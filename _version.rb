#!/usr/bin/env ruby
# encoding: UTF-8

module Bioinfo
  File.open(File.expand_path("../lib/bioinfo.rb", __FILE__)).each do |line|
    if line =~ /VERSION = "(.*)"/
      VERSION = $1
      break
    end
  end

  VERSION = "Unknown" unless Bioinfo.const_defined?("VERSION")
end

puts "Bioinfo::VERSION detected by _version.rb: #{Bioinfo::VERSION}"
