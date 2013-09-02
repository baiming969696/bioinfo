Bioinfo
=======

For bioinformaticians.


## Coding Style

Practically follow [ruby-style-guide](http://aidistan.github.io/ruby-style-guide/)
, a community-driven ruby coding style guide.

Following is the list of some __possible__ differences.

### Comments

* Write self-documenting code for developers.

* Write YARD document within the code to generate API docs and example usages.

	* Use (part of) these sections to describe a class or module

		* Overview (default) : briefly describe the purpose and the usage

		* Mechanism

		* Example Usage

		* Supplementary : such as the brief introduction of the database (this subtitle could be changed)

		* Reference

* Use these and only these comment annotations,

	* TODO: To note missing features or functionality that should be added at 
	a later date.

	* FIXME: To note broken code that needs to be fixed.

	* OPTIMIZE: To note slow or inefficient code that may cause performance 
	  problems.

	* HACK: To note code smells where questionable coding practices were used 
	  and should be refactored away.

	* REVIEW: To note anything that should be looked at to confirm it is
	  working as intended. For example: REVIEW: Are we sure this is how the 
	  client does X currently?

### Classes & Modules

* Define VERSION for each script or database class. And write the changes in 
  _HISTORY.md_

* Use this structure in module/class definitions

		class MyClass
		  # special handling, such as autoload, go first if has any
		  self.autoload(:Utility, "myclass/utility")

		  # extends and includes are the first most time
		  extend SomeModule
		  include AnotherModule

		  # constants are next
		  SOME_CONSTANT = 20

		  # afterwards we have attribute macros
		  attr_reader :name

		  # followed by other macros (if any)
		  validates :name

		  # public class methods are next in line
		  def self.some_method
		  end

		  # followed by public instance methods
		  def some_method
		  end

		  # protected and private methods are grouped near the end
		  protected

		  def some_protected_method
		  end

		  private

		  def some_private_method
		  end
		end


## Test Style

Having no explicit map of our gem, we just add new Script or Module when we 
need it, which make the popular test suite _RSepc_ doesn't suit our need 
quite well.

In such case, we choose to write our tests with the std-lib __test/unit__ and 
__shoulda-context__ gem.


## License

Copyright 2013 Aidi Stan under the MIT license.
