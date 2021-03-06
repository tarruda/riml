require File.expand_path("../version", __FILE__)

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'riml'
  s.version     = Riml::VERSION.join('.')
  s.summary     = 'Riml is a language that compiles into VimL'
  s.description = <<-desc
  Riml is a subset of VimL with some added features, and it compiles to plain
  Vim script. Some of the added features include classes, string interpolation,
  heredocs, default case-sensitive string comparison and default arguments in
  functions. Give it a try!
  desc

  s.required_ruby_version  = '>= 1.8.7'
  s.license = 'MIT'

  s.author = 'Luke Gruber'
  s.email = 'luke.gru@gmail.com'
  s.homepage = 'https://github.com/luke-gru/riml'
  s.bindir = 'bin'
  s.require_path = 'lib'
  s.executables = ['riml']
  s.files = Dir['README.md', 'LICENSE', 'version.rb', 'lib/**/*', 'Rakefile',
                'CONTRIBUTING', 'CHANGELOG' 'Gemfile']

  s.add_development_dependency('racc', '1.4.9')
  s.add_development_dependency('rake', '~> 10.1.0')
  s.add_development_dependency('bundler', '~> 1.3')
  s.add_development_dependency('minitest', '>= 5.0.8')
  s.add_development_dependency('mocha', '~> 0.14.0')
end
