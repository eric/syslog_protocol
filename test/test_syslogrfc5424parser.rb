require File.expand_path('../helper', __FILE__)

describe "a syslog 5424 format message packet parser" do

  it "parse some valid packets" do
    p = SyslogProtocol.syslog5424_parse("<34>1 2018-11-14T12:41:48.686781+08:00 mymachine fluentd erlang 1234567 [test@xxxxx kube-namespace=\"test\" pod_name=\"test-0\" container_name=\"test\"] message is sent")
    p.facility.should.equal 4
    p.severity.should.equal 2
    p.pri.should.equal 34
    p.hostname.should.equal "mymachine"
    p.appname.should.equal 'fluentd'
    p.msgid = "1234567"
    p.procid = "erlang"
    p.structured_data = {"test@xxxxx" => { "kube-namespace" => "test", "pod_name" => "test-0", "container_name" => "test"}}
    p.content.should.equal "message is sent"
    p.time.should.equal Time.parse("2018-11-14T12:41:48.686781+08:00")

    p = SyslogProtocol.syslog5424_parse("<13>1 2018-10-01T06:11:48.686781+08:00 10.0.0.99 fluentd erlang 1234567 [test@xxxxx kube-namespace=\"test\" pod_name=\"test-0\" container_name=\"test\"] Use the BFG!")
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal "10.0.0.99"
    p.appname.should.equal 'fluentd'
    p.msgid = "1234567"
    p.procid = "erlang"
    p.structured_data = {"test@xxxxx" => { "kube-namespace" => "test", "pod_name" => "test-0", "container_name" => "test"}}
    p.content.should.equal "Use the BFG!"
    p.time.should.equal Time.parse("2018-10-01T06:11:48.686781+08:00")
  end

  it "treat a packet with no valid PRI as all content, setting defaults" do
    p = SyslogProtocol.syslog5424_parse("nomnom")
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal 'unknown'
    p.content.should.equal "nomnom"
  end

  it "PRI with preceding 0's shall be considered invalid" do
    p = SyslogProtocol.syslog5424_parse("<045>1 Oct 11 22:14:15 space_station my PRI is not valid")
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal 'unknown'
    p.content.should.equal "<045>1 Oct 11 22:14:15 space_station my PRI is not valid"
  end

  it "allow the user to pass an origin to be used as the hostname if packet is invalid" do
    p = SyslogProtocol.syslog5424_parse("<045>1 Oct 11 22:14:15 space_station my PRI is not valid", '127.0.0.1')
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal '127.0.0.1'
    p.content.should.equal "<045>1 Oct 11 22:14:15 space_station my PRI is not valid"
  end

  it "parse a packet with structured_data default value of '-'" do
    p = SyslogProtocol.syslog5424_parse("<13>1 2018-10-01T06:11:48.686781+08:00 10.0.0.99 fluentd erlang 1234567 - Use the BFG!")
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal "10.0.0.99"
    p.appname.should.equal 'fluentd'
    p.msgid = "1234567"
    p.procid = "erlang"
    p.structured_data = {}
    p.content.should.equal "Use the BFG!"
    p.time.should.equal Time.parse("2018-10-01T06:11:48.686781+08:00")
  end
end
