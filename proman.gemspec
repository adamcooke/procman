$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'proc_man'

Gem::Specification.new do |s|
  s.name = 'procman'
  s.version = ProcMan::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = "A very very simple library for starting/stopping/restarting processes for a Ruby application"
  s.description = s.summary
  s.files = Dir["**/*"]
  s.bindir = "bin"
  s.executables << 'procman'
  s.require_path = 'lib'
  s.has_rdoc = false
  s.author = "Adam Cooke"
  s.email = "adam@atechmedia.com"
  s.homepage = "http://atechmedia.com"
end
