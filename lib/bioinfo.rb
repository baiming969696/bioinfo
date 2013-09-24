#!/usr/bin/env ruby
# encoding: UTF-8

# Top level namespace of Bioinfo
#
# === Initialization
# It's unnecessary to initialize Bioinfo after requiring since Bioinfo follows
# the principle "Convention over Configuration". 
#   require 'bioinfo'
#   Bioinfo.init # unnecessary but no harm
#
# Sometimes custom initialization fits your need better. Write the process 
# according to {Bioinfo.init} to make sure that anything left uninitiated will 
# not affect your final result.
#   require 'bioinfo'
#
#   Bioinfo.wd = "/home/aidistan/bioinfo"
#   Bioinfo.log.level = Logger::WARN
#
module Bioinfo
  # autoloaders - modules
  self.autoload(:Utility, "bioinfo/utility")
  self.autoload(:Modules, "bioinfo/modules")
  self.autoload(:Databases, "bioinfo/databases")
  self.autoload(:Scripts, "bioinfo/scripts")
  # autoloaders - classes
  self.autoload(:Logger, "bioinfo/logger")
  self.autoload(:DataFile, "bioinfo/datafile")

  extend Modules::WorkingDir

	# Current version of Bioinfo
	VERSION = "0.0.3"
  # Default working directory
  DEFAULT_WORKING_DIRECTORY = File.expand_path("../..",__FILE__)

  module_function

  # Run Bioinfo in irb
  def irb
    system "irb -I #{File.dirname(__FILE__)} -r bioinfo -r irb/completion --simple-prompt"
  end
  # Get the instance of Bioinfo::Logger
  # @return [Bioinfo::Logger]
  def log
    Logger.instance
  end
  # Get the instance of Bioinfo::Utility::NetworkOption
  # @return [Bioinfo::Utility::NetworkOption]
  def opt_network
    Utility::NetworkOption.instance
  end
  # Default initialization
  # @return [Bioinfo] the Bioinfo module itself
  def init 
    Bioinfo.wd = Bioinfo::DEFAULT_WORKING_DIRECTORY
    Bioinfo.log.level = Logger::INFO
    return self
  end
end

# Extention to Ruby's Core library
class String; end
# Extention to Ruby's Core library
class Array; end

# Necessary initialization
Bioinfo.wd = Bioinfo::DEFAULT_WORKING_DIRECTORY
