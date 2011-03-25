module SyslogProto

  class Logger
    
    def initialize(hostname, facility)
      @packet = Packet.new
      @packet.hostname = hostname
      @packet.facility = facility
    end
    
    SEVERITIES.each do |k,v|
      define_method(k) do |*args|
        msg = args.shift
        raise ArgumentError.new "MSG may not be omitted" unless msg and msg.length > 0
        p = @packet.dup
        p.severity = k
        p.msg = msg
        p.assemble
      end
    end
    
  end

end
