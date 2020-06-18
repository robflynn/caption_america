require "rubygems"
require "bundler/setup"

require "minitest/autorun"
require "minitest/pride"
require "caption_america"

class MiniTest::Spec
  def fixture_path(path)
    File.join(File.dirname(__FILE__), 'fixtures', path)
  end

  def fixture(path)
    File.open(fixture_path(path))
  end
end