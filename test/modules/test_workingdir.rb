#!/usr/bin/env ruby
# encoding: UTF-8
require 'test/unit'
require 'shoulda-context'
require 'bioinfo'

class Bioinfo_Modules_WorkingDir_Test < Test::Unit::TestCase
  include Bioinfo::Modules::WorkingDir
  
  context "WorkingDirNeeded module" do
    should "change @wd if :wd= called" do
      assert_equal(self.wd, nil, "@wd not nil at first.")
      self.wd = File.dirname(__FILE__)
      assert_not_equal(self.wd, nil, "@wd not changed.")
    end

    should "create working directory if @wd not exist" do
      wd = File.expand_path("../tmp" ,__FILE__)
      assert(!Dir.exist?(wd), "Oops, \"#{wd}\" already exists.")
      self.wd = wd
      assert(Dir.exist?(wd), "Working directory not created.")
      Dir.delete(wd)
    end
  end
end
