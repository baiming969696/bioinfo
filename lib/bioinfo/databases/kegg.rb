#!/usr/bin/env ruby
# encoding: UTF-8
require 'rexml/document'

# KEGG class is designed to build ppi networks based on KEGG pathways.
#
# == Mechanism
# Download and analyze KGML files of pathways. Run time depends on connection 
# status and the number of pathways you give.
#
# == Example Usage
# To load single pathway, using class method is better than create an object.
#   # bad
#   Bioinfo::Databases::KEGG.new("05010") # => KEGG object
#   # good
#   Bioinfo::Databases::KEGG.get_pathway("hsa05010") # => Pathway object
#
# Load a list of pathways in one KEGG object
#   pathway_list = ["hsa00010", "hsa00020", ...]
#   Bioinfo::Databases::KEGG.new(pathway_list)
#
# Load all pathways of hsa and merge into one huge network
#   Bioinfo::Databases::KEGG.new(nil, 'hsa').merge.network
#   # => [ [gene1 ,gene2], ...]
#
# == About KEGG
# KEGG is a database resource for understanding high-level functions and 
# utilities of the biological system, such as the cell, the organism and the 
# ecosystem, from molecular-level information, especially large-scale 
# molecular datasets generated by genome sequencing and other high-throughput 
# experimental technologies.
#
# == Reference
# {http://www.genome.jp/kegg/ KEGG website}
#
# {http://www.ncbi.nlm.nih.gov/pubmed/22080510 Kanehisa, M., Goto, S., 
# Sato, Y., Furumichi, M., and Tanabe, M.; KEGG for integration and 
# interpretation of large-scale molecular datasets. Nucleic Acids Res. 40, 
# D109-D114 (2012).}
#
# {http://www.ncbi.nlm.nih.gov/pubmed/10592173 Kanehisa, M. and Goto, S.; 
# KEGG: Kyoto Encyclopedia of Genes and Genomes. Nucleic Acids Res. 28, 
# 27-30 (2000).}
class Bioinfo::Databases::KEGG
  # Struct for storing pathway information
  # @attr [String] id KEGG pathway id
  # @attr [Array] gene An *Entrez* *ID* list of genes
  # @attr [Array] network A list of edges between Pathway.gene
  # @attr [Array] associated_pathway A list of KEGG pathway ids
  Pathway = Struct.new(:id, :gene, :network, :associated_pathway) do
    def inspect
      "#<Bioinfo::Databases::KEGG::Pathway @id=#{self.id.inspect}>"
    end
    def to_s
      inspect
    end
  end

  extend Bioinfo::Modules::WorkingDir

  # Current version of KEGG
  VERSION = "0.1.0"
  # KEGG default organism - Homo sapiens (human)
  DEFAULT_ORGANISM = "hsa"
  # KEGG identifer patterns
  PATTERNS = {
    pathway:{
      official:/^[a-z]{3}\d{5}$/, 
      alternative:/^\d{5}$/ 
    },
    organism:/^[a-z]{3}$/,
  }
  # Downloading url
  URLS = {
    pathway_kgml:->(pathway_id){ "http://rest.kegg.jp/get/#{pathway_id}/kgml" },
    pathway_list:->(organism){ "http://rest.kegg.jp/list/pathway/#{organism}" },
  }

  # Get the pathways
  # @return [Hash] Pathway ids as keys
  attr_reader :pathway

  # Validate the pathway_id
  # @param [String] pathway_id
  # @param [String] organism
  # @return [String] Valid pathway ID, nil returned if unable to validate)
  # @raise ArgumentError Raised if organism invalid
  def self.validate_pathway_id(pathway_id, organism = DEFAULT_ORGANISM)
    raise ArgumentError, "Invalid organism" unless organism =~ PATTERNS[:organism]
    case pathway_id
    when PATTERNS[:pathway][:official]    then pathway_id
    when PATTERNS[:pathway][:alternative] then organism + pathway_id
    else nil
    end
  end
  # Check if pathway_id is a valid KEGG pathway id
  # @return [Boolean]
  def self.valid_pathway_id?(pathway_id)
    pathway_id =~ PATTERNS[:pathway][:official] ? true : false
  end
  # Get the list of all pathways of given organism
  # @param [String] organism
  # @return [Array]
  # @raise ArgumentError
  def self.get_pathway_list(organism)
    raise ArgumentError, "Invalid organism" unless organism =~ PATTERNS[:organism]
    filepath = path_to("list_#{organism}.txt")
    unless File.exists?(filepath)
      content = Bioinfo::Utility.request(URLS[:pathway_list].call(organism))
      File.open(filepath, 'w').puts content
    end
    list = []
    pattern = Regexp.new("^path:(#{organism}" + $1 + ')') if /\^(.+)\$/ =~ PATTERNS[:pathway][:alternative].inspect
    File.open(filepath).each { |line| list<<$1 if line.match(pattern) }
    return list
  end
  # Get the pathway specified by pathway_id
  # @param [String] pathway_id KEGG pathway id (using {DEFAULT_ORGANISM} if not specified)
  # @return [Pathway]
  # @raise Bioinfo::Utility::HTTPError Raised if invalid KEGG pathway id given or broken network connection
  def self.get_pathway(pathway_id)
    raise ArgumentError, "Invalid pathway_id" unless pathway_id = validate_pathway_id(pathway_id)

    filepath = path_to("#{pathway_id}.xml")
    unless File.exist?(filepath)
      begin
        Bioinfo.log.info("KEGG") { "Downloading the KGML of pathway #{pathway_id.inspect} from KEGG" }
        content = Bioinfo::Utility.request(URLS[:pathway_kgml].call(pathway_id))
        File.open(filepath, 'w').puts content
      rescue Bioinfo::Utility::HTTPError => e
        raise ArgumentError, "Given pathway #{pathway_id.inspect} not exists in KEGG" if e.code == 400 || e.code == 404
        raise e
      end
    end
    doc = REXML::Document.new(File.open(filepath).readlines.join)
    pathway = Pathway.new(pathway_id, [], [], [])

    # Get entry list
    entry_list = {}
    doc.elements.each("pathway/entry") do |entry|
      entry_id = entry.attributes['id']
      case entry.attributes['type']
      when 'gene'
        entry_list[entry_id] = {:type => :gene, :gene => []}
        entry.attributes['name'].scan(/hsa:(\d+)/) { |match| entry_list[entry_id][:gene]<<match[0] }
      when 'group'
        entry_list[entry_id] = {:type => :group, :component => [], :gene => []}
        entry.elements.each("component") do |component|
          entry_list[entry_id][:component]<<component.attributes['id']
        end
      when 'map'
        entry_list[entry_id] = {:type => :map, :gene => []}
        /path:(?<map>\w+)/ =~ entry.attributes['name']
        entry_list[entry_id][:map] = map
        pathway.associated_pathway<<map
      end
    end
    # Build pathway.gene & process group entry
    entry_list.each_value do |hash|
      case hash[:type]
      when :gene
        hash[:gene].each { |gene| pathway.gene<<gene }
      when :group
        # Link genes between entries
        0.upto(hash[:component].size-2) do |i|
          (i+1).upto(hash[:component].size-1) do |j|
            entry_list[hash[:component][i]][:gene].each do |genei|
              entry_list[hash[:component][j]][:gene].each do |genej|
                pathway.network<<[genei, genej]<<[genej, genei]
              end
            end
          end
        end
        # Build gene list for the group
        hash[:component].each { |entry_id| hash[:gene] += entry_list[entry_id][:gene] }
        hash[:gene].uniq!
      end
    end
    # Get entry relation list
    entry_relation_list = []
    doc.elements.each("pathway/relation") do |relation|
      next unless entry_list.has_key?(relation.attributes['entry1'])
      next unless entry_list.has_key?(relation.attributes['entry2'])

      # One-direction or two-direction
      relation.elements.each('subtype') do |subtype|
        case subtype.attributes['value']
        when '-->', '--|', '..>', '+p', '-p', '+g', '+u', '+m'
          entry_relation_list<<[relation.attributes['entry1'], relation.attributes['entry2']]
          break
        when '...', '---'
          entry_relation_list<<[relation.attributes['entry1'], relation.attributes['entry2']]
          entry_relation_list<<[relation.attributes['entry2'], relation.attributes['entry1']]
          break
        end
      end
    end
    # Load relation into :network
    entry_relation_list.each do |pair|
      entry_list[pair[0]][:gene].each do |gene1|
        entry_list[pair[1]][:gene].each do |gene2|
          pathway.network.push [gene1, gene2]
        end
      end
    end
    return pathway
  end

  # Create a new KEGG object
  # @overload initialize(pathway_id, organism = DEFAULT_ORGANISM)
  #   Load the pathway specified by pathway_id
  #   @param [String] pathway_id KEGG pathway ID
  #   @param [String] organism Default organism for unspecific pathway number
  # @overload initialize(pathway_ids, organism = DEFAULT_ORGANISM)
  #   Load pathways specified by pathway_ids
  #   @param [Array] pathway_ids KEGG pathway IDs
  #   @param [String] organism Default organism for unspecific pathway number
  # @overload initialize(nil, organism = DEFAULT_ORGANISM)
  #   Load all pathways of the specified organism
  #   @param [nil]
  #   @param [String] organism Default organism for unspecific pathway number
  def initialize(pathway_id = nil, organism = DEFAULT_ORGANISM)
    pathway_id = self.class.get_pathway_list(organism) unless pathway_id
    pathway_id = [pathway_id] unless pathway_id.respond_to?(:each)
    pathway_ids = []
    pathway_id.each do |id|
      valid_id = self.class.validate_pathway_id(id, organism) rescue nil
      valid_id ? pathway_ids<<valid_id : Bioinfo.log.warn("KEGG") { "Invalide pathway id #{id.inspect} discarded" }
    end

    Bioinfo.log.debug("KEGG") { "Start to load pathways: #{pathway_ids.inspect}" }
    @pathway = {}
    pathway_ids.each { |id| @pathway[id] = self.class.get_pathway(id) }
  end
  # Extend to associated pathways
  # @return [self]
  # REVIEW: really extended?
  def extend_to_associated
    pathway_ids = []
    @pathway.each_value { |pathway| pathway_ids |= pathway.associated_pathway }
    (pathway_ids - @pathway.keys).each { |id| @pathway[id] = self.class.get_pathway(id) }
    return self
  end
  # Merge pathways into one named :merged
  # @return [Pathway]
  def merge
    merged = Pathway.new(:merged, [], [], [])
    Bioinfo.log.info("KEGG") { "Generating the merged network for #{self.inspect}" }
    @pathway.each_value do |pathway|
      next if pathway.id.is_a?(Symbol)
      merged.gene |= pathway.gene
      merged.network |= pathway.network
    end
    @pathway[:merged] = merged
  end
  # @private
  def inspect
    "#<Bioinfo::Databases::KEGG pathway.keys=#{@pathway.keys.inspect}>"
  end
  # @private
  def to_s
    inspect
  end
end

Bioinfo::Databases::KEGG.wd = Bioinfo.path_to("data/kegg")
