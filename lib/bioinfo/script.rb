#!/usr/bin/env ruby
# encoding: UTF-8

# Superclass of all script class
class Bioinfo::Script
  include Bioinfo::Modules::WorkingDir
  
  # Main entry for every script
  # @abstract
  def run
    raise NotImplementedError, "Please overload"
  end

  # Initailize instance varaibles
  def initialize
    self.wd = Bioinfo.wd + "/tmp/" + self.class.to_s
  end
end
