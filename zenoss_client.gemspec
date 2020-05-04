# -*- encoding: utf-8 -*-

lib = File.expand_path('lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'date'

Gem::Specification.new do |gem|
  gem.name = "zenoss_client"
  gem.version = File.open('VERSION').readline.chomp
  gem.date = Date.today.to_s
  gem.platform = Gem::Platform::RUBY
  gem.rubyforge_project  = nil

  gem.authors = ['Dan Wanek', 'Ben Miller', 'Marek Skrobacki', 'Taylor Etheredge']
  gem.email = ['dan.wanek@gmail.com', 'bjmllr@gmail.com', 'marek@skrobacki.uk', 'taylor.etheredge@gmail.com']
  gem.homepage = "http://github.com/RubyOpenSource/zenoss_client"

  gem.summary = "A wrapper around the Zenoss JSON and REST APIs"
  gem.license = 'GPL-3.0'
  gem.description = <<-EOF
    This is a wrapper around the Zenoss JSON and REST APIs. For the most things it
    should feel very familiar to zendmd, but there are some changes do to the merging
    of the JSON and REST APIs. Please read the API docs for Zenoss and the YARDDoc for
    this gem (rdoc.info).
  EOF

  gem.files = `git ls-files`.split(/\n/)
  gem.require_path = "lib"
  gem.rdoc_options = %w(-x test/ -x examples/)
  gem.extra_rdoc_files = %w(README.textile COPYING.txt)

  gem.required_ruby_version = '>= 2.0.0-p648'
  gem.add_runtime_dependency  'httpclient', '~> 2.0'
  gem.add_runtime_dependency  'tzinfo', '~> 2.0.2'
  gem.add_runtime_dependency  'json', '~> 2.3'

  gem.add_development_dependency('rake')
  gem.add_development_dependency('minitest')
  gem.add_development_dependency('vcr')
  gem.add_development_dependency('webmock')
end
