require_relative 'font'
require 'date'
require 'json'
require 'byebug'

class LushGreenGardens

  WHITE = 0
  LIGHT_GREEN = 1
  GREEN = 2
  DARK_GREEN = 3
  FERTILIZER = true

  attr_accessor :word, :current_letter, :latest_run, :current_day

  def initialize(word="&REWEL")
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
    # once a day call water_my_garden
    system("echo 'Lets get this garden growing!'")
    print_status()
    system("echo '----------------------------------------------------------'")

    while true
      if itsa_new_day?()
        print_status()

        grow_baby_grow()

        print_status()
      end
      system("echo 'Sleeping, check back in an hour.'")
      system("echo '----------------------------------------------------------'")
      sleep(3600)
    end

  end

  def print_status
    system("echo 'Current day: #{@current_day}'")
    system("echo 'Latest run: #{@latest_run}'")
  end

  def itsa_new_day?
    return true if @latest_run != @current_day
    result = @current_day.next == Date.today
    @current_day = @current_day.next if result
    result
  end

  def grow_baby_grow()
    return if initial_run?()
    remove_missed_days = (@current_day - @latest_run).to_i - 1
    if remove_missed_days < 7
      make_up_time(remove_missed_days)
    else
      restart()
      water_my_garden(FERTILIZER)
      return
    end
    water_my_garden()
  end

  def initial_run?()
    if @latest_run.nil?
      # @current_day.monday? ? water_my_garden() : water_my_garden(FERTILIZER)
      true ? water_my_garden() : water_my_garden(FERTILIZER)
      return true
    end
    false
  end

  def water_my_garden(fertilizer=false)
    if fertilizer
      green_square(GREEN)
    else
      green_square()
      @latest_run = @current_day
      save_data()
    end
  end

  def green_square(color = nil)
    color = update_current_letter() if color.nil?
    num = num_of_commits(color)
    make_commits(num)
  end

  def num_of_commits(color)
    #return num of commits to make for the day
    case color
    when 0
      low, high = 0, 0
    when 1
      low, high = 1, 3
    when 2
      low, high = 5, 8
    when 3
      low, high = 15, 20
    end
    rand(low..high)
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
    clear_output_file()
    commits_were_made(num)
  end

  def next_letter()
    #get the next letter to be written
    puts "NEXT LETTER"
    letter = @word[0]
    @word = @word.slice(1..-1)
    if are_you_puerto_rican?(letter)
      return FONT_LETTERS[:PUERTO_RICO_FLAG].dup
    end
    FONT_LETTERS[letter.capitalize.to_sym].dup
  end

  def load_data()

    payload = File.readlines("lib/data.txt")[0]
    payload = JSON.parse(payload)

    payload["original_word"] == "nil" ? original_word = nil : @original_word = payload["original_word"]
    payload["word"] == "nil" ? current_word = nil : current_word = payload["word"]
    payload["current_letter"] == "nil" ? current_letter = nil : current_letter = payload["current_letter"]
    payload["latest_run"] == "nil" ? latest_run = nil : latest_run = payload["latest_run"]
    @current_index = payload["current_index"].to_i

    validate_latest_run(latest_run)
    validate_current_letter(current_letter)

    # current_word.instance_of?(String) ? @word = current_word : nil
  end

  def validate_latest_run(latest_run)
    if latest_run.nil?
      @latest_run = latest_run
    else
      date = latest_run.split("-")
      @latest_run = Date.new(date[0].to_i, date[1].to_i, date[2].to_i)
    end
  end

  def validate_current_letter(current_letter)
    current_letter.nil? ? @current_letter = next_letter() : @current_letter = current_letter
  end

  def make_up_time(days)
    days.times { update_current_letter() }
  end

  def are_you_puerto_rican?(letter)
    letter == "&"
  end

  def update_current_letter
    @current_letter = next_letter() if @current_letter.empty?
    @current_letter.shift
  end

  def save_data()
    context = {
      original_word: @original_word,
      word: @word,
      current_letter: @current_letter,
      latest_run: @latest_run,
      current_index: @current_index
    }

    log = File.open('lib/data.txt','w')
    log.write(JSON.generate(context))
    log.close
  end

  def load_text()
    lorem = File.readlines('lib/lorem.txt')
    words = lorem[0].chomp.split(" ") #length = 579
  end

  def output_words(new_word)
    output = File.open("lib/output.txt", "a")
    output.write(new_word)
    output.close
  end

  def clear_output_file()
    output = File.open("lib/output.txt", "w")
    output.write("")
    output.close
  end

  def file_writer()
    words = load_text()
    @current_index = (@current_index + 1) % 579
    new_word = words[@current_index] + " "
    output_words(new_word)
  end

  def restart()
    @word = @original_word
    @current_letter= nil
    @latest_run = nil
  end

  def commits_were_made(commits) #save to log
    data = {
      date: Date.today,
      num_of_commits: commits,
      current_letter: @current_letter,
      word: @word,
      latest_run: @latest_run,
    }

    stats = File.open('lib/log.txt','a')
    stats.puts(JSON.generate(data))
    stats.close
  end

end


LushGreenGardens.new()
