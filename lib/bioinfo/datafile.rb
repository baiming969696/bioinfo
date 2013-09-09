#!/usr/bin/env ruby
# encoding: UTF-8

# This module is designed to load data files into Bioinfo as an Array, 
# especially those in accord with Bioinfo data format. Customized format 
# is also supported by calling blocks.
#
# == Bioinfo Text Data
# Bioinformatics deals with data, which is expressed in txt in many cases.
# We define some rules and two types format for exchanging and communicating.
#
# * Rules
#   * Encode in ASCII or UTF-8
#   * Any line starts with "#" is a comment and should be ignored
#   * Use tab to separate values, comma to separate values of an array
#     * Example
#         Name  Emails    
#         John  john@live.com, john@gmail.com
# * List format
#   * Just a list of things. Usually used to translate between outer indexes 
#     and inner indexes.
#   * Example
#       # Gene Symbol
#       NFKB1
#       ...
# * Table format
#   * Tab separated values.
#   * Example
#       NFKB1   0.23   3.512   ...
#       ...     ...    ...     ...
#
# == Shortage
# DataFile can't handle big data file under the limit of your memory. You 
# should process them line by line instead :)
module Bioinfo::DataFile
  module_function

  # Load a data file, process each line with given block
  # @return [Array]
  def load(filename, opts={})
    rtn = opts[:without_name] ? [] : [opts[:name] || filename]
    File.open(filename).each do |line|
      next if line =~ /^#/
      rtn<<yield(line)
    end
    return rtn
  end
  # Load a list
  def load_list(filename, opts={})
    rtn = opts[:without_name] ? [] : [opts[:name] || filename]
    File.open(filename).each do |line|
      next if line =~ /^#/
      line =~ /,/ ? rtn<<line.chomp.split(/,\s?/) : rtn<<line.chomp
    end
    return rtn
  end
  # Load a table
  # @return [Array]
  def load_table(filename, opts={})
    rtn = opts[:without_name] ? [] : [opts[:name] || filename]
    File.open(filename).each do |line|
      next if line =~ /^#/
      rtn<<(line.chomp.split("\t").collect { |col| col =~ /,/ ? col.split(/,\s?/) : col })
    end
    return rtn      
  end
end
