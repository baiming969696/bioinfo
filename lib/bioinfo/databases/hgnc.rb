#!/usr/bin/env ruby
# encoding: UTF-8

class Bioinfo::Databases::HGNC
  #
  # Macro definitions
  #
  private

  def self.create_converters(sym)
    class_eval %{
      def #{sym}
        { direct:@@direct_converters, indirect:@@indirect_converters }
      end
    }
    IDENTIFIERS.each_key do |src|
      IDENTIFIERS.each_key do |dst|
        next if src == dst
        sym = (src.to_s + "2" + dst.to_s).to_sym
        [src, dst].include?(:hgncid) ? create_direct_converter(sym) : create_indirect_converter(sym)
      end
    end
    return nil
  end

  def self.create_direct_converter(*syms)
    syms.each do |sym|
      class_variable_defined?(:@@direct_converters) ? @@direct_converters<<sym : @@direct_converters=[sym]
      class_eval %{
        def #{sym}(obj = nil)
          return @#{sym} unless obj
          return @#{sym}[obj.to_s].to_s rescue raise ArgumentError, "The parameter \\"\#{obj}\\"(\#{obj.class}) can't be converted into String"
        end
      }
      String.class_eval %{
        def #{sym}
          String.hgnc.#{sym}[self].to_s rescue raise "HGNC dictionary not given"
        end
        def #{sym}!
          replace(String.hgnc.#{sym}[self].to_s) rescue raise "HGNC dictionary not given"
        end
      }
      Array.class_eval %{
        def #{sym}
          self.collect do |item|
            item.to_s rescue raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array can't be converted into String"
          end.collect { |item| item.#{sym} }
        end
        def #{sym}!
          self.collect! do |item|
            item.to_s rescue raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array can't be converted into String"
          end.collect! { |item| item.#{sym} }
        end
      }
    end
    return nil
  end

  def self.create_indirect_converter(*syms)
    syms.each do |sym|
      class_variable_defined?(:@@indirect_converters) ? @@indirect_converters<<sym : @@indirect_converters=[sym]
      /^(?<src>[^2]+)2(?<dst>.+)$/ =~ sym.to_s
      class_eval %{
        def #{sym}(obj)
          return hgncid2#{dst}(#{src}2hgncid(obj)) rescue raise ArgumentError, "The parameter \\"\#{obj}\\"(\#{obj.class}) can't be converted into String"
        end
      }
      String.class_eval %{
        def #{sym}
          self.#{src}2hgncid.hgncid2#{dst}
        end
        def #{sym}!
          replace(self.#{src}2hgncid.hgncid2#{dst})
        end
      }
      Array.class_eval %{
        def #{sym}
          self.collect do |item|
            item.to_s rescue raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array can't be converted into String"
          end.collect { |item| item.#{src}2hgncid.hgncid2#{dst} }
        end
        def #{sym}!
          self.collect! do |item|
            item.to_s rescue raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array can't be converted into String"
          end.collect! { |item| item.#{src}2hgncid.hgncid2#{dst} }
        end
      }
    end
    return nil
  end
end

# HGNC object loads in any given table in HGNC format and builds hashes 
# storing the convertion pairs, using HGNC ID as the primary key.
#
# == Mechanism
# HGNC object stores several hashes to convert other identifiers from or into 
# HGNC IDs, since HGNC ID served as the primary key. Any converter whose name 
# includes "hgncid" is called a direct converter, otherwise a indirect 
# converter.
#
# == Example Usage
#
# === Instantiation
# Create an HGNC using default downloaded table is the most common way. It 
# may take minutes to download the table at the first time.
#   hgnc = Bioinfo::Databases::HGNC.new
#
# Or you want to create an instance with your own HGNC table.
#   hgnc = Bioinfo::Databases::HGNC.new("path_to_your_table/hgnc_custom.txt")
#
# === Convert in hash way
# Using HGNC object in hash way is the most effective way but without symbol 
# rescue. (Direct converters only)
#   hgnc.entrez2hgncid["ASIC1"] # => "HGNC:100"
#   some_function(hgnc.entrez2hgncid["ASIC1"], other_params) unless hgnc.entrez2hgncid["ASIC1"].nil?
#
# Note that nil (not "") will be returned by hash if failed to index.
#   hgnc.symbol2hgncid["NOT_SYMBOL"] # => nil
#
# And the hash does not rescue symbols if fail to index.
#   hgnc.symbol2hgncid["ada"] # => nil
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
# Using extended String or Array is a more "Ruby" way (as far as I think). 
# Just claim an HGNC object as the dictionary at first.
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
  VERSION = "0.2.0"
  # Download url of default HGNC table
  DOWNLOAD_URL = "http://www.genenames.org/cgi-bin/hgnc_downloads?col=gd_hgnc_id&col=gd_app_sym&col=gd_app_name&col=gd_status&col=gd_prev_sym&col=gd_aliases&col=gd_pub_chrom_map&col=gd_pub_acc_ids&col=gd_pub_refseq_ids&col=md_eg_id&col=md_refseq_id&col=md_prot_id&col=md_ensembl_id&status=Approved&status=Entry+Withdrawn&status_opt=2&where=%28%28gd_pub_chrom_map+not+like+%27%25patch%25%27+and+gd_pub_chrom_map+not+like+%27%25ALT_REF%25%27%29+or+gd_pub_chrom_map+IS+NULL%29+and+gd_locus_group+%3D+%27protein-coding+gene%27&order_by=gd_hgnc_id&format=text&limit=&hgnc_dbtag=on&submit=submit"
  # Identifers available in Bioinfo::Databases::HGNC by now mapped to headline in HGNC table
  IDENTIFIERS = {
    hgncid:"HGNC ID",
    symbol:["Approved Symbol", "Previous Symbols", "Synonyms"],
    entrez:"Entrez Gene ID(supplied by NCBI)",
    refseq:["RefSeq(supplied by NCBI)", "RefSeq IDs"],
    uniprot:"UniProt ID(supplied by UniProt)",
    ensembl:"Ensembl ID(supplied by Ensembl)",
  }

  # Convertion method family
  # @overload converter_list
  #   List all HGNC convertion methods
  #   @return [Hash]
  #   @example
  #     hgnc.converter_list
  #     # => {:direct=>[:hgncid2symbol, ...], :indirect=>[:symbol2entrez, ...]}
  # @overload direct_converter
  #   Get the corresponding hash
  #   @return [Hash]
  #   @example
  #     hgnc.symbol2hgncid          # => {...}
  #     hgnc.symbol2hgncid["ASIC1"] # => "HGNC:100"
  # @overload direct_converter(str)
  #   Convert str
  #   @param [String]
  #   @return [String] "" for no result
  #   @example
  #     hgnc.symbol2hgncid("ASIC1") # => "HGNC:100"
  #     hgnc.symbol2hgncid("") # => ""
  # @overload indirect_converter(str)
  #   Convert str
  #   @param [String]
  #   @return [String] "" for no result
  #   @example
  #     hgnc.symbol2entrez("ASIC1") # => "41"
  #     hgnc.symbol2entrez["ASIC1"] # => ArgumentError
  create_converters :converter_list

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
    if @@rescue_symbol && !class_variable_defined?(:@@rescue_history)
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
    # Instance variables
    @@direct_converters.each { |sym| instance_variable_set("@" + sym.to_s, {}) }

    if filepath
      raise ArgumentError, "#{filepath} not exists" unless File.exists?(filepath)
    else
      # Load the default HGNC table (may download if in need)
      filepath = File.expand_path("hgnc_downloads.txt", Bioinfo::Databases::HGNC.wd)
      unless File.exists?(filepath)
        Bioinfo.log.info("HGNC") { "Since default HGNC table not exists, trying to download one." }
        File.open(filepath, 'w').puts Bioinfo::Utility.request(DOWNLOAD_URL)
      end
    end    
    load_hgnc_table(File.open(filepath))
  
    Bioinfo.log.debug("HGNC") { "New object " + self.inspect }
  end
  # Use self as the dictionary for String & Array extention
  # @return [self]
  def as_dictionary
    String.hgnc = self
  end
  # Return the statistics hash
  # @return [Hash]
  # @example
  #   Bioinfo::Databases::HGNC.new("test_hgnc_dataset.txt").stat
  #   # => {"Gene Symbol"=>24, "Entrez ID"=>9, "Refseq ID"=>13, "Uniprot ID"=>9, "Ensembl ID"=>9}
  def stat
    @stat = {}
    IDENTIFIERS.each_key do |id|
      id == :hgncid ? @stat[id] = @hgncid2symbol.size : @stat[id] = instance_variable_get("@" + id.to_s + "2hgncid").size
    end
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

  private
  
  # Try to rescue a gene symbol
  # @param [String] symbol Gene symbol
  # @param [Symbol] method :auto or :manual
  # @param [Boolean] isPreview When set to true, neither outputing warnings nor modifying rescue history
  # @return [String] "" if rescue failed
  def rescue_symbol(symbol, method = @@rescue_method, isPreview = false)
    case method
    when :auto
      auto_rescue = ""
      if @symbol2hgncid[symbol.upcase]
        auto_rescue = symbol.upcase
      elsif @symbol2hgncid[symbol.gsub('-','')]
        auto_rescue = symbol.gsub('-','')
      elsif @symbol2hgncid[symbol.upcase.gsub('-','')]
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
        unless (manual_rescue = gets.chomp) == "" || @symbol2hgncid[manual_rescue]
          puts "Failed to recognize \"#{manual_rescue}\""
          next
        end
        @@rescue_history[symbol] = manual_rescue unless isPreview
        File.open(@@rescue_history_filename, "a").print(symbol, "\t", manual_rescue, "\n") unless isPreview
        return manual_rescue
      end
    end
  end
  # Load in the hgnc table from IO
  # @param [#gets, #each] fin Typically a File or IO
  def load_hgnc_table(fin)
    # Headline
    names = fin.gets.chomp.split("\t")
    index2identifier = {}
    index_hgncid = nil
    IDENTIFIERS.each_pair do |identifer, name|
      if identifer == :hgncid
        index_hgncid = names.index(name)
      elsif name.is_a?(String)
        index2identifier[names.index(name)] = identifer if names.index(name)
      else
        name.each_with_index { |n, i| index2identifier[names.index(n)] =  (i == 0 ? identifer : identifer.to_s) if names.index(n) }
      end
    end
    
    # Dynamically bulid a line processor
    process_one_line = index2identifier.collect { |index, identifer|
      if identifer.is_a?(Symbol) # Single
      %{
        unless column[#{index}] == "" || column[#{index}] == "-"
          @#{identifer}2hgncid[column[#{index}]] = column[#{index_hgncid}]
          @hgncid2#{identifer}[column[#{index_hgncid}]] = column[#{index}]
        end }
      else # Array
      %{ 
        column[#{index}].split(", ").each { |id| @#{identifer}2hgncid[id] = column[#{index_hgncid}] if @#{identifer}2hgncid[id].nil? } }
      end
    }.join

    # Content
    eval %{fin.each do |line|\n column = line.chomp.split("\\t")} + process_one_line + "end"
    return nil
  end

  #
  # Overwrite some methods to provide symbol rescue funtion
  # Use class_eval to ensure not documented by YARD
  #
  class_eval do
    def symbol2hgncid(symbol = nil)
      return @symbol2hgncid unless symbol
      begin
        @symbol2hgncid.fetch(symbol)
      rescue KeyError
        return "" if symbol == "" || !@@rescue_symbol
        @@rescue_history[symbol] ? @symbol2hgncid[@@rescue_history[symbol]].to_s : @symbol2hgncid[rescue_symbol(symbol)].to_s
      end
    end
  end
  String.class_eval do
    def symbol2hgncid
      String.hgnc.symbol2hgncid(self) rescue raise "HGNC dictionary not given"
    end
    def symbol2hgncid!
      replace(String.hgnc.symbol2hgncid(self)) rescue raise "HGNC dictionary not given"
    end
  end
end

class String
  # Get the HGNC dictionary for convertion
  # @return [Bioinfo::Databases::HGNC]
  def self.hgnc
    @hgnc
  end
  # @overload hgnc=(obj)
  #   Set the HGNC dictionary for convertion
  #   @param [Bioinfo::Databases::HGNC] obj
  #   @return [Bioinfo::Databases::HGNC]
  # @overload hgnc=(nil)
  #   Deregister the HGNC dictionary
  #   @param [nil]
  #   @return [Bioinfo::Databases::HGNC] the previous value
  #
  # @raise ArgumentError Raised if neither HGNC object nor nil given
  def self.hgnc=(obj)
    if obj == nil
      @hgnc, obj = obj, @hgnc
      return obj
    else
      raise ArgumentError, "Not a HGNC object" unless obj.is_a?(Bioinfo::Databases::HGNC)
      @hgnc = obj
    end
  end
end

Bioinfo::Databases::HGNC.wd = File.expand_path("data/hgnc", Bioinfo.wd)
Bioinfo::Databases::HGNC.rescue_symbol = true
Bioinfo::Databases::HGNC.rescue_method = :auto
