This guide describes how to build a Nagios monitoring server using Chef cookbooks available from the [Cookbooks Community Site](http://cookbooks.opscode.com) and the Opscode Platform. It assumes you have followed the [Getting Started Guide](http://help.opscode.com/faqs/start/how-to-get-started) and already have Chef installed.  

*This guide uses Ubuntu 10.04 on Amazon AWS EC2 with Chef 0.10.0*

***Note:** At this time, the steps described above have only been tested on the identified platform(s).  Opscode has not researched and does not support alternative steps that may lead to successful completion on other platforms.  Platform(s) supported by this guide may change over time, so please do check back for updates.  If you'd like to undertake this guide on an alternate platform, you may desire to turn to open source community resources for support assistance.*

You can watch a short screencast of this guide [here](http://blip.tv/file/4718422).

<embed src="http://blip.tv/play/hMAggqGNUwA" type="application/x-shockwave-flash" width="600" height="480" allowscriptaccess="always" allowfullscreen="true"></embed>

At the end of this guide, you will have one Ubuntu 10.04 system running Nagios in Amazon EC2.

We are going to reuse a few cookbooks from the [Cookbooks Community Site](http://cookbooks.opscode.com) to build the environment. The **nagios** cookbook is required, of course. The Nagios web interface will be set up with **apache2**. Finally, we will need the **apt** cookbook to ensure the package cache is updated.

If you do not already have an account with Amazon AWS, go to [Amazon Web Sevices](http://aws.amazon.com/) and click "Sign up". You will need the access and secret access key credentials from the sign-up later.

Environment Setup
----

First, we will configure the local workstation.

### Shell Environment

Obtain the repository used for this guide. It contains all the components required. Use git:

    git clone git://github.com/opscode/nagios-quick-start.git

### Chef and Knife

You will need some additional gems for Knife. Fog requires XML2 and XSLT development headers so you'll need to install them for your operating system, for example on Debian and Ubuntu:

    sudo apt-get install libxml2-dev libxslt-dev
    sudo gem install knife-ec2 fog net-ssh-multi

As part of the [Getting Started Guide](help.opscode.com/faqs/start/how-to-get-started), you cloned a chef-repo and copied the Knife configuration file (knife.rb), validation certificate (ORGNAME-validator.pem) and user certificate (USERNAME.pem) to **~/chef-repo/.chef/**. Copy these files to the new rails-quick-start repository. You can also re-download the Knife configuration file for your [Organization from the Management Console](http://help.opscode.com/faqs/start/user-environment).

    mkdir ~/nagios-quick-start/.chef
    cp ~/chef-repo/.chef/knife.rb ~/nagios-quick-start/.chef
    cp ~/chef-repo/.chef/USERNAME.pem ~/nagios-quick-start/.chef
    cp ~/chef-repo/.chef/ORGNAME-validator.pem ~/nagios-quick-start/.chef

Add the Amazon AWS credentials to the Knife configuration file.

    vi ~/nagios-quick-start/.chef/knife.rb

Add the following two lines to the end:

    knife[:aws_access_key_id] = "replace with the Amazon Access Key ID"
    knife[:aws_secret_access_key] =  "replace with the Amazon Secret Access Key ID"

Once the nagios-quick-start and knife configuration is in place, we'll work from this directory.

    cd nagios-quick-start

### Amazon AWS EC2

In addition to the credentials, two additional things need to be configured in the AWS account.

Configure the default [security group](http://docs.amazonwebservices.com/AWSEC2/latest/DeveloperGuide/index.html?using-network-security.html) to allow incoming connections for the following ports.

* 22 - SSH
* 80 - Nagios web interface via Apache

Add these to the default security group for the account using the AWS Console.

1. Sign into the [Amazon AWS Console](https://console.aws.amazon.com/s3/home).
2. Click on the "Amazon EC2" tab at the top.
3. Click on "Security Groups" in the left sidebar of the AWS Console.
4. Select the "Default" group in the main pane.
5. Enter the values shown for each of the ports required.
![aws-management-console](http://img.skitch.com/20101207-nnsrab59tswrbmh56f7rw5k2a6.jpg)

Create an [SSH Key Pair](http://docs.amazonwebservices.com/AWSEC2/latest/DeveloperGuide/index.html?using-credentials.html#using-credentials-keypair) and save the private key in **~/.ssh**.

1. In the AWS Console, click on "Key Pairs" in the left sidebar.
2. Click on "Create Keypair" at the top of the main pane.
3. Give the keypair a name like "nagios-quick-start".
4. The keypair will be downloaded automatically by the browser and saved to the default Downloads location.
5. Move the nagios-quick-start.pem file from the default Downloads location to **~/.ssh** and change permissions so that only you can read the file. For example,

    mv ~/Downloads/nagios-quick-start.pem ~/.ssh  
    chmod 600 ~/.ssh/nagios-quick-start.pem

Acquire Cookbooks
----

The nagios-quick-start repository has all the cookbooks we need for this guide. They were downloaded along with their dependencies from the cookbooks site using Knife. These are in the **cookbooks/** directory.

    apache2
    apt
    nagios

Upload all the cookbooks to the Opscode Platform.

    knife cookbook upload -a

Server Roles
------------

All the required roles have been created in the nagios-quick-start repository. They are in the **roles/** directory.

    base.rb
    production.rb
    monitoring.rb

Upload all the roles to the Opscode Platform.

    rake roles

Data Bag Item
----

The nagios-quick-start repository contains a data bag item that has information about a default user that can log into the Nagios web interface, **nagiosadmin**.

The data bag name is **users** and the item name is **nagiosadmin**. Upload this to the Opscode Platform.

    knife data bag create users
    knife data bag from file users nagiosadmin.json

Launch Single Instance
----

We are going to use an m1.small instance with the 32 bit Ubuntu 10.04 image provided [by Canonical](http://uec-images.ubuntu.com/releases/10.04/release-20101228/). The identifier is **ami-7000f019** for the AMI in us-east-1 with instance storage that we will use in this guide.  We'll show you the **knife ec2 server create** sub-command to launch instances.

This command will:

* Launch a server on EC2.
* Connect it to the Opscode Platform.
* Configure the system with Chef.

Launch the Nagios monitoring server on a single instance.

    knife ec2 server create -G default -I ami-7000f019 -f m1.small \
    -S nagios-quick-start -i ~/.ssh/nagios-quick-start.pem -x ubuntu \
    -r 'role[production],role[base],role[monitoring]'

Once complete, the instance will be running Nagios.

Verification
----

Knife will output the fully qualified domain name of the instance when the command completes. You can navigate to the Nagios instance with:

    http://ec2-xxx-xx-xx-xxx.compute-1.amazonaws.com/

The login is nagiosadmin and the password is nagios.

Adding Service Checks
----

New service checks can be added easily. Update the services.cfg.erb template. If necessary, update the commands.cfg.erb template for an additional command. Then upload the cookbook.

If the check is for all hosts, use **hostgroup_name all**.

    vi cookbooks/nagios/templates/default/services.cfg.erb
    ...
    define service {
        service_description HTTP Processes
        hostgroup_name      webserver
        check_command       check_http
        use                 default-service
    }

If the check is for a certain role, such as **monitoring**, make sure it only gets enabled in the configuration if that role exists. For example:

    vi cookbooks/nagios/templates/default/services.cfg.erb
    ...
    <% unless @service_hosts['webserver'].nil? -%>
    define service {
        service_description HTTP Processes
        hostgroup_name      webserver
        check_command       check_http
        use                 default-service
    }

    <% end -%>

If the service check doesn't already exist in the commands.cfg.erb, add it.

    vi cookbooks/nagios/templates/default/commands.cfg.erb
    ...
    define command {
      command_name    check_http
      command_line    $USER1$/check_http -I $HOSTADDRESS$ -H $HOSTADDRESS$
    }

Upload the Nagios cookbook and run chef on the monitoring node.

    knife cookbook upload nagios
    knife ssh 'role:monitoring' 'sudo chef-client' -x ubuntu -i ~/.ssh/nagios-quick-start.pem

Refer to the [Nagios Documentation](http://nagios.sourceforge.net/docs/3_0/toc.html) for more information about writing Nagios service check definitions.

Adding NRPE Checks
----

To add a new NRPE check, create the entry in nrpe.cfg.erb. For example, to add a check for a process named "chef-client":

    vi cookbooks/nagios/templates/default/nrpe.cfg.erb
    ...
    command[check_chef_client]=/usr/lib/nagios/plugins/check_procs -w 1:2 -c 1:2 -C chef-client

Then upload the cookbook and run chef on the client systems, and the plugin will be enabled via NRPE.

    knife cookbook upload nagios
    knife ssh '*:*' 'sudo chef-client' -x ubuntu -i ~/.ssh/nagios-quick-start.pem

Refer to the [Nagios Documentation](http://nagios.sourceforge.net/docs/3_0/toc.html) for more information about NRPE.

Adding New Plugin Scripts
----

If you've found a cool Nagios plugin you'd like to use, you can distribute it to nodes with the cookbook files directory.

    cp check_something_cool cookbooks/nagios/files/default/plugins
    knife cookbook upload nagios
    knife ssh '*:*' 'sudo chef-client' -x ubuntu -i ~/.ssh/nagios-quick-start.pem

Then update the commands.cfg.erb for the new command, and enable a service check by adding an entry in services.cfg.erb, per the sections above.

Refer to the [Nagios Documentation](http://nagios.sourceforge.net/docs/3_0/toc.html) for more information about Nagios Plugins.

Appendix
----

### Adding New Systems

New Chef nodes added to the Chef Server will automatically be monitored by Nagios when **chef-client** runs on the **monitoring** server. Both Nagios hosts.cfg and hostgroups.cfg are dynamically configured, automatically, based on role and node search in the **nagios::server** recipe.

### Nagios Admin Password

The data bag item for Nagios contains a default password that should cetainly be changed to something stronger. The password in the data bag item is:

    "htpasswd": "{SHA}/i0Kels0lRtuw8RhhPHtPq4ZRZ0=",

This password was generated with **htpasswd -snb nagiosadmin nagios**. Use the **htpasswd** command to generate a new password.

    htpasswd -sn nagiosadmin
    New password:
    Re-type new password:

Then update the data bag item:

    vi data_bags/users/nagiosadmin.json
    "htpasswd": "NEWSHAPASSWORDFROMABOVE",

Once the entries are modified, simply load the data bag item from the json file:

    knife data bag from file users nagiosadmin.json

### Non-EC2 Systems

For people not using Amazon EC2, other Cloud computing providers can be used. Supported by Knife and fog as of this revision:

* Rackspace Cloud
* Terremark vCloud
* Slicehost

See the [launch cloud instances page](http://wiki.opscode.com/display/chef/Launch+Cloud+Instances+with+Knife) on the Chef wiki for more information about using Knife to launch these instance types.

For people not using cloud at all, but have their own infrastructure and hardware, use the [bootstrap](http://wiki.opscode.com/display/chef/Knife+Bootstrap) knife command. Note that the run-list syntax is slightly different.

    knife bootstrap IPADDRESS \
    -r 'role[production],role[base],role[monitoring]'

See the contextual help for knife bootstrap on the additional options to set for SSH.

    knife bootstrap --help

### A Note about EC2 Instances

We used an m1.small instance. This is a low performance instance size in EC2 and just fine for testing. Visit the Amazon AWS documentation to [learn more about instance sizes](http://aws.amazon.com/ec2/instance-types/).

Be sure to terminate instances when they are no longer needed as they will incur charges.
