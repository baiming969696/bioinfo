#!/usr/bin/env ruby
# encoding: UTF-8

class Bioinfo::Databases::HGNC
  # Use self as the dictionary for String & Array extention
  # @return [self]
  def as_dictionary
    String.hgnc = self
  end
end

# Meta method used to extend String class
# @!visibility private
def hgnc_extends(*syms)
  syms.each do |sym|
    class_eval %{
      def #{sym}
        raise "HGNC dictionary not given" unless String.instance_variable_get(:@hgnc)
        String.hgnc.#{sym}(self)
      end
      def #{sym}!
        raise "HGNC dictionary not given" unless String.instance_variable_get(:@hgnc)
        replace(String.hgnc.#{sym}(self))
      end
    }
  end
end

class String
  # @!group Convertion Methods
  # @!method symbol2entrez
  #  @return [String]
  hgnc_extends :symbol2entrez
  # @!method entrez2symbol
  #  @return [String]
  hgnc_extends :entrez2symbol
  # @!method uniprot2entrez
  #  @return [String]
  hgnc_extends :uniprot2entrez
  # @!method entrez2uniprot
  #  @return [String]
  hgnc_extends :entrez2uniprot
  # @!method ensembl2entrez
  #  @return [String]
  hgnc_extends :ensembl2entrez
  # @!method entrez2ensembl
  #  @return [String]
  hgnc_extends :entrez2ensembl
  # @!method refseq2entrez
  #  @return [String]
  hgnc_extends :refseq2entrez
  # @!method entrez2refseq
  #  @return [String]
  hgnc_extends :entrez2refseq
  # @!endgroup

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
  #   @return [Bioinfo::Databases::HGNC] the previous dictionry
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

# Meta method used to extend Array class
# @!visibility private
def hgnc_extends(*syms)
  syms.each do |sym|
    class_eval %{
      def #{sym}
        self.collect do |item|
          raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array is not a String" unless item.is_a?(String)
        end
        self.collect { |item| item.#{sym} }
      end
      def #{sym}!
        self.collect do |item|
          raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array is not a String" unless item.is_a?(String)
        end
        self.collect! { |item| item.#{sym} }
      end
    }
  end
end

class Array
  # @!group Convertion Methods
  # @!method symbol2entrez
  #  @return [Array]
  hgnc_extends :symbol2entrez
  # @!method entrez2symbol
  #  @return [Array]
  hgnc_extends :entrez2symbol
  # @!method uniprot2entrez
  #  @return [Array]
  hgnc_extends :uniprot2entrez
  # @!method entrez2uniprot
  #  @return [Array]
  hgnc_extends :entrez2uniprot
  # @!method ensembl2entrez
  #  @return [Array]
  hgnc_extends :ensembl2entrez
  # @!method entrez2ensembl
  #  @return [Array]
  hgnc_extends :entrez2ensembl
  # @!method refseq2entrez
  #  @return [Array]
  hgnc_extends :refseq2entrez
  # @!method entrez2refseq
  #  @return [Array]
  hgnc_extends :entrez2refseq
  # @!endgroup
end

undef :hgnc_extends
