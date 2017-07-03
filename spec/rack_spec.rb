require "test/unit"
require "rack/test"
require 'pry-byebug'

OUTER_APP = Rack::Builder.parse_file("config.ru").first
SESSION_ID="2864943336b8ef524f84ff7a790a35861083b3ff901052c5e98d074bbc1056b0"

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def test_root_url
    post "/", { user_name: "sasha" }
    assert last_response.ok?
    assert_equal 200, last_response.status
  end

  def test_get_404
    get "/dfsgsgds"
    assert_equal 404, last_response.status
  end

  def test_post_404
    post "/dfsgsgds"
    assert_equal 404, last_response.status
  end

  def test_new_game
    post "/game", {user_name: "sasha"}
    assert last_response.ok?
    assert_equal 200, last_response.status
  end

  def test_send_answer
    post "/send_answer", {user_name: "sasha", answer: "1234"}
    assert last_response.ok?
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'You answers'
  end

  def test_send_answer_hint
    post "/send_answer", {user_name: "sasha", answer: "hint"}
    assert last_response.ok?
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'hint'
  end

  def test_lost
    get "/game_over", {}, { session_id: SESSION_ID, "rack.session" => { session_id: SESSION_ID } }
    assert last_response.ok?
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>Game Over</h1>'
  end

  def test_win
    get "/win", {}, { session_id: SESSION_ID, "rack.session" => { session_id: SESSION_ID } }
    assert last_response.ok?
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>You winner</h1>'
  end

  def test_score
    get "/score", {}, { session_id: SESSION_ID, "rack.session" => { session_id: SESSION_ID } }
    assert last_response.ok?
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<tr><td>Date</td><td>Name</td><td>Results</td></tr>'
  end
end

