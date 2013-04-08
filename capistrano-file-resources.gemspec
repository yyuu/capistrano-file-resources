# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano/configuration/resources/file_resources/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yamashita Yuu"]
  gem.email         = ["yamashita@geishatokyo.com"]
  gem.description   = %q{A sort of utilities which helps you to manage file resources.}
  gem.summary       = %q{A sort of utilities which helps you to manage file resources.}
  gem.homepage      = "https://github.com/yyuu/capistrano-file-resources"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "capistrano-file-resources"
  gem.require_paths = ["lib"]
  gem.version       = Capistrano::Configuration::Resources::FileResources::VERSION

  gem.add_dependency("capistrano")
  gem.add_dependency("mime-types")
end
