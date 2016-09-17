require './app'
require 'test/unit'
require 'rack/test'

class CheckTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_hello_world
    get '/test'
    assert(last_response.ok?)
    assert_equal('we are good', last_response.body)
  end

  def test_it_says_hello_to_a_person
    get '/', :name => 'Simon'
    assert last_response.body.include?('Simon')
  end
end