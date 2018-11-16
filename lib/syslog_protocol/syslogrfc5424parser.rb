require 'time'

module SyslogProtocol

  def self.syslog5424_parse(msg, origin=nil)
    packet = SyslogRfc5424Packet.new
    original_msg = msg.dup
    pri = syslog5424_parse_pri(msg)
    if pri and (pri = pri.to_i).is_a? Integer and (0..191).include?(pri)
      packet.pri = pri
    else
      # If there isn't a valid PRI, treat the entire message as content
      packet.pri = 13
      packet.time = Time.now
      packet.hostname = origin || 'unknown'
      packet.content = original_msg

      return packet
    end
    time = syslog5424_parse_time(msg)
    if time
      packet.time = Time.parse(time)
    else
      packet.time = Time.now
    end
    hostname = syslog5424_parse_hostname(msg)
    packet.hostname = hostname || origin
    appname = syslog5424_parse_appname(msg)
    packet.appname = appname
    procid = syslog5424_parse_procid(msg)
    packet.procid = procid
    msgid = syslog5424_parse_msgid(msg)
    packet.msgid = msgid
    structured_data = syslog5424_parse_structured_data(msg)
    packet.structured_data = structured_data
    content = syslog5424_parse_content(msg)
    packet.content = content

    packet
  end

  private

  def self.syslog5424_parse_pri(msg)
    pri = msg.slice!(/<(\d\d?\d?)>1/)
    pri = pri.slice(/\d\d?\d?/) if pri
    if !pri or (pri =~ /^0/ and pri !~ /^0$/)
      return nil
    else
      return pri
    end
  end

  def self.syslog5424_parse_time(msg)
    msg.slice!(/(\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\d\d\d\d\+\d\d:\d\d)/)
  end

  def self.syslog5424_parse_hostname(msg)
    m = msg.split(" ")
    if m.nil? or m.empty?
      raise ArgumentError, "Message format is not correct"
    end
    return m[0]

  end

  def self.syslog5424_parse_appname(msg)
    m = msg.split(" ")
    if m.nil? or m.empty?
      raise ArgumentError, "Message format is not correct"
    end
    return m[1]
  end
  def self.syslog5424_parse_procid(msg)
    m = msg.split(" ")

    if m.nil? or m.empty?
      raise ArgumentError, "Message format is not correct"
    end
    return m[2]
  end
  def self.syslog5424_parse_msgid(msg)
    m = msg.split(" ")
    if m.nil? or m.empty?
      raie ArgumentError, "Message format is not correct"
    end
    return m[3]
  end

  def self.syslog5424_parse_content(msg)
    m = msg.match(/(.*)\s(.*)\s(.*)\s(.*)\s(-)\s(.*)/)
    if m.nil?
      s = msg.match(/(.*)\s(\[.*\])\s(.*)/)
      if s.nil?
        raise ArgumentError, "Message format is not correct"
      else
        return s[3]
      end
    else
      return m[6]
    end
  end

  def self.syslog5424_parse_structured_data(msg)
    s_data = {}
    m = msg.match(/(.*)\s(\[.*\])\s/)
    s_data = parse_structured_data(m[2]) unless m.nil?
    return s_data
  end

  private
  def self.parse_structured_data(sdata)
   structured_data = {}
   sdata_key = ''
   sdata_value = {}
   arr = sdata.sub(/^\[/, "").sub(/\]/,"").split(" ")
   arr.each { |item|
     if item.include?("@")
       sdata_key = item
     else
       key, value = item.split("=")
       sdata_value[key] = value
     end
   }
   structured_data[sdata_key] = sdata_value
   return structured_data
  end
end