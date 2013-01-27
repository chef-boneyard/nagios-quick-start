#
# Cookbook Name:: rsyslog_test
# Minitest:: cook-2141
#
# Copyright 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path('../support/helpers', __FILE__)

describe "rsyslog_test::cook-2141" do
  include Helpers::RsyslogTest

  it 'contains the PreserveFQDN configuration directive' do
    file('/etc/rsyslog.conf').must_include('$PreserveFQDN off')
  end
end
