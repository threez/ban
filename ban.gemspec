# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ban/version'

Gem::Specification.new do |spec|
  spec.name          = 'ban'
  spec.version       = Ban::VERSION
  spec.authors       = ['Vincent Landgraf']
  spec.email         = ['setcool@gmx.de']
  spec.description   = %q{A home control system based on firmata}
  spec.summary       = %q{
    Ban is a arduino firmware (based on firmata) that receives incoming remote
    control switch commands, infrared commands, door open/close signaling and
    can send out remote control commands also. Ban distributes all this
    information over a websocket.
  }
  spec.homepage      = 'https://github.com/threez/ban'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'

  spec.add_runtime_dependency 'eventmachine'
  spec.add_runtime_dependency 'arduino_firmata'
  spec.add_runtime_dependency 'thor'
  spec.add_runtime_dependency 'em-websocket'
end
