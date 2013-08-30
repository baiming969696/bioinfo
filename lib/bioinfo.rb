#!/usr/bin/env ruby
# encoding: UTF-8

# Top level namespace of Bioinfo
module Bioinfo
	# Current version of Bioinfo
	VERSION = "0.0.1"

  # Default working directory
  WORKING_DIRECTORY = File.expand_path("../..",__FILE__)

  # autoloaders - modules
  self.autoload(:Utility, "bioinfo/utility")
  self.autoload(:Modules, "bioinfo/modules")
  self.autoload(:Databases, "bioinfo/databases")
  self.autoload(:Scripts, "bioinfo/scripts")

  # autoloaders - classes
  self.autoload(:Logger, "bioinfo/logger")
  self.autoload(:Script, "bioinfo/script")

  class << self
    include Modules::WorkingDir

    # Get the instance of Bioinfo::Logger
    def log
      Logger.instance
    end
  end
end

# Initialize
Bioinfo.wd = Bioinfo::WORKING_DIRECTORY
