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

require 'spec_helper'

describe UsersController do
  before(:each) do
    @user = FactoryGirl.find_or_create(:user)
    @another_user = FactoryGirl.find_or_create(:archivist)
    sign_in @user
    User.any_instance.stubs(:groups).returns([])
    controller.stubs(:clear_session_user) ## Don't clear out the authenticated session
  end
  describe "#show" do
    it "show the user profile if user exists" do
      get :show, uid: @user.login
      response.should be_success
      response.should_not redirect_to(root_path)
      flash[:alert].should be_nil
    end
    it "redirects to root if user does not exist" do
      get :show, uid: 'johndoe666'
      response.should redirect_to(root_path)
      flash[:alert].should include ("User 'johndoe666' does not exist")
    end
  end
  describe "#edit" do
    it "show edit form when user edits own profile" do
      get :edit, uid: @user.login
      response.should be_success
      response.should render_template('users/edit')
      flash[:alert].should be_nil
    end
    it "redirects to show profile when user attempts to edit another profile" do
      get :edit, uid: @another_user.login
      response.should redirect_to(profile_path(@another_user.login))
      flash[:alert].should include("You cannot edit archivist1's profile")
    end
  end
  describe "#update" do
    it "should not allow other users to update" do
      post :update, uid: @another_user.login, user: { avatar: nil }
      response.should redirect_to(profile_path(@another_user.login))
      flash[:alert].should include("You cannot edit archivist1's profile")
    end
    it "should set an avatar and redirect to profile" do
      @user.avatar.file?.should be_false
      Resque.expects(:enqueue).with(UserEditProfileEventJob, @user.login).once
      f = fixture_file_upload('/world.png', 'image/png')
      post :update, uid: @user.login, user: { avatar: f }
      response.should redirect_to(profile_path(@user.login))
      flash[:notice].should include("Your profile has been updated")
      User.find_by_login(@user.login).avatar.file?.should be_true
    end
    it "should validate the content type of an avatar" do
      Resque.expects(:enqueue).with(UserEditProfileEventJob, @user.login).never
      f = fixture_file_upload('/image.jp2', 'image/jp2')
      post :update, uid: @user.login, user: { avatar: f }
      response.should redirect_to(edit_profile_path(@user.login))
      flash[:alert].should include("Avatar content type is invalid")
    end
    it "should validate the size of an avatar" do
      f = fixture_file_upload('/4-20.png', 'image/png')
      Resque.expects(:enqueue).with(UserEditProfileEventJob, @user.login).never
      post :update, uid: @user.login, user: { avatar: f }
      response.should redirect_to(edit_profile_path(@user.login))
      flash[:alert].should include("Avatar file size must be less than 2097152 Bytes")
    end
    it "should delete an avatar" do
      Resque.expects(:enqueue).with(UserEditProfileEventJob, @user.login).once
      post :update, uid: @user.login, delete_avatar: true
      response.should redirect_to(profile_path(@user.login))
      flash[:notice].should include("Your profile has been updated")
      @user.avatar.file?.should be_false
    end
    it "should refresh directory attributes" do
      Resque.expects(:enqueue).with(UserEditProfileEventJob, @user.login).once
      User.any_instance.expects(:populate_attributes).once
      post :update, uid: @user.login, update_directory: true
      response.should redirect_to(profile_path(@user.login))
      flash[:notice].should include("Your profile has been updated")
    end
  end
  describe "#follow" do
    after(:all) do
      @user.unfollow(@another_user) rescue nil
    end
    it "should follow another user if not already following, and log an event" do
      @user.following?(@another_user).should be_false
      Resque.expects(:enqueue).with(UserFollowEventJob, @user.login, @another_user.login).once
      post :follow, uid: @another_user.login
      response.should redirect_to(profile_path(@another_user.login))
      flash[:notice].should include("You are following #{@another_user.login}")
    end
    it "should redirect to profile if already following and not log an event" do
      User.any_instance.stubs(:following?).with(@another_user).returns(true)
      Resque.expects(:enqueue).with(UserFollowEventJob, @user.login, @another_user.login).never
      post :follow, uid: @another_user.login
      response.should redirect_to(profile_path(@another_user.login))
      flash[:notice].should include("You are following #{@another_user.login}")
    end
    it "should redirect to profile if user attempts to self-follow and not log an event" do
      Resque.expects(:enqueue).with(UserFollowEventJob, @user.login, @user.login).never
      post :follow, uid: @user.login
      response.should redirect_to(profile_path(@user.login))
      flash[:alert].should include("You cannot follow or unfollow yourself")
    end
  end
  describe "#unfollow" do
    it "should unfollow another user if already following, and log an event" do
      User.any_instance.stubs(:following?).with(@another_user).returns(true)
      Resque.expects(:enqueue).with(UserUnfollowEventJob, @user.login, @another_user.login).once
      post :unfollow, uid: @another_user.login
      response.should redirect_to(profile_path(@another_user.login))
      flash[:notice].should include("You are no longer following #{@another_user.login}")
    end
    it "should redirect to profile if not following and not log an event" do
      @user.stubs(:following?).with(@another_user).returns(false)
      Resque.expects(:enqueue).with(UserUnfollowEventJob, @user.login, @another_user.login).never
      post :unfollow, uid: @another_user.login
      response.should redirect_to(profile_path(@another_user.login))
      flash[:notice].should include("You are no longer following #{@another_user.login}")
    end
    it "should redirect to profile if user attempts to self-follow and not log an event" do
      Resque.expects(:enqueue).with(UserUnfollowEventJob, @user.login, @user.login).never
      post :unfollow, uid: @user.login
      response.should redirect_to(profile_path(@user.login))
      flash[:alert].should include("You cannot follow or unfollow yourself")
    end
  end
end
