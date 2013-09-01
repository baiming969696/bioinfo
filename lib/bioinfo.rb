#!/usr/bin/env ruby
# encoding: UTF-8

# Top level namespace of Bioinfo
#
# == Example Usage
#
# === Initialization
# Call {Bioinfo.init} to initialize Bioinfo with conventions at first.
#   require 'bioinfo'
#   Bioinfo.init
#
# Sometimes custom initialization fits your need better. Write the process 
# according to {Bioinfo.init} to make sure that nothing is left uninitiated 
# which may make some problems hard to debug.
#   require 'bioinfo'
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
  self.autoload(:Script, "bioinfo/script")

  extend Modules::WorkingDir

	# Current version of Bioinfo
	VERSION = "0.0.1"

  # Default working directory
  DEFAULT_WORKING_DIRECTORY = File.expand_path("../..",__FILE__)

  module_function

  # Default initialization
  # @return [Bioinfo] the Bioinfo module itself
  def init 
    Bioinfo.wd = Bioinfo::DEFAULT_WORKING_DIRECTORY
    Bioinfo.log.level = Logger::DEBUG
    return self
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
end
