# frozen_string_literal: true

require_relative "lib/cocoapods/version"

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-play"
  spec.version       = Cocoapods::Play::VERSION
  spec.authors       = ["LY"]
  spec.email         = ["xxxx@163.com"]

  spec.summary       = " play 命令"
  spec.description   = "play 命令"
  spec.homepage      = "http://www.baidu.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["lib/**/*.rb"] + %w{ README.md LICENSE.txt }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_dependency 'cocoapods', '~> 1.10'
end
