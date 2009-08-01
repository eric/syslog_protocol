#!/usr/bin/env rake

task :default => [:test]

task :test do
  require 'lib/syslog'
  require 'bacon'
  Bacon.summary_at_exit
  Dir.glob("test/*.rb").each{|f| load f}
end