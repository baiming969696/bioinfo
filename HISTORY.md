History
===============

### 0.0.2 2013-09-02
* 1 major enhancement
  * Add Bioinfo::Utility.request for http requests
  * TODO: Add Bioinfo::Database::HGNC
* 1 minor enhancement
  * Optimized the initialization of Bioinfo and got rid of ./_version.rb

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
