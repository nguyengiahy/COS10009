require 'rubygems'
require 'gosu'

# Instructions:  This code also needs to be fixed and finished!
# As in the earlier button tasks the "Click Me" text is not appearing
# on the button, also both the mouse_x and mouse_ co-ordinate should
# be shown, regardless of whether the mouse has been clicked or not.
# The button should be highlighted when the mouse moves over it
# (i.e it should have a black border around the outside)
# finally, a user has noticed that in this version also sometimes the
# button action occurs when you click outside the button area and vice-versa.


# FOR THE CREDIT VERSION:
# display a colored border that 'highlights' the button when the mouse moves over it

# determines whether a graphical widget is placed over others or not
module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

# Global constants
WIN_WIDTH = 640
WIN_HEIGHT = 400

class DemoWindow < Gosu::Window

  # set up variables and attributes
  def initialize()
    super(WIN_WIDTH, WIN_HEIGHT, false)
    @background = Gosu::Color::WHITE
    @button_font = Gosu::Font.new(20)
    @info_font = Gosu::Font.new(10)
    @is_hovering = false
    @locs = [60,60]
  end


  # Draw the background, the button with 'click me' text and text
  # showing the mouse coordinates
  def draw()
    # Draw background color
    Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)
    # Draw the rectangle that provides the background.
    # ????
    # Draw the button
    Gosu.draw_rect(50, 50, 100, 50, Gosu::Color::GREEN, ZOrder::TOP, mode=:default)
    if @is_hovering
      Gosu.draw_rect(45, 45, 110, 60, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    end
    # Draw the button text
    @button_font.draw("Click me", 60, 60, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    # Draw the mouse_x position
    @info_font.draw("mouse_x: #{@locs[0]}", 0, 380, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    # Draw the mouse_y position
    @info_font.draw("mouse_y: #{@locs[1]}", 100, 380, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
  end

  def update
    @locs = [mouse_x, mouse_y]
    if mouse_over_button(mouse_x, mouse_y)
      @is_hovering = true
    else
      @is_hovering = false
    end
  end

  # this is called by Gosu to see if it should show the cursor (or mouse)
  def needs_cursor?; true; end

 # This still needs to be fixed!

  def mouse_over_button(mouse_x, mouse_y)
    if ((mouse_x > 50 and mouse_x < 150) and (mouse_y > 50 and mouse_y < 100))
      true
    else
      false
    end
  end

  # If the button area (rectangle) has been clicked on change the background color
  # also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
  # you will learn about inheritance in the OOP unit - for now just accept that
  # these are available and filled with the latest x and y locations of the mouse click.
  def button_down(id)
    case id
    when Gosu::MsLeft
      if mouse_over_button(mouse_x, mouse_y)
        @background = Gosu::Color::YELLOW
      else
        @background = Gosu::Color::WHITE
      end
    end
  end
end

# Lets get started!
DemoWindow.new.show()