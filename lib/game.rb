require 'codebreaker'

class GameRacker
  attr_accessor :attempts
  ATTEMPT_COUNT = 5
  HINT = 2

  def initialize(user_name)
    @game = Codebreaker::Game.new
    @game.start
    @result_answer = []
    @user_name = user_name
    @attempts = ATTEMPT_COUNT
    @hint = HINT
  end

  def save_object_game(object, file_name)
    File.open(file_name, 'w') { |f| f.write(YAML.dump(object)) }
  end

  def answer(user_code)
    attempt
    return @attempts=0 if user_code == 'hint' && @hint < 1
    return @result_answer.push(['hint', @game.hint]) && @hint-=1 if user_code == 'hint'
    @result_answer.push([user_code, @game.attempt(user_code)])
  end

  def attempt
    return @attempts -= @result_answer.count unless @result_answer.empty?
    ATTEMPT_COUNT
  end

  def hint
    @hint
  end

  def answer_list
    @result_answer.reverse
  end

  def score
    YAML.load_file('score.yaml')
  end

  def save_score
    path_file = File.expand_path("../../score.yaml", __FILE__)

    file = if File.exist? path_file
             YAML.load_file(path_file)
           else
             {}
           end
    file[Time.now.strftime('%s')] = [@user_name, @result_answer]
    File.open(path_file, 'w') { |f| f.puts file.to_yaml }
  end
end
