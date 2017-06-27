require 'erb'
require 'pry-byebug'
require_relative 'route'
require 'time'
require 'date'

class Racker
  attr_accessor :attempts

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @route = Route.new(env)
    @route.init_session
  end

  def response
    case @route.request.path
    when '/' then @route.new_game
    when '/send_answer' then @route.answer
    when '/game' then @route.go
    when '/game_over' then @route.lost
    when '/win' then  @route.win
    when '/score' then @route.score
    else @route.not_found
    end
  end
end
