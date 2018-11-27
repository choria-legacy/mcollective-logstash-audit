Logstash RPC Audit Logs
=======================

## Deprecation Notice

This repository holds legacy code related to The Marionette Collective project.  That project has been deprecated by Puppet Inc and the code donated to the Choria Project.

Please review the [Choria Project Website](https://choria.io) and specifically the [MCollective Deprecation Notice](https://choria.io/mcollective) for further information and details about the future of the MCollective project.

## Overview

This is a [SimpleRPC Audit Plugin](http://docs.puppetlabs.com/mcollective/simplerpc/auditing.html) that writes audit events to a json file that can
easily be consumed by logstash.

[Logstash](http://www.logstash.net/) is an opensource project that stores log lines and allow you to do full text and meta data based searches on that data.

[![mcollective-logstash](images/mcollective-logstash.png)](https://raw.github.com/puppetlabs/mcollective-logstash-audit/master/images/mcollective-logstash.png)

The image above shows a screenshot of Kibana showing all RPC requests made by a specific client, you can also see meta data for one of the requests.

Installation
------------

 * Follow the [basic plugin install guide](http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/InstalingPlugins).
 * You need to have the JSON RubyGem install on all nodes

Configuration
-------------

The logfile defaults to /var/log/mcollective-audit.log but can be changed as below, you also need to enable auditing as per the example below:

     rpcaudit = 1
     rpcauditprovider = logstash
     plugin.logstash.logfile = /var/log/mcollective-logstashaudit.log

Logstash
--------

A possible Logstash shipper configuration might look like this.

    input {
      file {
        type => 'mcollective-audit'
        path => '/var/log/mcollective-audit.log'
        format => json_event
      }
    }

This tells the log shipper to fetch audit log entries from the same location that you’ve configured above in the mcollective config.
