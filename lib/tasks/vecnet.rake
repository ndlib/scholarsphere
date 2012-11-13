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

require 'securerandom'

namespace :vecnet do
  desc "Add an initial user"
  task :hack_a_user => :environment do
    count = 0
    begin
      a = User.create(email: "none@example.com", login: "natalie#{count}", display_name: "Natalie", group_list: "")
      puts "Created user #{a.id}"
    rescue ActiveRecord::StatementInvalid
      count += 1
      retry
    end
  end
end
