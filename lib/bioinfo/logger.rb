#!/usr/bin/env ruby
# encoding: UTF-8
require 'singleton'
require 'logger'

# Double-output featured logger
#
# Call {Bioinfo.log Bioinfo.log} to return the singleton instance instead of 
# anyway else and use it as if it's a std-lib {http://rubydoc.info/stdlib/logger/Logger Logger}.
#
# == Mechanism
# To realize the double-output feature, use the instance itself as a delegator 
# of two loggers, one linked to STDOUT, one linked to a log file in "#{Bioinfo.wd}/log".
#
class Bioinfo::Logger
  # Instance methods not in this list will be undefined at the beginning of
  # class definition
  PRESERVED = [:__id__, :object_id, :__send__, :respond_to?]

  instance_methods.each do |m|
    next if PRESERVED.include?(m)
    undef_method m
  end

  # Include modules after undefed methods
  include Singleton
  include Bioinfo::Modules::WorkingDir

  # Get the logger linked to STDOUT
  # @return [::Logger]
  attr_reader :screen_logger
  # Get the logger linked to log file
  # @return [::Logger]
  attr_reader :file_logger

  # @private
  def inspect
    "#<Bioinfo::Logger.singleton>"
  end
  # @private
  def to_s
    inspect
  end
  def respond_to?(sym)
    return true if super(sym)
    return @screen_logger.respond_to?(sym)
  end

  private

  def initialize
    self.wd = Bioinfo.path_to("log")
    
    # STDOUT
    @screen_logger = Logger.new(STDOUT)
    @screen_logger.level = Logger::INFO
    @screen_logger.formatter = proc { |severity, datetime, progname, msg|
      "[#{severity}] #{progname}: #{msg}\n"
    }

    # Log file
    @file_logger = Logger.new(path_to(Bioinfo::Utility.get_timestamp + ".log"))
    @file_logger.level = Logger::DEBUG
  end
  # Transmit method call if std-lib Logger can respond to it
  def method_missing(symbol, *args, &block)
    if @screen_logger.respond_to?(symbol)
      if block
        @screen_logger.send(symbol, *args, &block)
        @file_logger.send(symbol, *args, &block)
      else
        @screen_logger.send(symbol, *args)
        @file_logger.send(symbol, *args)
      end
    else
      super
    end
  end
end
