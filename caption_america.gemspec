# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'caption_america/version'

Gem::Specification.new do |s|
  s.name        = 'caption_america'
  s.version     = CaptionAmerica::VERSION
  s.summary     = "Caption America"
  s.authors     = ["Rob Flynn"]
  s.files       = Dir['lib/**/*']

  s.homepage    = 'https://github.org/dcmp/caption_america'
  s.license     = 'NOT YET DECIDED'

  s.description = "Capion America"
  s.email       = 'rflynn@dcmp.org'

  s.required_ruby_version = '>= 2.1.2'

  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 12.3"
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'hex_string'
  s.add_development_dependency 'ruby-rtf'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'memoist'
  s.add_development_dependency 'rmagick'
  s.add_development_dependency 'bindata', '~> 1.8.0'
end