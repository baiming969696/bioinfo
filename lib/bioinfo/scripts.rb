#!/usr/bin/env ruby
# encoding: UTF-8

# Namespace of all scripts
module Bioinfo::Scripts
  Bioinfo::Utility.set_autoloaders(
    {
      Script:"bioinfo/scripts/script",
      MimMiner:"bioinfo/scripts/mimminer",
      Cipher:"bioinfo/scripts/cipher",
    }, 
    self
  )
end
