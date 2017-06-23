require 'erb'
require 'pry-byebug'
require_relative 'game'

class Racker
  attr_accessor :attempts
  PATH = "file_session/"

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session["init"] = true
    @session_id = @request.session['session_id']
    @file_name = File.expand_path("../../#{PATH}#{@session_id}", __FILE__)
    init_session
  end

  def init_session

    binding.pry
    if File.file? @file_name
      @game_racker = YAML.load_file(@file_name)
    else
      @game_racker = GameRacker.new(@request['user_name'])
    end
  end

  def response
    case @request.path
    when '/' then  Rack::Response.new(render_with_layout('index.html.erb'))
    when '/send_answer' then answer
    when '/game' then  go
    when '/game_over' then  lost
    when '/win' then  win
    else Rack::Response.new('Not Found', 404)
    end
  end

  def lost
    save_score
    Rack::Response.new(render_with_layout('game_over.html.erb'))
  end

  def answer
    return lost if @game_racker.attempts<1
    @game_racker.answer(@request.params['answer'])
    return win if @game_racker.answer_list.first[1] == '++++'
    go
  end

  def win
    save_score
    Rack::Response.new(render_with_layout('win.html.erb'))
  end

  def go
    @game_racker.save_object_game(@game_racker,@file_name)
    Rack::Response.new(render_with_layout('game.html.erb'))
  end

  def save_score
    @game_racker.save_score
    FileUtils.rm(@file_name)
  end

  def render_with_layout(template, context = self)
    template = File.expand_path("../../views/#{template}", __FILE__)
    render_layout do
      ERB.new(File.read(template)).result(binding)
    end
  end

  def render_layout
    layout = File.read(File.expand_path("../../views/header.html.erb", __FILE__))
    ERB.new(layout).result(binding)
  end

end
