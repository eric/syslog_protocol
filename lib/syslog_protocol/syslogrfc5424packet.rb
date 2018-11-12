module SyslogProtocol
    class SyslogRfc5424Packet < Packet
      attr_reader :appname, :procid, :msgid, :structured_data

      def initialize(appname = nil, procid = nil, msgid = nil, facility = nil)
        super()
        @msgid = format_field(msgid, 32)
        @procid = format_field(procid, 128)
        @appname = format_field(appname, 48)
        @structured_data = {}
      end

      def assemble(max_size = 1024)
        unless @hostname and @facility and @severity and @appname
          raise "Could not assemble packet without hostname, tag, facility, and severity"
        end
        sd = '-'
        unless @structured_data.empty?
          sd = format_sdata(@structured_data)
        end
        fmt = "<%s>1 %s %s %s %s %s %s %s"
        data = fmt % [pri, @time, @hostname,
                  @appname, format_field(@procid, 128),@msgid, sd, @content]

        if string_bytesize(data) > max_size
          data = data.slice(0, max_size)
          while string_bytesize(data) > max_size
            data = data.slice(0, data.length - 1)
          end
        end

        data
      end

      def generate_timestamp
        @time || Time.now.to_datetime.rfc3339(6)
      end

      def appname=(a)
        unless a && a.is_a?(String) && a.length > 0
          raise ArgumentError, "Appname must not be omitted"
        end
        if a.length > 48
          raise ArgumentError, "Appname must not be longer than 48 characters"
        end
        if a =~ /\s/
          raise ArgumentError, "Appname may not contain spaces"
        end
        if a =~ /[^\x21-\x7E]/
          raise ArgumentError, "Appname may only contain ASCII characters 33-126"
        end

        @appname = a
      end

      def procid=(p)
        if p.length > 128
          raise ArgumentError.new("Procid can't be bigger than 128")
        end
        @procid = format_field(p, 128)
      end

      def msgid=(m)
        if m.is_a? Integer
          @msgid = format_field(m.to_s, 32)
        elsif m.is_a? String
          if m.length > 32
            raise ArgumentError, "msgid must not be longer than 32 characters"
          else
            @msgid = format_field(m, 32)
          end
        else
          raise ArgumentError.new "msgid must be a number or string"
        end
      end

      def structured_data=(s)
        if s.is_a? Hash
          @structured_data = s
        else
          raise ArgumentError.new "structured_data must be a dict"
        end
      end

      def format_sdata(sdata)
        if sdata.empty?
          '-'
        end
        r = []
        sdata.each { |sid, hash|
          s = []
          s.push(sid.to_s.gsub(/[^-@\w]/, ""))
          hash.each { |n, v|
            # RFC-5424 requires SD-NAME to be 32 length
            paramname = format_field(n.to_s.gsub(/[^-@\w]/, ""), 32)
            paramvalue = v.to_s.gsub(/[\]"=]/, "")
            s.push("#{paramname}=\"#{paramvalue}\"")
          }
          r.push("["+s.join(" ")+"]")
        }
        rx = []
        r.each { |x|
          rx.push("[#{x}]")
        }
        r.join("")
      end

    end
end
