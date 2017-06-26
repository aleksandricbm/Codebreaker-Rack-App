require 'erb'
require 'pry-byebug'
require_relative 'game'
require 'time'
require 'date'

class Racker
  attr_accessor :attempts
  PATH = 'file_session/'.freeze

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session['init'] = true
    @session_id = @request.session['session_id']
    @file_name = File.expand_path("../../#{PATH}#{@session_id}", __FILE__)
    init_session
  end

  def init_session
    FileUtils.mkdir 'file_session' unless File.exist? PATH
    @game_racker = if File.file? @file_name
                     YAML.load_file(@file_name)
                   else
                     GameRacker.new(@request['user_name'])
                   end
  end

  def response
    case @request.path
    when '/' then new_game
    when '/send_answer' then answer
    when '/game' then go
    when '/game_over' then lost
    when '/win' then  win
    when '/score' then score
    else Rack::Response.new('Not Found', 404)
    end
  end

  private

  def new_game
    Rack::Response.new(render_with_layout('index.html.erb'))
  end

  def lost
    save_score
    Rack::Response.new(render_with_layout('game_over.html.erb'))
  end

  def answer
    #binding.pry
    return new_game if @request.params['answer'].nil?
    return go if @game_racker.hint < 1 && @request.params['answer'] == 'hint'
    return lost if @game_racker.attempts < 1
    @game_racker.answer(@request.params['answer'])
    return win if @game_racker.answer_list.first[1] == '++++'
    go
  end

  def score
    Rack::Response.new(render_with_layout('score.html.erb'))
  end

  def win
    save_score
    Rack::Response.new(render_with_layout('win.html.erb'))
  end

  def go
    @game_racker.save_object_game(@game_racker, @file_name)
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
    layout = File.read(File.expand_path('../../views/header.html.erb', __FILE__))
    ERB.new(layout).result(binding)
  end
end
