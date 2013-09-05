#!/usr/bin/env ruby
# encoding: UTF-8
require 'test/unit'
require 'shoulda-context'
require 'bioinfo'

class Bioinfo_Databases_Cipher_Test < Test::Unit::TestCase
  context "Cipher object" do
    should "build gene tables" do
      cipher = Bioinfo::Databases::Cipher.new("137280")
      assert(cipher.genes["137280"].include?(["HIST1H2AB", 968, "0.052943"]))
    end
  end
end
