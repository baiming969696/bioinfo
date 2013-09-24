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
  # Create a new instance
  # @param [String] wd Working directory of this instance
  def initialize(wd)
    self.wd = wd
  end
  # @private
  def inspect
    "#<#{self.class} @wd=#{@wd}>"
  end
  # @private
  def to_s
    inspect
  end
end
