name              "nagios"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures Nagios3 server and the NRPE client"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "3.1.0"

recipe "nagios", "Includes the client recipe."
recipe "nagios::client", "Installs and configures a nagios client with nrpe"
recipe "nagios::server", "Installs and configures a nagios server"
recipe "nagios::pagerduty", "Integrates contacts w/ PagerDuty API"

%w{ apache2 build-essential php nginx nginx_simplecgi }.each do |cb|
  depends cb
end

%w{ debian ubuntu redhat centos fedora scientific amazon oracle}.each do |os|
  supports os
end
