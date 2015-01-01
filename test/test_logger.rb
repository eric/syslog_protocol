require File.expand_path('../helper', __FILE__)

describe "syslog logger" do

  it "create a new logger with hostname and facility" do
    lambda {@logger = SyslogProtocol::Logger.new("space_station", 'test', "local0")}.should.not.raise
  end

  it "hostname and facility must conform to the requirements of a Packet" do
    lambda {SyslogProtocol::Logger.new("space station", "some shit", 'test test')}.should.raise ArgumentError
  end

  it "generates packets" do
    # We have to set a time so we have a consistant timestamp to check against..
    p = @logger.instance_variable_get("@packet")
    p.time = Time.now
    ts = p.generate_timestamp
    @logger.debug("vacuum tubez are operational").should.equal "<135>#{ts} space_station test: vacuum tubez are operational\n"
    @logger.info("firing thrusters at 13 degrees").should.equal "<134>#{ts} space_station test: firing thrusters at 13 degrees\n"
    @logger.notice("the hyper drive has been activated").should.equal "<133>#{ts} space_station test: the hyper drive has been activated\n"
    @logger.warn("meteorites incoming!").should.equal "<132>#{ts} space_station test: meteorites incoming!\n"
    @logger.err("vacuum tube 3 in hyper drive failed").should.equal "<131>#{ts} space_station test: vacuum tube 3 in hyper drive failed\n"
    @logger.crit("wing struck by a meteorite!").should.equal "<130>#{ts} space_station test: wing struck by a meteorite!\n"
    @logger.alert("LEAKING ATMOSPHERE").should.equal "<129>#{ts} space_station test: LEAKING ATMOSPHERE\n"
    @logger.emerg("LEAKING ASTRONAUTS WE ARE DONE").should.equal "<128>#{ts} space_station test: LEAKING ASTRONAUTS WE ARE DONE\n"
  end

end
