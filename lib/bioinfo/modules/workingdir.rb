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
  # @param [String] val target working directory
  def wd=(val)
    FileUtils.mkdir_p(val)
    @wd = val
  end
  # Expand a relative path to absolute one based on wd
  # @param [String] relative_path relative path
  # @return [String] absolute path
  def path_to(relative_path)
    File.expand_path(relative_path, @wd)
  end
end
