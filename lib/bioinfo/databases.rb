#!/usr/bin/env ruby
# encoding: UTF-8

# Namespace of all classes who interactive with databases
module Bioinfo::Databases
  Bioinfo::Utility.set_autoloaders(
    {
      HGNC:"bioinfo/databases/hgnc",
      Cipher:"bioinfo/databases/cipher",
      KEGG:"bioinfo/databases/kegg",
    },
    self
  )
end
