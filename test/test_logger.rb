require File.expand_path('../helper', __FILE__)

describe "syslog logger" do
  
  it "create a new logger with hostname and facility" do
    lambda {@logger = SyslogProto::Logger.new("space_station", "local0")}.should.not.raise
  end
  
  it "hostname and facility must conform to the requirements of a Packet" do
    lambda {SyslogProto::Logger.new("space station", "some shit")}.should.raise ArgumentError
  end
  
  it "generates packets" do
    # We have to set a time so we have a consistant timestamp to check against..
    p = @logger.instance_variable_get("@packet")
    p.time = Time.now
    ts = p.generate_timestamp
    @logger.debug("vacuum tubez are operational").should.equal "<135>#{ts} space_station vacuum tubez are operational"
    @logger.info("firing thrusters at 13 degrees").should.equal "<134>#{ts} space_station firing thrusters at 13 degrees"
    @logger.notice("the hyper drive has been activated").should.equal "<133>#{ts} space_station the hyper drive has been activated"
    @logger.warn("meteorites incoming!").should.equal "<132>#{ts} space_station meteorites incoming!"
    @logger.err("vacuum tube 3 in hyper drive failed").should.equal "<131>#{ts} space_station vacuum tube 3 in hyper drive failed"
    @logger.crit("wing struck by a meteorite!").should.equal "<130>#{ts} space_station wing struck by a meteorite!"
    @logger.alert("LEAKING ATMOSPHERE").should.equal "<129>#{ts} space_station LEAKING ATMOSPHERE"
    @logger.emerg("LEAKING ASTRONAUTS WE ARE DONE").should.equal "<128>#{ts} space_station LEAKING ASTRONAUTS WE ARE DONE"
  end
  
end