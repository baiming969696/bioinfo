#!/usr/bin/env ruby
# encoding: UTF-8
require 'test/unit'
require 'shoulda-context'
require 'bioinfo'

# Keep screen clear
Bioinfo.log.screen_logger.level = Logger::UNKNOWN

class Bioinfo_Databases_HGNC_Test < Test::Unit::TestCase
  setup do
    @hgnc  = Bioinfo::Databases::HGNC.new(File.expand_path("data/samples/hgnc_sample.txt", Bioinfo.wd))
  end

  context "HGNC object" do
    should "convert identifiers in Hash way" do
      assert_equal("41", @hgnc.symbol2entrez["ASIC1"])
      assert_equal("RGS5", @hgnc.entrez2symbol["8490"])
      assert_equal("9028", @hgnc.refseq2entrez["NM_003961"])
      assert_equal("8787", @hgnc.uniprot2entrez["O75916"])
      assert_equal("6006", @hgnc.ensembl2entrez["ENSG00000188672"])
    end
    should "convert identifiers in method way" do
      assert_equal("41", @hgnc.symbol2entrez("ASIC1"))
      assert_equal("RGS5", @hgnc.entrez2symbol("8490"))
      assert_equal("9028", @hgnc.refseq2entrez("NM_003961"))
      assert_equal("8787", @hgnc.uniprot2entrez("O75916"))
      assert_equal("6006", @hgnc.ensembl2entrez("ENSG00000188672"))
    end
    should "try to resuce unrecognized symbols" do
      assert_equal("41", @hgnc.symbol2entrez("ASIC-1"))
      assert_equal("41", @hgnc.symbol2entrez("Asic1"))
      assert_equal("41", @hgnc.symbol2entrez("Asic-1"))
    end
  end

  context "With HGNC module," do
    teardown do
      String.hgnc = nil
    end
    
    context "String object" do
      should "need a dictionary" do
        assert_raise(RuntimeError) { "".symbol2entrez }
        @hgnc.as_dictionary
        assert_nothing_raised { "".symbol2entrez }
      end
      should "convert identifiers" do
        @hgnc.as_dictionary
        assert_equal("41", "ASIC1".symbol2entrez)
        assert_equal("RGS5", "8490".entrez2symbol)
        assert_equal("9028", "NM_003961".refseq2entrez)
        assert_equal("8787", "O75916".uniprot2entrez)
        assert_equal("6006", "ENSG00000188672".ensembl2entrez)
        assert_equal("", "".symbol2entrez)
      end
    end

    context "Array object" do
      should "convert identifiers" do
        @hgnc.as_dictionary
        assert_raise(ArgumentError) { ["",1].symbol2entrez }
        assert_equal(["ASIC1", "RGS4"], ["41", "5999"].entrez2symbol)
      end
    end
  end
end
