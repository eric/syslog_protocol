Gem::Specification.new do |s|
  s.name = "syslogproto"
  s.version = "0.0.1"
  s.date = "2009-08-01"
  s.authors = ["Jake Douglas"]
  s.email = "jakecdouglas@gmail.com"
  s.has_rdoc = false
  s.add_dependency('bacon')
  s.summary = "Syslog protocol"
  s.homepage = "http://www.github.com/yakischloba/syslog"
  s.description = "Syslog protocol"
  s.files =
    ["syslogproto.gemspec",
    "README.rdoc",
    "Rakefile",
    "lib/syslogproto.rb",
    "lib/syslogproto/common.rb",
    "lib/syslogproto/logger.rb",
    "lib/syslogproto/packet.rb",
    "lib/syslogproto/parser.rb",
    "test/test_logger.rb",
    "test/test_packet.rb",
    "test/test_parser.rb"]
end
