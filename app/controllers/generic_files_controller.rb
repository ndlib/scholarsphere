# -*- coding: utf-8 -*-
# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class GenericFilesController < ApplicationController
  include Hydra::Controller::ControllerBehavior
  include Hydra::AssetsControllerHelper  # for apply_depositor_metadata method
  include Hydra::Controller::UploadBehavior # for add_posted_blob_to_asset method
  include Blacklight::Configurable # comply with BL 3.7
  include ScholarSphere::Noid # for normalize_identifier method

  # This is needed as of BL 3.7
  self.copy_blacklight_config_from(CatalogController)

  rescue_from AbstractController::ActionNotFound, :with => :render_404

  # actions: audit, index, create, new, edit, show, update, destroy, permissions, citation
  before_filter :authenticate_user!, :except => [:show, :citation]
  before_filter :has_access?, :except => [:show]
  before_filter :enforce_access_controls
  before_filter :find_by_id, :except => [:index, :create, :new]
  prepend_before_filter :normalize_identifier, :except => [:index, :create, :new]

  # routed to /files/new
  def new
    @generic_file = GenericFile.new
    @batch_noid = ScholarSphere::Noid.noidify(ScholarSphere::IdService.mint)
  end

  # routed to /files/:id/edit
  def edit
    @terms = @generic_file.get_terms
    @groups = current_user.groups
  end

  # routed to /files/:id
  def index
    @generic_files = GenericFile.find(:all, :rows => GenericFile.count)
    render :json => @generic_files.map(&:to_jq_upload).to_json
  end

  # routed to /files/:id (DELETE)
  def destroy
    pid = @generic_file.noid
    @generic_file.delete
    begin
      Resque.enqueue(ContentDeleteEventJob, pid, current_user.login)
    rescue Redis::CannotConnectError
      logger.error "Redis is down!"
    end
    redirect_to dashboard_path, :notice => render_to_string(:partial=>'generic_files/asset_deleted_flash', :locals => { :generic_file => @generic_file })
  end

  # routed to /files (POST)
  def create
    begin
      retval = " "
      # check error condition No files
      if !params.has_key?(:files)
         retval = render :json => [{:error => "Error! No file to save"}].to_json

      # check error condition empty file
      elsif ((params[:files][0].respond_to?(:tempfile)) && (params[:files][0].tempfile.size == 0))
         retval = render :json => [{ :name => params[:files][0].original_filename, :error => "Error! Zero Length File!"}].to_json

      elsif ((params[:files][0].respond_to?(:size)) && (params[:files][0].size == 0))
         retval = render :json => [{ :name => params[:files][0].original_filename, :error => "Error! Zero Length File!"}].to_json

      # process file
      else
        create_and_save_generic_file
        if @generic_file
          begin
            Resque.enqueue(ContentDepositEventJob, @generic_file.pid, current_user.login)
          rescue Redis::CannotConnectError
            logger.error "Redis is down!"
          end
          respond_to do |format|
            format.html {
              retval = render :json => [@generic_file.to_jq_upload].to_json,
                :content_type => 'text/html',
                :layout => false
            }
            format.json {
              retval = render :json => [@generic_file.to_jq_upload].to_json
            }
          end
        else
          retval = render :json => [{:error => "Error creating generic file."}].to_json
        end
      end
    rescue => error
      logger.warn "GenericFilesController::create rescued error #{error.backtrace}"
      retval = render :json => [{:error => "Error occurred while creating generic file."}].to_json
    ensure
      # remove the tempfile (only if it is a temp file)
      params[:files][0].tempfile.delete if params[:files][0].respond_to?(:tempfile)
    end

    return retval
  end

  # routed to /files/:id/citation
  def citation
  end

  # routed to /files/:id
  def show
    perms = permissions_solr_doc_for_id(@generic_file.pid)
    @can_read =  can? :read, perms
    @can_edit =  can? :edit, perms
    @events = @generic_file.events(100)

    respond_to do |format|
      format.html
      format.endnote { render :text => @generic_file.export_as_endnote }
    end
  end

  # routed to /files/:id/audit (POST)
  def audit
    render :json=>@generic_file.audit
  end

  # routed to /files/:id (PUT)
  def update
    version_event = false

    if params.has_key?(:revision) and params[:revision] !=  @generic_file.content.latest_version.versionID
      revision = @generic_file.content.get_version(params[:revision])
      @generic_file.add_file_datastream(revision.content, :dsid => 'content')
      version_event = true
      begin
        Resque.enqueue(ContentRestoredVersionEventJob, @generic_file.pid, current_user.login, params[:revision])
      rescue Redis::CannotConnectError
        logger.error "Redis is down!"
      end
    end

    if params.has_key?(:filedata)
      return unless virus_check(params[:filedata]) == 0
      add_posted_blob_to_asset(@generic_file, params[:filedata])
      version_event = true
      begin
        Resque.enqueue(ContentNewVersionEventJob, @generic_file.pid, current_user.login)
      rescue Redis::CannotConnectError
        logger.error "Redis is down!"
      end
    end
    @generic_file.update_attributes(params[:generic_file].reject { |k,v| %w{ Filedata Filename revision part_of date_modified date_uploaded format }.include? k})
    @generic_file.set_visibility(params)
    @generic_file.date_modified = Time.now.ctime
    @generic_file.save
    # do not trigger an update event if a version event has already been triggered
    begin
      Resque.enqueue(ContentUpdateEventJob, @generic_file.pid, current_user.login) unless version_event
    rescue Redis::CannotConnectError
      logger.error "Redis is down!"
    end
    record_version_committer(@generic_file, current_user)
    redirect_to edit_generic_file_path(:tab => params[:redirect_tab]), :notice => render_to_string(:partial=>'generic_files/asset_updated_flash', :locals => { :generic_file => @generic_file })

  end

  # routed to /files/:id/permissions (POST)
  def permissions
    ScholarSphere::GenericFile::Permissions.parse_permissions(params)
    @generic_file.update_attributes(params[:generic_file].reject { |k,v| %w{ Filedata Filename revision}.include? k})
    @generic_file.save
    Resque.enqueue(ContentUpdateEventJob, @generic_file.pid, current_user.login)
    redirect_to edit_generic_file_path, :notice => render_to_string(:partial=>'generic_files/asset_updated_flash', :locals => { :generic_file => @generic_file })
  end

  protected
  def record_version_committer(generic_file, user)
    version = generic_file.content.latest_version
    # content datastream not (yet?) present
    return if version.nil?
    VersionCommitter.create(:obj_id => version.pid,
                            :datastream_id => version.dsid,
                            :version_id => version.versionID,
                            :committer_login => user.login)
  end

  def find_by_id
    @generic_file = GenericFile.find(params[:id])
  end

  def virus_check( file)
      stat = 0 # ClamAV.instance.scanfile(file.path)
      flash[:error] = "Virus checking did not pass for #{file.original_filename} status = #{stat}" unless stat == 0
      logger.warn "Virus checking did not pass for #{file.inspect} status = #{stat}" unless stat == 0
      return stat
  end 

  def create_and_save_generic_file
    unless params.has_key?(:files)
      logger.warn "!!!! No Files !!!!"
      return
    end
    file = params[:files][0]
    return nil unless virus_check(file) == 0  

    @generic_file = GenericFile.new
    # if we want to be able to save zero length files then we can use this to make the file 1 byte instead of zero length and fedora will take it
    #if (file.tempfile.size == 0)
    #   logger.warn "Encountered an empty file...  Creating a new temp file with on space."
    #   f = Tempfile.new ("emptyfile")
    #   f.write " "
    #   f.rewind
    #   file.tempfile = f
    #end
    add_posted_blob_to_asset(@generic_file,file)
    apply_depositor_metadata(@generic_file)
    @generic_file.date_uploaded = Time.now.ctime
    @generic_file.date_modified = Time.now.ctime
    @generic_file.relative_path = params[:relative_path] if params.has_key?(:relative_path)
    @generic_file.creator = current_user.name

    if params.has_key?(:batch_id)
      batch_id = ScholarSphere::Noid.namespaceize(params[:batch_id])
      @generic_file.add_relationship("isPartOf", "info:fedora/#{batch_id}")
    else
      logger.warn "unable to find batch to attach to"
    end

    save_tries = 0
    begin
      @generic_file.save
    rescue RSolr::Error::Http => error
      logger.warn "GenericFilesController::create_and_save_generic_file Caught RSOLR error #{error.inspect}"
      save_tries++
      # fail for good if the tries is greater than 3
      rescue_action_without_handler(error) if save_tries >=3
      sleep 0.01
      retry
    end
    record_version_committer(@generic_file, current_user)
    begin
      Resque.enqueue(UnzipJob, @generic_file.pid) if file.content_type == 'application/zip'
    rescue Redis::CannotConnectError
      logger.error "Redis is down!"
    end
    return @generic_file
  end
end
