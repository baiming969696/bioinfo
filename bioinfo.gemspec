# encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)
require 'rake'
require 'bioinfo'

Gem::Specification.new do |s|
  s.name        = "bioinfo"
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Ruby lib for bioinformatics"
  s.description = "Useful scripts for bioinformaticians."

  s.version     = Bioinfo::VERSION
  s.license     = 'MIT'

  s.authors     = ["Aidi Stan"]
  s.email       = ["aidistan@live.cn"]
  s.homepage    = "http://aidistan.github.io/bioinfo/"

  s.files         = FileList['lib/**/*', 'test/**/*', '.yardopts', 'rakefile', 'LICENSE', '*.md', ].to_a
  s.require_paths = ["lib"]
  s.test_files    = FileList['test/**/*'].to_a

  s.add_development_dependency "yard", ">= 0.8.6"
  s.add_development_dependency "shoulda-context", ">= 1.1.5" # for tests
end
