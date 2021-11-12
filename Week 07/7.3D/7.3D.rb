require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)
SCREEN_W = 800
SCREEN_H = 600
X_LOCATION = 500		# x-location to display track's name

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
	attr_accessor :bmp, :dim
	def initialize(file, leftX, topY)
		@bmp = Gosu::Image.new(file)
		@dim = Dimension.new(leftX, topY, leftX + @bmp.width(), topY + @bmp.height())
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
	    @albums = read_albums()
	    @album_playing = -1
	    @track_playing = -1
	end

  	# Read a single track
	def read_track(a_file, idx)
		track_name = a_file.gets.chomp
		track_location = a_file.gets.chomp
		# --- Dimension of the track's title ---
		leftX = X_LOCATION
		topY = 50 * idx + 30
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
		tracks = Array.new()
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
	def read_album(a_file, idx)
		title = a_file.gets.chomp
		artist = a_file.gets.chomp
		# --- Dimension of an album's artwork ---
		if idx % 2 == 0
			leftX = 30
		else
			leftX = 250
		end
		topY = 190 * (idx / 2) + 30 + 20 * (idx/2)
		artwork = ArtWork.new(a_file.gets.chomp, leftX, topY)
		# -------------------------------------
		tracks = read_tracks(a_file)
		album = Album.new(title, artist, artwork, tracks)
		return album
	end

	# Read all albums
	def read_albums()
		a_file = File.new("input.txt", "r")
		count = a_file.gets.chomp.to_i
		albums = Array.new()

		i = 0
		while i < count
			album = read_album(a_file, i)
			albums << album
			i += 1
	  	end

		a_file.close()
		return albums
	end

	# Draw albums' artworks
	def draw_albums(albums)
		albums.each do |album|
			album.artwork.bmp.draw(album.artwork.dim.leftX, album.artwork.dim.topY , z = ZOrder::PLAYER)
		end
	end

	# Draw tracks' titles of a given album
	def draw_tracks(album)
		album.tracks.each do |track|
			display_track(track)
		end
	end

	# Draw indicator of the current playing song
	def draw_current_playing(idx, album)
		draw_rect(album.tracks[idx].dim.leftX - 10, album.tracks[idx].dim.topY, 5, @track_font.height(), Gosu::Color::RED, z = ZOrder::PLAYER)
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
		# If a new album has just been seleted, and no album was selected before -> start the first song of that album
		if @album_playing >= 0 && @song == nil
			@track_playing = 0
			playTrack(0, @albums[@album_playing])
		end
		
		# If an album has been selecting, play all songs in turn
		if @album_playing >= 0 && @song != nil && (not @song.playing?)
			@track_playing = (@track_playing + 1) % @albums[@album_playing].tracks.length()
			playTrack(@track_playing, @albums[@album_playing])
		end
	end

	# Draws the album images and the track list for the selected album
	def draw
		draw_background()
		draw_albums(@albums)
		# If an album is selected => display its tracks
		if @album_playing >= 0
			draw_tracks(@albums[@album_playing])
			draw_current_playing(@track_playing, @albums[@album_playing])
		end
	end

 	def needs_cursor?; true; end


	def button_down(id)
		case id
	    when Gosu::MsLeft

	    	# If an album has been selected
	    	if @album_playing >= 0
		    	# --- Check which track was clicked on ---
		    	for i in 0..@albums[@album_playing].tracks.length() - 1
			    	if area_clicked(@albums[@album_playing].tracks[i].dim.leftX, @albums[@album_playing].tracks[i].dim.topY, @albums[@album_playing].tracks[i].dim.rightX, @albums[@album_playing].tracks[i].dim.bottomY)
			    		playTrack(i, @albums[@album_playing])
			    		@track_playing = i
			    		break
			    	end
			    end
			end

			# --- Check which album was clicked on ---
			for i in 0..@albums.length() - 1
				if area_clicked(@albums[i].artwork.dim.leftX, @albums[i].artwork.dim.topY, @albums[i].artwork.dim.rightX, @albums[i].artwork.dim.bottomY)
					@album_playing = i
					@song = nil
					break
				end
			end
	    end
	end

end

# Show is a method that loops through update and draw
MusicPlayerMain.new.show if __FILE__ == $0