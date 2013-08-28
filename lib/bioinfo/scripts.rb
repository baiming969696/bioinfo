#!/usr/bin/env ruby
# encoding: UTF-8

# Namespace of all scripts
module Bioinfo::Scripts
  # Scripts released by now
  SCRIPTS = {
  }

  Bioinfo.set_autoloaders(SCRIPTS, self)
end
