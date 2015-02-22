# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ddeployer/version'

Gem::Specification.new do |spec|
  spec.name          = "ddeployer"
  spec.version       = Ddeployer::VERSION
  spec.authors       = ["rytmrt"]
  spec.email         = ["ryota.morita.3.8@gmail.com"]
  spec.summary       = %q{Gitから差分を抽出して、サーバーに適応するツール}
  spec.description   = %q{Gitから差分を抽出して、サーバーに適応するツールです。}
  spec.homepage      = "https://github.com/rytmrt/dDeployer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "thor"
  spec.add_dependency "net-sftp"
end
