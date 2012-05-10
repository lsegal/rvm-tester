require File.dirname(__FILE__) + "/lib/rvm-tester"
Gem::Specification.new do |s|
  s.name          = "rvm-tester"
  s.summary       = "Runs tests across Ruby installations in RVM"
  s.version       = RVM::Tester::VERSION
  s.author        = "Loren Segal"
  s.email         = "lsegal@soen.ca"
  s.homepage      = "http://github.com/lsegal/rvm-tester"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{lib}/**/*") + ['README.md']
  s.require_paths = ['lib']
  s.add_dependency 'rake'
  s.add_dependency 'mob_spawner'
end