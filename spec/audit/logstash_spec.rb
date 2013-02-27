#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'audit', 'logstash.rb')

module MCollective
  module RPC

    describe Logstash do
      let(:config) do
        conf = mock
        conf.stubs(:identity).returns('rspec.com')
        conf.stubs(:pluginconf).returns({})
        conf
      end

      let(:time) do
        t = mock
        t.stubs(:utc).returns(t)
        t.stubs(:utc?).returns(true)
        t.stubs(:strftime).returns("2013-02-25T11:06:27")
        t.stubs(:tv_usec).returns(900133)
        t
      end

      let(:request) do
        req = mock
        req.stubs(:uniqid).returns('uniqid')
        req.stubs(:time).returns(time)
        req.stubs(:caller).returns('caller')
        req.stubs(:sender).returns('sender')
        req.stubs(:agent).returns('agent')
        req.stubs(:action).returns('test')
        req.stubs(:data).returns({:key => 'value'})
        req
      end

      before do
        Config.stubs(:instance).returns(config)
        Time.stubs(:at).returns(time)
        Time.stubs(:now).returns(time)
        @audit = Logstash.new
        @audit.stubs(:require)
      end

      describe '#audit_request' do
        it 'should load the target file from pluginconf' do
          config.stubs(:pluginconf).returns({'logstash.target' => 'rspec_target'})
          File.expects(:open).returns('rspec_target', 'a')
          @audit.audit_request(request, nil)
        end

        it 'should write to the default file if no config is specified' do
          File.expects(:open).returns('/var/log/mcollective-logstashaudit.log', 'a')
          @audit.audit_request(request, nil)
        end

        it 'should write the correct json to the target file' do
          require 'json'
          output = StringIO.new

          File.expects(:open).yields(output)
          @audit.audit_request(request, nil)
          output = JSON.load(output.string)
          output['@tags'].should == []
          output['@type'].should == 'mcollective-audit'
          output['@source'].should == 'mcollective-audit'
          output['@timestamp'].should == "2013-02-25T11:06:27.900133Z"
          output['@fields']['uniqid'].should == 'uniqid'
          output['@fields']['request_time'].should == '2013-02-25T11:06:27.900133Z'
          output['@fields']['caller'].should == 'caller'
          output['@fields']['callerhost'].should == 'sender'
          output['@fields']['agent'].should == 'agent'
          output['@fields']['action'].should == 'test'
          output['@fields']['data'].should == "{:key=>\"value\"}"
          output['@message'].should == 'rspec.com: caller@sender invoked agent agent#test'
        end

        it 'should log a warning if it cannot write to the target file' do
          File.expects(:open).raises('error')
          Log.expects(:warn).with('Cannot write to audit file %s: %s', ['/var/log/mcollective-audit.log','error'])
          @audit.audit_request(request, nil)
        end
      end

    end
  end
end
