require 'gosu'

module ZOrder
  LOWEST, LOW, HIGH, HIGHEST = *0..3
end

module ItemType
  LIVE, SHIELD = *0..1
end

################################################
############# Constants declaration ############
################################################

SCR_WIDTH = 550
SCR_HEIGHT = 700
HEADER_HEIGHT = 60
FONT_SIZE = 25
OFFSET = 10

################################################
############# Classes declaration ##############
################################################

class Live
	attr_accessor :image
	def initialize
		@image = Gosu::Image.new("images/live.png")
	end
end
# ----------------------------------------------
class Player
	attr_accessor :image, :x, :y, :moving_velocity, :falling_velocity, :lives, :inventories, :score

	def initialize()
		@image = Gosu::Image.new("images/ball.png")
		@x = rand(0 .. SCR_WIDTH - @image.width)		# Initialise x-position randomly
		@y = HEADER_HEIGHT + Gosu::Image.new("images/up_thorn.png").height
		@moving_velocity = 4							# Velocity of moving horizontally 
		@falling_velocity = 5							# Velocity of falling horizontally
		@lives = [Live.new, Live.new, Live.new]			# Initilise player with 3 lives
		@inventories = Array.new()						# Player's collected items
		@score = 0										# Player's score
	end
end
# ----------------------------------------------
class Block
	attr_accessor :image, :x, :y, :moving_velocity, :is_obstacle

	def initialize(moving_velocity)
		@image = Gosu::Image.new("images/block.png")
		@x = rand(0 .. SCR_WIDTH - @image.width)		# Initialise x-position randomly
		@y = SCR_HEIGHT
		@moving_velocity = moving_velocity 				# Velocity of moving upwards
		@is_obstacle = false		
	end
end
# ----------------------------------------------
class Item
	attr_accessor :image, :x, :y, :velocity, :item_type
	def initialize(item_type)
		if item_type == ItemType::LIVE
	    	@image = Gosu::Image.new("images/live.png")
	    else
	    	@image = Gosu::Image.new("images/shield.png")
	    end
	    @item_type = item_type
	    @x = nil
	    @y = nil
	    @velocity = nil
  	end
end

################################################
############# Utility functions ################
################################################

# Move player to left
def move_left player
	if player.x - player.moving_velocity < 0	# If player is off the screen => set x = 0
  		player.x = 0
  	else
	  	player.x -= player.moving_velocity		# Move left
  	end
end
# ----------------------------------------------
# Move player to right
def move_right player
	if player.x + player.image.width + player.moving_velocity > SCR_WIDTH 	# If player is off the screen => set x = 0
  		player.x = SCR_WIDTH - player.image.width
  	else
	  	player.x += player.moving_velocity				# Move right
  	end
end
# ----------------------------------------------
# Let player falling
def fall player
	player.y += player.falling_velocity
end
# ----------------------------------------------
# Spawn player on a random block
def spawn blocks, player
	# Get the furthest non-obstacle block index
	idx = blocks.length - 1
	while blocks[idx].is_obstacle
		idx -= 1
	end

	# Spawn player on the found block
	player.x = blocks[idx].x
	player.y = blocks[idx].y - player.image.height
end
# ----------------------------------------------
# Set player's original image
def set_player_image player
	player.image = Gosu::Image.new("images/ball.png")
end
# ----------------------------------------------
# Reduce player's lives and spawn on a random block
def reduce_live blocks, player
	# Decrease 1 live
	player.lives.pop

	# Spawn player on a random block
	spawn blocks, player
end
# ----------------------------------------------
# Check if player has touched the top boundary or bottom boundary
def check_boundary blocks, player
	if player.lives.length > 0

		# Exceed bottom boundary
		if player.y > SCR_HEIGHT		
			reduce_live blocks, player

		# Exceed top boundary but player has a shield
		elsif  player.y < HEADER_HEIGHT + Gosu::Image.new("images/up_thorn.png").height
			if player.inventories.any? {|inventory| inventory.item_type == ItemType::SHIELD}
				# Remove the shield effect
				player.inventories = player.inventories.reject{|inventory| inventory.item_type == ItemType::SHIELD}
				set_player_image player

				# Spawn player on a random block
				spawn blocks, player
			
			# Exceed top boundary but player DOESN'T have a shield
			else
				reduce_live blocks, player
			end
		end
	end
