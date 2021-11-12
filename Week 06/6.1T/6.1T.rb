require './input_functions'

# Task 6.1 T - use the code from 5.1 to help with this

class Track
	attr_accessor :name, :location

	def initialize (name, location)
		@name = name
		@location = location
	end
end

# Reads in and returns a single track from the given file

def read_track(music_file)
	name = music_file.gets.chomp.to_s
	location = music_file.gets.chomp.to_s
	t = Track.new(name, location)
	return t
end

# Returns an array of tracks read from the given file

def read_tracks(music_file)
	
	count = music_file.gets().to_i()
	tracks = Array.new()

	# Put a while loop here which increments an index to read the tracks
	while count > 0
		track = read_track(music_file)
		tracks << track
		count -= 1
	end

	return tracks
end

# Takes an array of tracks and prints them to the terminal

def print_tracks(tracks)
	n = tracks.length()
	i = 0
	while i < n
		puts(tracks[i].name)
		puts(tracks[i].location)
		i += 1
	end
end

# Takes a single track and prints it to the terminal
def print_track(track)
  	puts('Track title is: ' + track.name)
	puts('Track file location is: ' + track.location)
end


# search for track by name.
# Returns the index of the track or -1 if not found
def search_for_track_name(tracks, search_string)

# Put a while loop here that searches through the tracks
# Use the read_string() function from input_functions.
# NB: you might need to use .chomp to compare the strings correctly

# Put your code here.
	found_index = -1
	for i in 0..tracks.length() - 1
		if tracks[i].name == search_string
			found_index = i 
			break
		end
	end
  	return found_index
end


# Reads in an Album from a file and then prints all the album
# to the terminal

def main()
  	music_file = File.new("album.txt", "r")
	tracks = read_tracks(music_file)
  	music_file.close()

	print_tracks(tracks)
  	search_string = read_string("Enter the track name you wish to find: ")
  	index = search_for_track_name(tracks, search_string)
  	if index > -1
   		puts "Found " + tracks[index].name
		puts " at " + index.to_s()
  	else
    	puts "Entry not Found"
  	end
end

main()
