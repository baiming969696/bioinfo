#!/usr/bin/env ruby
# encoding: UTF-8

# Provide setter and getter for working directory variable @wd
module Bioinfo::Modules::WorkingDir
  # Get current working directory
  # @return [String]
  def wd
    @wd;
  end

  # Set current working directory
  #
  # If not exists, the method will try to mkdir one.
  #
  # @param [String] val
  def wd=(val)
    @wd = val

    dirs = []
    until Dir.exists?(val)
      dirs<<val
      val = File.dirname(val)
      # raise "Directory too deep" if dirs.size > 64
    end

    dirs.reverse.each { |d| Dir.mkdir(d) }
  end
end
