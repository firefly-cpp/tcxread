# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'tcxread'
  spec.version       = '0.1.0'
  spec.license       = 'MIT'
  spec.authors       = %w[firefly-cpp]
  spec.email         = ['iztok@iztok-jr-fister.eu']

  spec.summary       = 'tcx reader/parser in Ruby'
  spec.homepage      = 'https://github.com/firefly-cpp/tcxread'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/firefly-cpp/tcxread'
  spec.metadata['changelog_uri'] = 'https://github.com/firefly-cpp/tcxread'

  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ['lib']

  spec.add_dependency "nokogiri", "~> 1.11"

end