end
# ----------------------------------------------
# Stop the ball when it touches blocks
def stand_on_block (blocks, player)
	blocks.each do |block|
		bottom_boundary = player.y + player.image.height 	# the bottom boundary of the ball
		left_boundary = block.x - player.image.width 		# the leftmost boundary to fall
		right_boundary = block.x + block.image.width 		# the rightmost boundary to fall

		# If the ball stands on the region
		if (bottom_boundary >= block.y && bottom_boundary <= block.y + 2*OFFSET) && (player.x >= left_boundary && player.x <= right_boundary)
			# If it is a normal block
			if !block.is_obstacle
				player.y = block.y - player.image.height
			# If it is an obstacle but player has shield
			elsif player.inventories.any? {|inventory| inventory.item_type == ItemType::SHIELD}
				# Remove the shield effect
				player.inventories = player.inventories.reject{|inventory| inventory.item_type == ItemType::SHIELD}
				set_player_image player

				# Spawn player on a random block
				spawn blocks, player
			# If it is an obstacle but player DOESN'T have shield
			else
				reduce_live blocks, player
			end
		end
	end
end
# ----------------------------------------------
# Generate a random block and add it in the blocks array
def create_block blocks, moving_velocity, is_obstacle
	block = Block.new(moving_velocity)
	if is_obstacle
		block.is_obstacle = true
		block.image = Gosu::Image.new("images/thorn.png")
	end
	blocks << block
end
# ----------------------------------------------
# Move the blocks upward
def move_blocks blocks
	blocks.each do |block|
		block.y -= block.moving_velocity
	end
end
# ----------------------------------------------
# Move the items upward
def move_items items
	items.each do |item|
		if item != nil
			item.y -= item.velocity
			if item.y < HEADER_HEIGHT + Gosu::Image.new("images/up_thorn.png").height
				items.delete(item)
			end
		end
	end
end
# ----------------------------------------------
# Increase the score and remove blocks
def scoring (blocks, player)
	blocks.each do |block|
		if block.y < HEADER_HEIGHT + Gosu::Image.new("images/up_thorn.png").height
			blocks.delete(block)
			player.score += 1
		end
	end
end
# ----------------------------------------------
# Collect items when player touches it
def collect_items player, items
	items.each do |item|
		if item != nil
			# Distance between player and item
			dist = Gosu.distance(player.x + player.image.width/2, player.y + player.image.height/2, item.x + item.image.width/2, item.y + item.image.height/2)
			
			# If the distance is close enough
			if dist <= item.image.width/2 + player.image.width/2
				if item.item_type == ItemType::LIVE && player.lives.length < 6		# Maximum number of lives is 6
					player.lives << Live.new()
				elsif item.item_type == ItemType::SHIELD && !player.inventories.any? {|inventory| inventory.item_type == ItemType::SHIELD}
					player.image = Gosu::Image.new("images/metal_ball.png")
					player.inventories << Item.new(ItemType::SHIELD)
				end
				items.delete(item)
			end
		end
	end
end
# ----------------------------------------------
# Draw player
def draw_player player
	if player.lives.length > 0
		# Draw the ball
    	player.image.draw(player.x, player.y, ZOrder::HIGH)
    	# Draw player's lives in the header
    	player.lives.each_with_index do |live, idx|
    		x_pos = SCR_WIDTH - (idx + 1) * (live.image.width + OFFSET) - idx * OFFSET/2
    		live.image.draw(x_pos, 0.5 * OFFSET, ZOrder::LOW)
    	end
  	end
end
# ----------------------------------------------
# Draw player's score
def draw_score player, font
	font.draw_text("Score: #{player.score}", 0, 0, ZOrder::HIGHEST, 1.0, 1.0, Gosu::Color::BLACK)
end
# ----------------------------------------------
# Draw blocks
def draw_block blocks
	blocks.each do |block|
      block.image.draw(block.x, block.y, ZOrder::LOW)
    end
end
# ----------------------------------------------
# Draw items
def draw_items items
	items.each do |item|
		if item != nil
			item.image.draw(item.x, item.y, ZOrder::LOW)
		end
	end
end
# ----------------------------------------------
# Draw top boundary of the playable game region
def draw_top_boundary
	Gosu.draw_rect(0, 0, SCR_WIDTH, HEADER_HEIGHT, Gosu::Color.argb(0xff_ffffcc), ZOrder::LOW)
	obstacle = Gosu::Image.new("images/up_thorn.png", :tileable => true)
	obstacle.draw(0, HEADER_HEIGHT, ZOrder::LOW)
end
# ----------------------------------------------
# Draw game-over screen
def draw_game_over player
	if player.lives.empty?
      	end_screen = Gosu::Image.new("images/game_over.jpg")
      	end_screen.draw(0, 0, ZOrder::HIGHEST)
    end
end

################################################
################## Game Main ###################
################################################

