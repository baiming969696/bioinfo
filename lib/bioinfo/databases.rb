#!/usr/bin/env ruby
# encoding: UTF-8

# Namespace of all databases
module Bioinfo::Databases
  # Databases released by now
  DATABASES = {
    HGNC:"bioinfo/databases/hgnc",
    Cipher:"bioinfo/databases/cipher",
  }

  Bioinfo::Utility.set_autoloaders(DATABASES, self)
end
