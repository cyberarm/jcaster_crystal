ROOT_PATH = File.expand_path("../..", __FILE__)

require "gosu"

require "./lib/jcaster"
require "./lib/world_map"
require "./lib/player"
require "./lib/map"
require "./lib/timer"

class Launcher < Gosu::Window
  DETAILS = {0 => "Very low", 1 => "Low", 2 => "Medium", 3 => "High", 4 => "Max"}

  def initialize
    @title = Gosu::Image.new("#{ROOT_PATH}/media/title.jpg", tileable: true)
    @font = Gosu::Font.new(20, name: "#{ROOT_PATH}/media/boxybold.ttf")

    settings = File.read("#{ROOT_PATH}/settings").lines.map { |l| l.chomp.to_i }

    @screen_width = Gosu.screen_width
    @screen_height = Gosu.screen_height
    @details = settings[2]
    @timer = Timer.new

    super 640, 480, fullscreen: false
    self.caption = "jCaster Launcher"
  end

  def update
    if Gosu.button_down?(Gosu::KB_D) && @timer.time > 100
      if @details > DETAILS.size - 2
        @details = 0
      else
        @details += 1
      end

      save_settings
      @timer.reset
    end
    if Gosu.button_down?(Gosu::KB_RETURN)
      JCaster.new.show
      close
    end
    close if Gosu.button_down?(Gosu::KB_ESCAPE)
  end

  def save_settings
    File.open("#{ROOT_PATH}/settings", "w") do |file|
      file.write("#{@screen_width.to_s}\n#{@screen_height.to_s}\n#{@details.to_s}".to_slice)
    end
  end

  def draw
    @title.draw(0, 0, 10, 2, 2)
    @font.draw_text("v#{VERSION}!", 460, 140, 10, 1, 1, color = 0xffffffff)
    @font.draw_markup("<c=6a6a6a>R</c>esolution: #{@screen_width} x #{@screen_height}", 20, 240, 10, 1, 1, color = 0xffffffff)
    @font.draw_markup("<c=6a6a6a>D</c>etails: #{DETAILS[@details]}", 20, 300, 10, 1, 1, color = 0xffffffff)
    @font.draw_text_rel("PRESS ENTER TO START", 320, 440, 10, 0.5, 0.5, 1, 1, color = 0xffffffff) if (Gosu.milliseconds / 500).to_i % 2 == 0
  end
end

Launcher.new.show
