#!/usr/bin/env ruby
# encoding: UTF-8

# OMIM was originally designed to be read by humans, we hereby designed 
# {Bioinfo::Databases::OMIM Bioinfo::Databases::OMIM} to retrieve the 
# OMIM entries and store them in suitable data structure.
#
# == Prerequisite
# Please manually download the omim data from {ftp://grcf.jhmi.edu/OMIM OMIM ftp}.
# * "mim2gene.txt"
# * "omim.txt.Z" and decompress it to get "omim.txt"
#
# == Example Usage
# Set working path to the diretory where you store "mim2gene.txt" and 
# "omim.txt" first.
#   Bioinfo::Databases::OMIM.wd = "/home/aidistan/download/"
#
# Load OMIM entries.
#   Bioinfo::Databases::OMIM.load_entries
#
# == Reference
# {http://omim.org/ OMIM website}
module Bioinfo::Databases::OMIM
  extend Bioinfo::Modules::WorkingDir

  module_function

  # Load OMIM ID list using {Bioinfo::DataFile.load_table}
  # @return [Array] A table
  def get_list
    Bioinfo::DataFile.load_table(path_to("mim2gene.txt"))
  end
  # Load OMIM entries
  # @param [Array] include_fields
  # @return [Hash]
  # @example
  #   Bioinfo::Databases::OMIM.load_entries
  #   # => 
  #   { "100050" => 
  #     {
  #       id:"100050"
  #     }
  #   }
  #
  def load_entries(include_fields = ["TX", "CS"])
    if File.exist?(path_to("omim.bin"))
      omim = Marshal.load(File.binread(path_to("omim.bin")))
    else
      Bioinfo.log.info("OMIM") { "Process omim.txt for the first time. It may take several minutes." }

      # Ensure HGNC loaded
      "".hgncid2symbol rescue Bioinfo::Databases::HGNC.new.as_dictionary

      omim = {}
      File.open(path_to("omim.txt")) do |fin|
        no = id = title = nil
        content = ""
        inside = {record:false, field:false}
        fin.each do |line|
          break if line =~ /^\*THEEND\*/
          if line =~ /^\*RECORD\*/
            inside[:record] = true
            if title
              omim[no] = { id:id, title:title, content:content }
              id = title = nil
              content = ""
            end
            next
          end
          case line
          when /^\*FIELD\* NO/
            no = fin.gets.chomp
          when /^\*FIELD\* TI/
            id, title = fin.gets.chomp.split(" ", 2)
          when /^\*FIELD\*/
            /^\*FIELD\* (?<field>\w\w)/ =~ line
            inside[:field] = include_fields.include?(field) ? true : false
          else
            content+= line.chomp if inside[:field]
          end
        end
      end

      File.binwrite(path_to("omim.bin"), Marshal.dump(omim))
    end

    # For debug
    Bioinfo.log.debug("OMIM") { omim.keys.size.to_s + " entries loaded." }
  end
end
