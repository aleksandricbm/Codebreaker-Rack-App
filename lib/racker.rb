require 'erb'
require 'codebreaker'
require 'pry-byebug'
require 'rack-cache'
require 'dalli'

class Racker
  ATTEMPT_COUNT = 5

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @game = Codebreaker::Game.new
    @game.start
    @hint = @game.hint
    #File.open('./file.yml', 'w') {|f| f.write(YAML.dump(@game)) }
    m = YAML.load(File.read('./file.yml'))
    puts m.attempt('3122')
    binding.pry
  end

  def response
    case @request.path
    when '/' then Rack::Response.new(render('index.html.erb'))
    when '/send_answer'
      Rack::Response.new do |response|
        num= attempt.to_i-1
        return Rack::Response.new('Game Over', 404) if num<1

        @game.attempt(ui.user_number)
        response.set_cookie('hint', @hint)
        response.set_cookie('attempt', num)
#        binding.pry
        response.redirect('/')
#        binding.pry
      end
    else Rack::Response.new('Not Found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def attempt
    #binding.pry
    @request.cookies['attempt'] || ATTEMPT_COUNT
  end

  def word
    @request.cookies['word'] || 'Nothing'
  end

end
