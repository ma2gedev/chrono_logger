# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chrono_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "chrono_logger"
  spec.version       = ChronoLogger::VERSION
  spec.authors       = ["Takayuki Matsubara"]
  spec.email         = ["takayuki.1229@gmail.com"]
  spec.summary       = %q{A lock-free logger with timebased file rotation.}
  spec.description   = %q{A lock-free logger with timebased file rotation.}
  spec.homepage      = "https://github.com/ma2gedev/chrono_logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", ">= 0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "delorean"
  spec.add_development_dependency "parallel"
  spec.add_development_dependency "coveralls"

  # for performance check
  spec.add_development_dependency "mono_logger"
  spec.add_development_dependency "log4r"
end
