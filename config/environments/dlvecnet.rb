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

ScholarSphere::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.log_level = :debug

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  #config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Compress assets
  config.assets.compress = true

  # Expands the lines which load the assets
  config.assets.debug = false

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # adjust to where fits is installed
  config.fits_path = '/opt/fits-0.6.1/fits.sh'

  config.assets.precompile += %w( generic_files.js dashboard.js video.js audio.min.js jquery.zclip.min.js bootstrap-tooltip.js bootstrap-popover.js video-js.css generic_files.css jquery-ui-1.8.1.custom.css jquery-ui-1.8.23.custom.css bootstrap.min.css batch.js reset_body.css scholarsphere-bootstrap.css bootstrap-modal.js jquery.validate.js swfobject.js)
  config.assets.precompile += %w( *.jpg *.png *.gif *.ico )

  #config.logout_url = 'http://cas.library.nd.edu' # 'https://webaccess.psu.edu/cgi-bin/logout?http://localhost:3000/'
  #config.login_url = 'http://cas.library.nd.edu/cas/login?service=http://localhost:8080' # 'https://webaccess.psu.edu?cosign-localhost&http://localhost:3000/'
end

