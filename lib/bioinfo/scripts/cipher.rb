#!/usr/bin/env ruby
# encoding: UTF-8

# {Bioinfo::Scripts::Cipher Bioinfo::Scripts::Cipher} is the underlying program
# to build and update {Bioinfo::Databases::Cipher::CIPHER_WEBSITE Cipher website}.
#
# == Mechanism
# Use Matlab to handle the heavy work. Please refer to the paper for details.
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
# @see Bioinfo::Databases::Cipher
# @todo Embed matlab codes if possible
class Bioinfo::Scripts::Cipher < Bioinfo::Scripts::Script
  # @!group Interfaces
  # Setup input files. Directly return the path of exist files or do anything 
  # to create these input files. Check what should be returned according to 
  # the example or view the source instead.
  # @return [Hash]
  # @example Check default return value
  #   p Bioinfo::Scripts::Cipher.new.setup_input_files
  # @example Overwrite
  #   def setup_input_files
  #     hash = super
  #     hash[:inner_protein_protein_interaction_edge] = "/home/aidistan/data/inner_ppi.txt"
  #     # ...
  #   end
  def setup_input_files
    {
      inter_gene_list:"",
      inter_disease_list:"",
      inner_protein_protein_interaction_edge:"",
      inner_disease_disease_similarity:"",
      inner_disease_gene_relation:"",
    }
  end
  # @!endgroup

  # Run this cipher instance
  def run
    File.expand_path("lib/bioinfo/scripts/cipher/samples/", Bioinfo::DEFAULT_WORKING_DIRECTORY)
  end
  # Create a new instance
  # @param [String] wd Working directory of this instance
  def initialize(wd = Bioinfo.path_to("tmp/cipher/" + Bioinfo::Utility.get_timestamp))
    super(wd)
  end
end
