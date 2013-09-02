#!/usr/bin/env ruby
# encoding: UTF-8
require 'fileutils'

# Provide setter and getter for working directory variable @wd
module Bioinfo::Modules::WorkingDir
  # Get current working directory
  # @return [String]
  # @raise RuntimeError Raised if @wd undefined
  def wd
    @wd or raise "The working directory of #{self} is undefined."
  end

  # Set current working directory
  #
  # If not exists, the method will try to mkdir one.
  #
  # @param [String] val target working directory
  def wd=(val)
    FileUtils.mkdir_p(val)
    @wd = val
  end
end
