#!/usr/bin/env ruby
# encoding: UTF-8

# Namespace of all modules
module Bioinfo::Modules
  # Modules released by now
  MODULES = {
    WorkingDir:"bioinfo/modules/workingdir"
  }

  Bioinfo.set_autoloaders(MODULES, self)
end