class Main < Gosu::Window
	def initialize
		super SCR_WIDTH, SCR_HEIGHT, false
		self.caption = "Rolling Ball"
		@font = Gosu::Font.new(FONT_SIZE)
		@background_img = Gosu::Image.new("images/space.png", :tileable => true)
		@blocks_moving_velocity = 3			# Moving upward velocity of blocks
		@player = Player.new()				
		@blocks = Array.new()
		@items = Array.new()
		@block_waiting_time = 0				# if block_waiting_time equals the create_block_time => new block is created
		@create_block_time = 55				# this will be set randomly but now it is initilized with 55
		@block_min_freq = 65				# lowest frequency of generating blocks
		@block_max_freq = 80				# highest frequency of generating blocks
		@obstacle_freq = 5					# frequency of generating obstacles
		@item_freq = 4						# frequency of generating items
		@time_elapsed = 0					
	end

	# ----------------------------------------------
	# Generate new blocks with random frequency
	def generate_blocks
		# Create either an obtacle or a normal block
		if rand(@obstacle_freq) < 1 && !@blocks.any? {|block| block.is_obstacle == true} && !@blocks.empty?
			create_block(@blocks, @blocks_moving_velocity, true)			# Create an obstacle
		else
			create_block(@blocks, @blocks_moving_velocity, false)			# Create a normal block
		end

		# Reset block_waiting_time and randomly set the next create_block_time
		@block_waiting_time = 0
		@create_block_time = rand(@block_min_freq .. @block_max_freq)	
	end
	# ----------------------------------------------
	# Generate new items with random frequency
	def generate_items
		# Put item on the furthest block
		idx = @blocks.length - 1
		if !@blocks[idx].is_obstacle
			# Create random item type
			num = rand(0 .. 1)
			type = ItemType::LIVE
			if num == 1
				type = ItemType::SHIELD
			end
			# Create an item and put it on the furthest block
			item = Item.new(type)
			item.x = rand(@blocks[idx].x .. @blocks[idx].x + @blocks[idx].image.width - item.image.width)
			item.y = @blocks[idx].y - item.image.height
			item.velocity = @blocks_moving_velocity
		end
		@items << item
	end
	# ----------------------------------------------
	# Increase the game difficulty over time 
	def increase_difficulty
		if @time_elapsed % 1000 == 0 && @time_elapsed <= 3000

			# Increase velocities 
			@player.falling_velocity += 2
			@player.moving_velocity += 2
			@blocks_moving_velocity += 1

			# Make blocks to move consistently with the new velocity
			@blocks.each do |block|
				block.moving_velocity = @blocks_moving_velocity
			end

			# Make items to move consistently with the new velocity
			@items.each do |item|
				if item != nil
					item.velocity = @blocks_moving_velocity
				end
			end

			@block_min_freq -= 15
			@block_max_freq -= 15

			# Reduce the chances of generating items
			@item_freq -= 1
		end
	end
	# ----------------------------------------------
	def draw
		@background_img.draw(0, 0, ZOrder::LOWEST)
		draw_score @player, @font
		draw_top_boundary
		draw_player @player
		draw_block @blocks
		draw_items @items
	 	draw_game_over @player
	end
	# ----------------------------------------------
	def update

		@block_waiting_time += 1
		@time_elapsed += 1
		# -------- Generate blocks randomly ---------
		if @block_waiting_time == @create_block_time
			generate_blocks
		end
		# --------- Generate items randomly ---------
		if rand(1000) < @item_freq && @blocks.length > 0
			generate_items
		end
		# ------------ Player movement --------------
		if Gosu.button_down? Gosu::KB_LEFT
      		move_left @player
    	end
    	if Gosu.button_down? Gosu::KB_RIGHT
      		move_right @player
    	end
    	# ------------ Game play --------------------
    	move_blocks @blocks
    	move_items @items
    	fall @player
    	stand_on_block @blocks, @player
    	collect_items @player, @items
    	check_boundary @blocks, @player
    	scoring @blocks, @player
    	increase_difficulty

	end
	# ----------------------------------------------
	def button_down(id)
		case id
		# Replay the game
		when Gosu::KB_SPACE
			if @player.lives.empty?
				# Set everything back to the initial state
				@blocks_moving_velocity = 3
				@player = Player.new()
				@blocks = Array.new()
				@items = Array.new()
				@block_waiting_time = 0				
				@create_block_time = 55				
				@block_min_freq = 45
				@block_max_freq = 80
				@obstacle_freq = 5
				@item_freq = 3
				@time_elapsed = 0
			end
		end
	end
end

Main.new.show