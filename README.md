Bioinfo
=======

For bioinformaticians.

## Coding Style

Practically follow [ruby-style-guide](http://aidistan.github.io/ruby-style-guide/)
, a community-driven ruby coding style guide.

### Comment Annotations

* TODO: To note missing features or functionality that should be added at a 
  later date.

* FIXME: To note broken code that needs to be fixed.

* OPTIMIZE: To note slow or inefficient code that may cause performance 
  problems.

* HACK: To note code smells where questionable coding practices were used 
  and should be refactored away.

* REVIEW: To note anything that should be looked at to confirm it is working 
  as intended. For example: REVIEW: Are we sure this is how the client does 
  X currently?


## Test Style

Having no explicit map of our gem, we just add new Script or Module when we 
need it, which make the popular test suite _RSepc_ doesn't suit our need 
quite well.

In such case, we choose to write our tests with the std-lib __test/unit__ and 
__shoulda-context__ gem.


## License

Copyright 2013 Aidi Stan under the MIT license.
