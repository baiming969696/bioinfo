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
  # @param [String] val target working directory
  def wd=(val)
    Bioinfo::Utility::mkdir_with_parents(val)
    @wd = val
  end
end
