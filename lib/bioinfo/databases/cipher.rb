#!/usr/bin/env ruby
# encoding: UTF-8
require 'fileutils'

# {Bioinfo::Databases::Cipher Bioinfo::Databases::Cipher} object gets top 
# 1000 genes for each phenotype, described by OMIM ID), from {CIPHER_WEBSITE
# Cipher website}.
#
# == Mechanism
# The process of {Bioinfo::Databases::Cipher Bioinfo::Databases::Cipher} is 
# simple and can be described by following steps:
# * fetch the disease list and the gene list
# * search and download the corresponding Cipher gene table of each OMIM ID
# * normalize gene identifiers to Approved Symbol and make them unique
#   * delete ones without approved symbols
#   * delete redundant symbols who rank lower
#
# Different from {Bioinfo::Scripts::Cipher Bioinfo::Scripts::Cipher}, this 
# process is absolutely a database searching, which makes the class named under
# {Bioinfo::Databases Bioinfo::Databases}.
#
# == About Cipher
# Correlating protein Interaction network and PHEnotype network to pRedict 
# disease genes (CIPHER), is a computational framework that integrates human 
# protein–protein interactions, disease phenotype similarities, and known 
# gene–phenotype associations to capture the complex relationships between 
# phenotypes and genotypes.
#
# == Reference
# {http://www.nature.com/msb/journal/v4/n1/full/msb200827.html
# Xuebing Wu, Rui Jiang, Michael Q. Zhang, Shao Li. 
# Network-based global inference of human disease genes. 
# Molecular Systems Biology, 2008, 4:189.}
#
class Bioinfo::Databases::Cipher
  extend Bioinfo::Modules::WorkingDir

  # Current version of Cipher
  VERSION = "0.1.0"
  # The url of Cipher website
  CIPHER_WEBSITE = "http://bioinfo.au.tsinghua.edu.cn/cipher/"

  # Get the table of cipher genes
  # @return [Hash] OMIM IDs as keys
  # @example
  #   Bioinfo::Databases::Cipher.new("137280").genes
  #   # => genes = {
  #   #   "137280" => [
  #   #     ["GSS", 1, "0.152752"], # [String, Fixnum, String]
  #   #     ...
  #   #   ]
  #   # }
  attr_reader :genes

  # Initialize the Cipher object
  # @example
  #   Bioinfo::Databases::Cipher.new("137280")
  #   # => #<Bioinfo::Databases::Cipher @genes.keys=["137280"]>
  # @overload initialize(omim_ids)
  #   @param [Array] omim_ids
  # @overload initialize(omim_id1, ...)
  #   @param [String] omim_id1
  def initialize(*omim_ids)
    # Ensure HGNC loaded
    "".hgncid2symbol rescue Bioinfo::Databases::HGNC.new.as_dictionary
    # Load disease list
    unless self.class.class_variable_defined?(:@@disease_list)
      @@disease_list = {}
      filename = self.class.path_to("landscape_phenotype.txt")
      File.open(filename, 'w:UTF-8').puts Bioinfo::Utility.request(CIPHER_WEBSITE + "landscape_phenotype.txt").gsub("\r","") unless File.exist?(filename)
      File.open(filename).each do |line|
        column = line.chomp.split("\t")
        column[2].gsub!('"', '')
        @@disease_list[column[1]] = column
      end
    end
    # Load gene list
    unless self.class.class_variable_defined?(:@@gene_list)
      @@gene_list = [nil]
      filename = self.class.path_to("landscape_extended_id.txt")
      File.open(filename, 'w:UTF-8').puts Bioinfo::Utility.request(CIPHER_WEBSITE + "landscape_extended_id.txt").gsub("\r","") unless File.exist?(filename)
      File.open(filename).each do |line|
        column = line.chomp.split("\t")
        gene   = String.hgnc.symbol2hgncid[column[4]]
        gene ||= String.hgnc.uniprot2hgncid[column[2]]
        gene ||= String.hgnc.refseq2hgncid[column[3]]
        @@gene_list.push(gene ? gene.hgncid2symbol : nil)
      end
    end
    # Generate @genes table
    @genes = Hash.new { |hash, key| hash[key] = [] }
    omim_ids.flatten.uniq.each do |_omim_id_|
      unless /(?<omim_id>\d+)/ =~ _omim_id_.to_s && @@disease_list[omim_id]
        Bioinfo.log.warn("Cipher") { "OMIM ID #{_omim_id_.inspect} discarded, since it doesn't exist in the disease list of Cipher" }
        next
      end
      filename = self.class.path_to(@@disease_list[omim_id][0] + ".txt")
      File.open(filename, 'w:UTF-8').puts Bioinfo::Utility.request(CIPHER_WEBSITE + "top1000data/#{@@disease_list[omim_id][0]}.txt").gsub("\r","") unless File.exist?(filename)
      File.open(filename).each_with_index do |line, index|
        column = line.chomp.split("\t")
        gene = @@gene_list[column[0].to_i]
        @genes[omim_id].push [gene, index + 1, column[1]] if gene
      end
      @genes[omim_id].uniq! { |item| item[0] }
    end
    # For debug
    Bioinfo.log.debug("Cipher") { "New object " + self.inspect }
  end
  # Write gene tables to files
  # @param [String] path Where to create files
  # @param [Boolean] with_title Wheter to print a title line
  # @return [self]
  def export(path, with_title = true)
    FileUtils.mkdir_p(path)
    @genes.each do |key, value|
      fout = File.open(File.expand_path("cipher_gene_#{key}.txt", path), 'w:UTF-8')
      fout.puts "Approved Symbol\tCipher Rank\tCipher Score" if with_title
      value.each { |l| fout.puts l.join("\t") }
      fout.close
    end
    return self
  end
  # @private
  def inspect
    "#<Bioinfo::Databases::Cipher @genes.keys=#{@genes.keys}>"
  end
  # @private
  def to_s
    inspect
  end
end

Bioinfo::Databases::Cipher.wd = Bioinfo.path_to("data/cipher")
