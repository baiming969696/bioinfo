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

  context "Bioinfo::Logger" do
    should "respond to methods which std-lig Logger does" do
      assert(Bioinfo.log.fatal?)
    end

    should "not respond to methods which std-lig Logger does not" do
      assert_raise NoMethodError do
        Bioinfo.log.definitely_no_this_method
      end        
    end
  end
end
