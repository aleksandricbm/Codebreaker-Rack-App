require 'codebreaker'

class GameRacker
  attr_accessor :attempts
  ATTEMPT_COUNT = 5

  def initialize(user_name)
      @game = Codebreaker::Game.new
      @game.start
      @result_answer = []
      @user_name = user_name
      @attempts = ATTEMPT_COUNT
  end

  def save_object_game(object,file_name)
    File.open(file_name, 'w') {|f| f.write(YAML.dump(object)) }
  end

  def answer(user_code)
    attempt
    @result_answer.push([user_code,@game.attempt(user_code)])
  end

  def attempt
    #binding.pry
    return @attempts -= @result_answer.count unless @result_answer.empty?
    ATTEMPT_COUNT
  end

  def answer_list
    @result_answer.reverse
  end

  def save_score
    File.open('score.yaml', 'a') {|f| f.write(YAML.dump("#{@user_name} : #{@result_answer}")) }
  end

end
