#!/usr/bin/env ruby
# encoding: UTF-8

# Top level namespace of Bioinfo
module Bioinfo
	# Current version of Bioinfo
	VERSION = "0.0.1"

  # Default working directory
  WORKING_DIRECTORY = File.expand_path("../..",__FILE__)

  # autoloaders - modules
  self.autoload(:Modules, "bioinfo/modules")
  self.autoload(:Databases, "bioinfo/databases")
  self.autoload(:Scripts, "bioinfo/scripts")

  # autoloaders - classes
  self.autoload(:Script, "bioinfo/script")

  class << self
    # Set autoloaders for given context
    # @param [Hash] hash module-path pairs
    # @param [Module] context in which to set the autoloaders
    def set_autoloaders(hash, context)
      hash.each { |mod, path| context.autoload(mod, path) }
    end

    # Include modules after self.set_autoloaders
    include Modules::WorkingDir
  end
end

# Initialize
Bioinfo.wd = Bioinfo::WORKING_DIRECTORY
