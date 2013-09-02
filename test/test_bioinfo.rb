#!/usr/bin/env ruby
# encoding: UTF-8
require 'test/unit'
require 'shoulda-context'
require 'bioinfo'

class Bioinfo_Test < Test::Unit::TestCase
  context "Bioinfo module" do
    should "have such hierarchy" do
      assert_nothing_raised do
        # Module
        Bioinfo::Modules
        Bioinfo::Databases
        Bioinfo::Scripts
        # Class
        Bioinfo::Script
      end
      
      assert_raise NameError do
        Bioinfo::NoSuchConstant
      end
    end
  end

  context "Bioinfo::Utility" do
    should "get the source of a valid web page" do
      assert(Bioinfo::Utility.request("http://www.google.com.hk/")) # Sometimes get error 302, just ignore it
    end
    should "raise exception when encounter a unsuccessful request" do
      assert_raise(Bioinfo::Utility::HTTPError) { Bioinfo::Utility.request("http://www.google.com.hk/give_me_404") }
    end
  end

  context "Bioinfo::Logger" do
    should "respond to methods which std-lig Logger does" do
      assert(Bioinfo.log.level)
    end
    should "not respond to methods which std-lig Logger does not" do
      assert_raise(NoMethodError) { Bioinfo.log.definitely_no_this_method }
    end
  end
end
