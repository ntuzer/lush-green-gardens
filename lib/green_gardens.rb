require_relative 'font'
require 'date'
require 'byebug'

class LushGreenGardens

  WHITE = 0
  LIGHT_GREEN = 1
  GREEN = 2
  DARK_GREEN = 3
  FERTILIZER = true

  attr_accessor :word, :current_letter, :latest_run, :current_day

  def initialize(word="REWEL")
    @original_word = word
    @word = word
    @current_letter= ""
    @latest_run = nil
    @current_day = Date.today
    @current_index = nil
    @num = 0

    load_data()
    scheduler()
  end

  def scheduler()
    #once a day call water_my_garden
    # while true
      @num = 0
      grow_baby_grow()
      # sleep(86400 - @num)
    # end
  end

  def grow_baby_grow()
    return if initial_run?()
    remove_missed_days = (@current_day - @latest_run).to_i - 1
    if remove_missed_days < 7
      make_up_time(remove_missed_days)
    else
      # restart word
      restart()
      water_my_garden(FERTILIZER)
      return
    end
    water_my_garden()
  end

  def initial_run?()
    if @latest_run.nil?
      @current_day.monday? ? water_my_garden() : water_my_garden(FERTILIZER)
      return true
    end
    false
  end

  def restart()
    @word = @original_word
    @current_letter= nil
    @latest_run = nil
  end

  def water_my_garden(fertilizer=false)
    if fertilizer
      green_square(GREEN)
    else
      green_square()
      @latest_run = @current_day
      save_context()
    end
  end

  def make_up_time(days)
    days.times { update_current_letter() }
  end

  def green_square(color = nil)
    # num_of_commits returns a random number and updates the current letter
    color = update_current_letter() if color.nil?
    num = num_of_commits(color)
    make_commits(num)
  end

  def load_data()
    current_word = File.readlines('lib/current_word.txt')[0]
    current_letter = File.readlines('lib/current_letter.txt')[0]
    current_index = File.readlines('lib/current_index.txt')[0]
    latest_run = File.readlines('lib/last_run_day.txt')[0]
    @current_index = current_index.to_i
    if latest_run.nil?
      @latest_run = latest_run
    else
      date = latest_run.split("-")
      debugger
      @latest_run = Date.new(date[0].to_i, date[1].to_i, date[2].to_i)
    end

    current_letter.instance_of?(Array) ? @current_letter = current_letter : @current_letter = next_letter()
    current_word.instance_of?(String) ? @word = current_word : nil # @word = current_word #@word = get_word() --- need to find a way to maintain after word is finished
  end

  def next_letter() #private
    #get the next letter to be written
    letter = @word[0]
    @word = @word.slice(1..-1)
    @current_letter = FONT_LETTERS[letter.capitalize.to_sym].dup
  end

  def update_current_letter
    next_letter() if @current_letter.empty?
    @current_letter.shift
  end

  def num_of_commits(color)
    #return num of commits to make for the day
    case color
    when 0
      low, high = 0, 0
    when 1
      low, high = 1, 3
    when 2
      low, high = 5, 10
    when 3
      low, high = 15, 20
    end

    rand(low..high)
  end

  def save_context()
    original_word = File.open('lib/original_word.txt','w')
    original_word.write(@original_word)
    original_word.close

    current_letter = File.open('lib/current_letter.txt','w')
    current_letter.write(@current_letter)
    current_letter.close

    current_word = File.open('lib/current_word.txt','w')
    current_word.write(@word)
    current_word.close

    current_index = File.open('lib/current_index.txt','w')
    current_index.write(@current_index)
    current_index.close

    last_run = File.open('lib/last_run_day.txt','w')
    last_run.write(Date.today)
    last_run.close
  end

  def load_text() #private to file_writer
    lorem = File.readlines('lib/lorem.txt')
    words = lorem[0].chomp.split(" ") #length = 579
  end

  def output_words(new_word) #private to file_writer
    output = File.open("lib/output.txt", "a")
    output.write(new_word)
    output.close
  end

  def file_writer() #private to make_commits
    words = load_text()
    @current_index = (@current_index + 1) % 579
    new_word = words[@current_index] + " "
    output_words(new_word)
  end

  def make_commits(num)
    num.times do
      @num += 60
      file_writer()
      message = 'Add text to file'
      system("git add .")
      system("git commit -m \"#{message}\"")
      system("git push origin master")
    end
  end
end
