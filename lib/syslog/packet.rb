module Syslog

  class Packet

    attr_reader :facility, :severity, :hostname
    attr_accessor :time, :msg
        
    def to_s
      assemble
    end

    def assemble
      unless @hostname and @facility and @severity
        return "I AM A JUNK PACKET CUZ MY USER DIDNT SET ME"
      end
      data = "<#{pri}>#{generate_timestamp} #{@hostname} #{@msg}"
      while data.bytesize > 1024
        data = data[0..(data.length-2)]
      end
      data
    end
    
    def facility=(f)
      if f.is_a? Integer
        if (0..23).include?(f)
          @facility = f
        else
          raise ArgumentError.new "Facility must be within 0-23"
        end
      elsif f.is_a? String
        if facility = FACILITIES[f]
          @facility = facility
        else
          raise ArgumentError.new "'#{f}' is not a designated facility"
        end
      else
        raise ArgumentError.new "Facility must be a designated number or string"
      end
    end

    def severity=(s)
      if s.is_a? Integer
        if (0..7).include?(s)
          @severity = s
        else
          raise ArgumentError.new "Severity must be within 0-7"
        end
      elsif s.is_a? String
        if severity = SEVERITIES[s]
          @severity = severity
        else
          raise ArgumentError.new "'#{s}' is not a designated severity"
        end
      else
        raise ArgumentError.new "Severity must be a designated number or string"
      end
    end

    def hostname=(h)
      unless h and h.is_a? String and h.length > 0
        raise ArgumentError.new("Hostname may not be omitted")
      end
      if h =~ /\s/
        raise ArgumentError.new("Hostname may not contain spaces")
      end
      if h =~ /[^\x21-\x7E]/
        raise ArgumentError.new("Hostname may only contain ASCII characters 33-126")
      end
      @hostname = h
    end

    def facility_name
      FACILITY_INDEX[@facility]
    end

    def severity_name
      SEVERITY_INDEX[@severity]
    end

    def pri
      (@facility * 8) + @severity
    end

    def pri=(p)
      unless p.is_a? Integer and (0..191).include?(p)
        raise ArgumentError.new "PRI must be a number between 0 and 191"
      end
      @facility = p / 8
      @severity = p - (@facility * 8)
    end
    
    def generate_timestamp
      time = @time || Time.now
      # The timestamp format requires that a day with fewer than 2 digits have
      # what would normally be a preceding zero, be instead an extra space.
      day = time.strftime("%d")
      day = day.sub(/^0/, ' ') if day =~ /^0\d/
      time.strftime("%b #{day} %H:%M:%S")
    end
    
    SEVERITIES.each do |k,v|
      define_method("#{k}?") {SEVERITIES[k] == @severity}
    end
    
  end

end