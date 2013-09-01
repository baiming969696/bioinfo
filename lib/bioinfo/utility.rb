#!/usr/bin/env ruby
# encoding: UTF-8

# Utilities defined here to make Bioinfo namespace simple and tidy
module Bioinfo::Utility
  module_function

  # Set autoloaders for given context
  # @param [Hash] hash module-path pairs
  # @param [Module] context in which to set the autoloaders
  def set_autoloaders(hash, context)
    hash.each { |mod, path| context.autoload(mod, path) }
  end

  # Create the directory and make parent directories as needed
  # @param [String] dir target directory
  def mkdir_with_parents(dir)
    dirs = []
    until Dir.exists?(dir)
      dirs<<dir
      dir = File.dirname(dir)
      # raise "Directory too deep" if dirs.size > 64
    end

    dirs.reverse.each { |d| Dir.mkdir(d) }
  end

  # Get a timestamp string as a legal file name
  # @return [String]
  # @example
  #   Bioinfo::Utility.get_timestamp # => "20130830_175334"
  def get_timestamp
    Time.now.to_s.split(" ")[0..1].join("_").gsub(/-|:/,"")
  end
end
