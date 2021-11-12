require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)
SCREEN_W = 800
SCREEN_H = 600
X_LOCATION = 400		# x-location to display track's name

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
	attr_accessor :bmp
	def initialize(file)
		@bmp = Gosu::Image.new(file)
	end
end

class Album
	attr_accessor :title, :artist, :artwork, :tracks
	def initialize (title, artist, artwork, tracks)
		@title = title
		@artist = artist
		@artwork = artwork
		@tracks = tracks
	end
end

class Track
	attr_accessor :name, :location, :dim
	def initialize(name, location, dim)
		@name = name
		@location = location
		@dim = dim
	end
end

class Dimension
	attr_accessor :leftX, :topY, :rightX, :bottomY
	def initialize(leftX, topY, rightX, bottomY)
		@leftX = leftX
		@topY = topY
		@rightX = rightX
		@bottomY = bottomY
	end
end


class MusicPlayerMain < Gosu::Window

	def initialize
	    super SCREEN_W, SCREEN_H
	    self.caption = "Music Player"
	    @track_font = Gosu::Font.new(25)
	    @album = read_album()
		@track_playing = 0
		playTrack(@track_playing, @album)
	end

  	# Read a single track
	def read_track(a_file, idx)
		track_name = a_file.gets.chomp
		track_location = a_file.gets.chomp
		# --- Dimension of the track ---
		leftX = X_LOCATION
		topY = 100 * idx + 50
		rightX = leftX + @track_font.text_width(track_name)
		bottomY = topY + @track_font.height()
		dim = Dimension.new(leftX, topY, rightX, bottomY)
		# --- Create a track object ---
		track = Track.new(track_name, track_location, dim)
		return track
	end

	# Read all tracks of an album
	def read_tracks(a_file)
		count = a_file.gets.chomp.to_i
		tracks = []
		# --- Read each track and add it into the arry ---
		i = 0
		while i < count
			track = read_track(a_file, i)
			tracks << track
			i += 1
		end
		# --- Return the tracks array ---
		return tracks
	end

	# Read a single album
	def read_album()
		a_file = File.new("input.txt", "r")
		title = a_file.gets.chomp
		artist = a_file.gets.chomp
		artwork = ArtWork.new(a_file.gets.chomp)
		tracks = read_tracks(a_file)
		album = Album.new(title, artist, artwork.bmp, tracks)
		a_file.close()
		return album
	end

	# Draw album
	def draw_albums(albums)
		@album.artwork.draw(50, 50 , z = ZOrder::PLAYER, 0.3, 0.3)
		@album.tracks.each do |track|
			display_track(track)
		end
	end

	# Draw indicator of the current playing song
	def draw_current_playing(idx)
		draw_rect(@album.tracks[idx].dim.leftX - 10, @album.tracks[idx].dim.topY, 5, @track_font.height(), Gosu::Color::RED, z = ZOrder::PLAYER)
	end

	# Detects if a 'mouse sensitive' area has been clicked on
	# i.e either an album or a track. returns true or false
	def area_clicked(leftX, topY, rightX, bottomY)
		if mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY
			return true
		end
		return false
	end

	# Takes a String title and an Integer ypos
	# You may want to use the following:
	def display_track(track)
		@track_font.draw(track.name, X_LOCATION, track.dim.topY, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
	end


	# Takes a track index and an Album and plays the Track from the Album
	def playTrack(track, album)
		@song = Gosu::Song.new(album.tracks[track].location)
		@song.play(false)
	end

	# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
	def draw_background()
		draw_quad(0,0, TOP_COLOR, 0, SCREEN_H, TOP_COLOR, SCREEN_W, 0, BOTTOM_COLOR, SCREEN_W, SCREEN_H, BOTTOM_COLOR, z = ZOrder::BACKGROUND)
	end

	# Not used? Everything depends on mouse actions.
	def update
		if not @song.playing?
			@track_playing = (@track_playing + 1) % @album.tracks.length()
			playTrack(@track_playing, @album)
		end
	end

	# Draws the album images and the track list for the selected album
	def draw
		draw_background()
		draw_albums(@album)
		draw_current_playing(@track_playing)
	end

 	def needs_cursor?; true; end


	def button_down(id)
		case id
	    when Gosu::MsLeft
	    	# --- Check which track was clicked on ---
	    	for i in 0..@album.tracks.length() - 1
		    	if area_clicked(@album.tracks[i].dim.leftX, @album.tracks[i].dim.topY, @album.tracks[i].dim.rightX, @album.tracks[i].dim.bottomY)
		    		playTrack(i, @album)
		    		@track_playing = i
		    		break
		    	end
		    end
	    end
	end

end

# Show is a method that loops through update and draw
MusicPlayerMain.new.show if __FILE__ == $0