History
===============

### 0.0.4 2013-
* 1 minor enhancement
	* Moved Bioinfo::Script to Bioinfo::Scripts::Script

### 0.0.3 2013-09-24
* 4 major enhacement
	* Bumped Bioinfo::Database::HGNC version to 0.2.0
		* Used metaprogramming in Bioinfo::Database::HGNC
		* Removd bioinfo/databases/hgnc/*
	* Added Bioinfo::Databases::Cipher
	* Added Bioinfo::Databases::KEGG
	* Added Bioinfo::Databases::OMIM

### 0.0.2 2013-09-03
* 2 major enhancement
	* Added Bioinfo::Utility.request for http requests
	* Added Bioinfo::Database::HGNC
* 2 minor enhancement
	* Optimized the initialization of Bioinfo and got rid of ./_version.rb
	* Improved YARD documents

### 0.0.1 2013-09-01
* 2 major enhancement
	* Determined the hierarchy of lib files of Bioinfo gem
		* Bioinfo namespace
			* Utility
			* Logger
			* and other classes
		* Bioinfo::Modules namespace
		* Bioinfo::Databases namespace
		* Bioinfo::Scripts namespace
	* Determined the hierarchy of Bioinfo gem
		* bin
		* data as the repository of datas
		* lib
		* log
		* test
		* tmp as the temporary directory of scripts
* 1 minor enhancement
	* Added ./_version.rb to avoid requiring the whole gem and generating temporary files
