#!/usr/bin/env ruby
# encoding: UTF-8

# Namespace of all modules
module Bioinfo::Modules
  Bioinfo::Utility.set_autoloaders(
    {
      WorkingDir:"bioinfo/modules/workingdir",
    }, 
    self
  )
end
