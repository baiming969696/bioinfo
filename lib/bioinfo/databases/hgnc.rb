#!/usr/bin/env ruby
# encoding: UTF-8
require 'fileutils'

# HGNC object loads in a table in HGNC-database format and builds hashes 
# storing the convertion pairs, using Entrez ID as primatry key.
#
# == Example Usage
#
# === Instantiation
# Create an HGNC using default downloaded HGNC data is the most common way.
#   hgnc = Bioinfo::Databases::HGNC.new
#
# Or you want to create an instance with your own HGNC table.
#   hgnc = Bioinfo::Databases::HGNC.new("path_to_your_table/hgnc_custom.txt")
#
# === Convert in hash way
# Using HGNC object in hash way is the most effective way but without symbol 
# rescue function.
#   hgnc.entrez2symbol["100"] # => "ADA"
#   some_function(hgnc.entrez2symbol["100"], other_params) unless hgnc.entrez2symbol["100"].nil?
#
# Note that nil (not "") will be returned by hash if failed to index.
#   hgnc.symbol2entrez["NOT_SYMBOL"] # => nil
#
# And the hash does not rescue symbols if fail to index.
#   hgnc.symbol2entrez["ada"] # => nil
#
# === Convert in method way
# Using HGNC object to convert identifers in method way would rescue symbol 
# while costs a little more.
#   hgnc.entrez2symbol("100") # => "ADA"
#   some_function(hgnc.entrez2symbol("100"), other_params) unless hgnc.entrez2symbol("100") == ""
#
# Note that empty String "" (not nil) will be returned if failed to convert.
#   hgnc.symbol2entrez["NOT_SYMBOL"] # => ""
#
# Method will rescue symbols if fail to query.
#   hgnc.symbol2entrez("ada") # => "100"
#
# === Convert String or Array
# Using extended String or Array is a more Ruby way (as far as I think). Just 
# to claim an HGNC object as the dictionary at first.
#   BioDB::HGNC.new.as_dictionary
#
# Then miricles happen.
#   "100".entrez2symbol # => "ADA"
#   some_function("100".entrez2symbol, other_params) unless "100".entrez2symbol == ""
#
# Note that empty String "" (not nil) will be returned if fail to convert 
#   "NOT_SYMBOL".symbol2entrez # => ""
#   "NOT_SYMBOL".symbol2entrez.entrez2ensembl # => ""
#
# Have fun!
#   "APC".symbol2entrez.entrez2ensembl # => "ENSG00000134982"
#   ["APC", "IL1"].symbol2entrez # => ["324","3552"] 
#   nil.entrez2ensembl # NoMethodError
#
# == About HGNC Database
# The HUGO Gene Nomenclature Committee (HGNC) is the only worldwide authority 
# that assigns standardised nomenclature to human genes. For each known human 
# gene their approve a gene name and symbol (short-form abbreviation).  All 
# approved symbols are stored in the HGNC database. Each symbol is unique and 
# HGNC ensures that each gene is only given one approved gene symbol. 
#
# == Reference
# {http://www.genenames.org/ HUGO Gene Nomenclature Committee at the European Bioinformatics Institute}
class Bioinfo::Databases::HGNC
  extend Bioinfo::Modules::WorkingDir

  # Current version of HGNC
  VERSION = "0.1.0"
  # Download url of default hgnc table
  DOWNLOAD_URL = "http://www.genenames.org/cgi-bin/hgnc_downloads?col=gd_hgnc_id&col=gd_app_sym&col=gd_app_name&col=gd_status&col=gd_prev_sym&col=gd_aliases&col=gd_pub_chrom_map&col=gd_pub_acc_ids&col=gd_pub_refseq_ids&col=md_eg_id&col=md_refseq_id&col=md_prot_id&col=md_ensembl_id&status=Approved&status=Entry+Withdrawn&status_opt=2&where=%28%28gd_pub_chrom_map+not+like+%27%25patch%25%27+and+gd_pub_chrom_map+not+like+%27%25ALT_REF%25%27%29+or+gd_pub_chrom_map+IS+NULL%29+and+gd_locus_group+%3D+%27protein-coding+gene%27&order_by=gd_hgnc_id&format=text&limit=&hgnc_dbtag=on&submit=submit"

  # Returns true if rescue symbol
  # @return [Boolean]
  def self.rescue_symbol?
    @@rescue_symbol
  end
  # When set to true, try to rescue unrecognized symbol
  # @param [Boolean] boolean
  # @return [Boolean]
  def self.rescue_symbol= (boolean)
    @@rescue_symbol = (boolean ? true : false)

    # Load in rescue history if exists
    if @@rescue_symbol && !self.class_variable_defined?(:@@rescue_history)
      @@rescue_history = {}
      @@rescue_history_filename = File.expand_path("rescue_history.txt", self.wd)
      if FileTest.exists?(@@rescue_history_filename)
        File.open(@@rescue_history_filename).each do |line|
          column = line.chomp.split("\t")
          @@rescue_history[column[0]] = column[1]
        end
      end
    end
    return @@rescue_symbol
  end
  # Return current rescue method
  # @return [Symbol] :manual or :auto
  def self.rescue_method
    @@rescue_method
  end
  # When set to :manual, user has to explain every new unrecognized symbol; 
  # otherwise, HGNC will try to do this by itself.
  # @param [Symbol] symbol :manual or :auto
  # @return [Symbol]
  def self.rescue_method= (symbol)
    @@rescue_method = (symbol == :manual ? :manual : :auto)
  end

  # Create a new HGNC object based on the given table or one downloaded from {DOWNLOAD_URL} if filepath is nil.
  # @param [String] filepath the path of your HGNC table files if default not used
  def initialize(filepath = nil)
    filepath ||= File.expand_path("hgnc_downloads.txt", Bioinfo::Databases::HGNC.wd)    
    @symbol2entrez  = {}
    @entrez2symbol  = {}
    @uniprot2entrez = {}
    @entrez2uniprot = {}
    @refseq2entrez  = {}
    @entrez2refseq  = {}
    @ensembl2entrez = {}
    @entrez2ensembl = {}

    # Download hgnc data table if in need
    unless File.exists?(filepath)
      Bioinfo.log.warn("HGNC") { "Databse file not exist in the given path: \"#{File.dirname(filepath)}\". Trying to download one instead." }
      FileUtils.mkdir_p(File.dirname(filepath)) unless Dir.exists?(File.dirname(filepath))
      File.open(filepath, 'w').puts Bioinfo::Utility.request(DOWNLOAD_URL)
    end
    fin = File.new(filepath)

    # Titleline
    @col = {}
    fin.gets.chomp.split("\t").each_with_index do |column, index|
      case column
      when /HGNC ID/             then @col[:HGNC_ID] = index
      when /Approved Symbol/     then @col[:Approved_Symbol] = index
      when /Previous Symbols/    then @col[:Previous_Symbols] = index
      when /Synonyms/            then @col[:Synonyms] = index
      when /Entrez Gene ID/      then @col[:Entrez_Gene_ID] = index
      when /RefSeq IDs/          then @col[:RefSeq_IDs] = index
      when /RefSeq/              then @col[:RefSeq] = index
      when /UniProt ID/          then @col[:UniProt_ID] = index
      when /Ensembl ID/          then @col[:Ensembl_ID] = index
      end
    end

    # Content
    fin.each do |line|
      column = line.chomp.split("\t")
      next if column[@col[:Entrez_Gene_ID]] == "" # Next line if no existing primary key

      @symbol2entrez[column[@col[:Approved_Symbol]]] = column[@col[:Entrez_Gene_ID]]
      @entrez2symbol[column[@col[:Entrez_Gene_ID]]] = column[@col[:Approved_Symbol]]
      column[@col[:Previous_Symbols]].split(", ").each { |symb| @symbol2entrez[symb] = column[@col[:Entrez_Gene_ID]] if @symbol2entrez[symb].nil? }
      column[@col[:Synonyms]].split(", ").each { |symb| @symbol2entrez[symb] = column[@col[:Entrez_Gene_ID]] if @symbol2entrez[symb].nil? }

      unless @col[:UniProt_ID].nil? or column[@col[:UniProt_ID]] == "-" or column[@col[:UniProt_ID]].nil? or column[@col[:UniProt_ID]] == ""
        @uniprot2entrez[column[@col[:UniProt_ID]]] = column[@col[:Entrez_Gene_ID]]
        @entrez2uniprot[column[@col[:Entrez_Gene_ID]]] = column[@col[:UniProt_ID]]
      end
      unless @col[:RefSeq].nil? or column[@col[:RefSeq]].nil? or column[@col[:UniProt_ID]] == ""
        @refseq2entrez[column[@col[:RefSeq]]] = column[@col[:Entrez_Gene_ID]]
        @entrez2refseq[column[@col[:Entrez_Gene_ID]]] = column[@col[:RefSeq]]
      end
      unless @col[:RefSeq_IDs].nil? or column[@col[:RefSeq_IDs]].nil? or column[@col[:RefSeq_IDs]] == ""
        column[@col[:RefSeq_IDs]].split(", ").each { |refseq| @refseq2entrez[refseq] = column[@col[:Entrez_Gene_ID]] if @refseq2entrez[refseq].nil? }
      end
      unless @col[:Ensembl_ID].nil? or column[@col[:Ensembl_ID]].nil? or column[@col[:UniProt_ID]] == ""
        @ensembl2entrez[column[@col[:Ensembl_ID]]] = column[@col[:Entrez_Gene_ID]]
        @entrez2ensembl[column[@col[:Entrez_Gene_ID]]] = column[@col[:Ensembl_ID]]
      end
    end
    fin.close

    Bioinfo.log.debug("HGNC") { "New object " + self.inspect }
  end
  # Try to rescue a gene symbol
  # @param [String] symbol Gene symbol
  # @param [Symbol] method :auto or :manual
  # @param [Boolean] isPreview When set to true, neither outputing warnings nor modifying rescue history
  # @return [String] "" if rescue failed
  def rescue_symbol(symbol, method = @@rescue_method, isPreview = false)
    case method
    when :auto
      auto_rescue = ""
      if @symbol2entrez[symbol.upcase]
        auto_rescue = symbol.upcase
      elsif @symbol2entrez[symbol.gsub('-','')]
        auto_rescue = symbol.gsub('-','')
      elsif @symbol2entrez[symbol.upcase.gsub('-','')]
        auto_rescue = symbol.upcase.gsub('-','')
      # Add more rules here
      end
      # Record
      unless isPreview
        Bioinfo.log.warn("HGNC") { "Unrecognized symbol \"#{symbol}\", \"#{auto_rescue}\" used instead" }
        @@rescue_history[symbol] = auto_rescue
      end
      return auto_rescue
    when :manual
      # Try automatic rescue first
      if (auto_rescue = rescue_symbol(symbol, :auto, true)) != ""
        print "\"#{symbol}\" unrecognized. Use \"#{auto_rescue}\" instead? [Yn] "
        unless gets.chomp == 'n'
          @@rescue_history[symbol] = auto_rescue unless isPreview
          return auto_rescue
        end
      end
      # Manually rescue
      loop do
        print "Please correct \"#{symbol}\" or press enter directly to return empty String instead:\n"
        unless (manual_rescue = gets.chomp) == "" || @symbol2entrez[manual_rescue]
          puts "Failed to recognize \"#{manual_rescue}\""
          next
        end
        @@rescue_history[symbol] = manual_rescue unless isPreview
        File.open(@@rescue_history_filename, "a").print(symbol, "\t", manual_rescue, "\n") unless isPreview
        return manual_rescue
      end
    end
  end
  # Return the statistics hash
  # @return [Hash]
  # @example
  #   Bioinfo::Databases::HGNC.new("test_hgnc_dataset.txt").stat
  #   # => {"Gene Symbol"=>24, "Entrez ID"=>9, "Refseq ID"=>13, "Uniprot ID"=>9, "Ensembl ID"=>9}
  def stat
    @stat = {
      "Gene Symbol" => @symbol2entrez.size,
      "Entrez ID"   => @entrez2symbol.size,
      "Refseq ID"   => @refseq2entrez.size
    }
    @stat["Uniprot ID"] = @uniprot2entrez.size unless @col[:UniProt_ID].nil?
    @stat["Ensembl ID"] = @ensembl2entrez.size unless @col[:Ensembl_ID].nil?
    return @stat
  end
  # @private
  def inspect
    "#<Bioinfo::Databases::HGNC @stat=#{stat.inspect}>"
  end
  # @private
  def to_s
    inspect
  end

  #
  # @!group Convertion Methods
  #

  # @overload symbol2entrez
  #   Get symbol2entrez hash
  #   @return [Hash]
  # @overload symbol2entrez(symbol)
  #   Convert symbol into entrez
  #   @param [String] symbol
  #   @return [String] "" for no result
  def symbol2entrez(symbol = nil)
    return @symbol2entrez unless symbol
    begin
      (symbol == "") ? "" : @symbol2entrez.fetch(symbol)
    rescue
      if @@rescue_symbol
        @@rescue_history[symbol] ? @symbol2entrez[@@rescue_history[symbol]].to_s : @symbol2entrez[rescue_symbol(symbol)].to_s
      else
        ""
      end
    end
  end
  # @overload uniprot2entrez
  #   Get the uniprot2entrez hash
  #   @return [Hash]
  # @overload uniprot2entrez(uniprot)
  #   Convert uniprot into entrez
  #   @param [String] uniprot
  #   @return [String] "" for no result
  def uniprot2entrez(uniprot = nil)
    return @uniprot2entrez unless uniprot
    return @uniprot2entrez[uniprot].to_s
  end
  # @overload refseq2entrez
  #   Get the refseq2entrez hash
  #   @return [Hash]
  # @overload refseq2entrez(refseq)
  #   Convert refseq into entrez
  #   @param [String] refseq
  #   @return [String] "" for no result
  def refseq2entrez(refseq = nil)
    return @refseq2entrez unless refseq
    return @refseq2entrez[refseq].to_s
  end
  # @overload ensembl2entrez
  #   Get the ensembl2entrez hash
  #   @return [Hash]
  # @overload ensembl2entrez(ensembl)
  #   Convert ensembl into entrez
  #   @param [String] ensembl
  #   @return [String] "" for no result
  def ensembl2entrez(ensembl = nil)
    return @ensembl2entrez unless ensembl
    return @ensembl2entrez[ensembl].to_s
  end
  # @overload entrez2symbol
  #   Get the entrez2symbol hash
  #   @return [Hash]
  # @overload entrez2symbol(entrez)
  #   Convert entrez into symbol
  #   @param [String] entrez
  #   @return [String] "" for no result
  def entrez2symbol(entrez = nil)
    return @entrez2symbol unless entrez
    return @entrez2symbol[entrez].to_s
  end
  # @overload entrez2uniprot
  #   Get the entrez2uniprot hash
  #   @return [Hash]
  # @overload entrez2uniprot(entrez)
  #   Convert entrez into uniprot
  #   @param [String] entrez
  #   @return [String] "" for no result
  def entrez2uniprot(entrez = nil)
    return @entrez2uniprot unless entrez
    return @entrez2uniprot[entrez].to_s
  end
  # @overload entrez2refseq
  #   Get the entrez2refseq hash
  #   @return [Hash]
  # @overload entrez2refseq(entrez)
  #   Convert entrez into refseq
  #   @param [String] entrez
  #   @return [String] "" for no result
  def entrez2refseq(entrez = nil)
    return @entrez2refseq unless entrez
    return @entrez2refseq[entrez].to_s
  end
  # @overload entrez2ensembl
  #   Get the entrez2ensembl hash
  #   @return [Hash]
  # @overload entrez2ensembl(entrez)
  #   Convert entrez into ensembl
  #   @param [String] entrez
  #   @return [String] "" for no result
  def entrez2ensembl(entrez = nil)
    return @entrez2ensembl unless entrez
    return @entrez2ensembl[entrez].to_s
  end

  #
  # @!endgroup
  #
end

require 'bioinfo/databases/hgnc/extend_core'

Bioinfo::Databases::HGNC.wd = File.expand_path("data/hgnc", Bioinfo.wd)
Bioinfo::Databases::HGNC.rescue_symbol = true
Bioinfo::Databases::HGNC.rescue_method = :auto
