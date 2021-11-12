require 'rubygems'
require 'gosu'
require './circle'

class DemoWindow < Gosu::Window
  def initialize
    super(640, 400)
    self.caption = "My Drawing"
  end

  def draw
    blue = Gosu::Color::BLUE
    draw_rect(100, 200, 300, 150, Gosu::Color::GREEN, z = 0)
    draw_triangle(50, 50, blue, 100, 150, blue, 200, 100, blue, z = 0)
    img2 = Gosu::Image.new(Circle.new(50))
    img2.draw(500, 40, z=0, 0.5, 1.0, Gosu::Color::RED)

  end
end

DemoWindow.new.show
