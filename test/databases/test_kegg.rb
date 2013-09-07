#!/usr/bin/env ruby
# encoding: UTF-8
require 'test/unit'
require 'shoulda-context'
require 'bioinfo'

class Bioinfo_Databases_KEGG_Test < Test::Unit::TestCase
  context "KEGG" do
    should "raise error if given pathway not exists" do
      assert_raise(ArgumentError) { Bioinfo::Databases::KEGG.get_pathway("00000") }
    end
    should "download KGMLs" do
      filename = Bioinfo::Databases::KEGG.path_to("hsa05010.xml")
      unless FileTest.exist?(filename)
        kegg = Bioinfo::Databases::KEGG.get_pathway("05010")
        assert(FileTest.exist?(filename))
      end
    end

    context "instance" do
      should "load KGMLs and create Pathway objects" do
        kegg = Bioinfo::Databases::KEGG.new("05010")
        assert(kegg.pathway["hsa05010"])
      end
      should "have more pathways if extended (in most cases)" do
        kegg = Bioinfo::Databases::KEGG.new("05010")
        before = kegg.pathway.size
        kegg.extend_to_associated
        assert(kegg.pathway.size > before)
      end
    end
  end
end
