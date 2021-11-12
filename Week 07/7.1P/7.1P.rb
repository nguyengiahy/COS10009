require './input_functions'

$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class Album
  attr_accessor :artist, :title, :genre, :tracks

  def initialize(artist, title, genre, tracks)
    @artist = artist
    @title = title
    @genre = genre
    @tracks = tracks
  end

end

class Track
  attr_accessor :track_name, :track_location

  def initialize(name, location)
    @track_name = name
    @track_location = location
  end

end

# Read a single track
def read_track(a_file)
  track_name = a_file.gets
  track_location = a_file.gets
  track = Track.new(track_name, track_location)
  return track
end

# Read all tracks of an album
def read_tracks(a_file)
  count = a_file.gets.chomp.to_i
  tracks = []

  while count > 0
    track = read_track(a_file)
    tracks << track
    count -= 1
  end

  return tracks
end

# Read a single album
def read_album(a_file)
  artist = a_file.gets
  title = a_file.gets
  genre = a_file.gets.chomp
  tracks = read_tracks(a_file)
  album = Album.new(artist, title, genre, tracks)
  return album
end

# Read information of all albums
def read_albums()
  filename = read_string("\nEnter filename: ")
  a_file = File.new(filename, "r")
  count = a_file.gets.chomp.to_i
  
  albums = Array.new()
  while count > 0
    album = read_album(a_file)
    albums << album
    count -= 1
  end

  a_file.close()

  puts "\nThe albums have been loaded."
  read_string("PRESS ENTER...\n")
  
  return albums
end

# Display albums
def display_albums(albums)
  if (!albums)
    puts "You need to load albums first\n"
    return
  end

  puts "\nHow do you want to display:"
  puts "1. Display all"
  puts "2. Display genre\n"
  
  choice = read_integer_in_range("Please enter your choice:", 1, 2)

  case choice
    when 1
      display_all_albums(albums)
    when 2
      display_genre(albums)
    else
      puts "Invalid choice"
  end

end

# Display all albums
def display_all_albums(albums)

  for i in 0..albums.length() - 1
    puts "\nAlbum ID: #{i+1}"
    display_album(albums[i])
    puts ""
  end

end

# Display a single album
def display_album(album)
  puts "Artist: #{album.artist}"
  puts "Title: #{album.title}"
  puts "Genre: #{album.genre}"
  display_tracks(album.tracks)
end

# Display all tracks of an album
def display_tracks(tracks)
  n = tracks.length

  puts "There are #{n} tracks in the album:"

  for i in 0..n - 1
    puts "Track #{i+1}:"
    display_track(tracks[i])
  end

end

# Display a single track
def display_track(track)
  puts track.track_name
  puts track.track_location
end

# Display albums according to genre
def display_genre(albums)
  puts "\nSelect genre"
  puts "1 - Pop"
  puts "2 - Psytrance"
  puts "3 - Alt-rock"
  puts "4 - Metal\n"

  genre = read_integer_in_range("\nPlease enter your choice:", 1, 4)
  genre = genre.to_s

  display_albums_by_genre(genre, albums)

  puts ""
end

# Display albums with the selected genre
def display_albums_by_genre(genre, albums)

  for i in 0..albums.length - 1
    if albums[i].genre == genre
      puts "\nAlbum ID: #{i+1}"
      display_album(albums[i])
      puts ""
    end
  end

end

# Play an album with a given ID
def play_album(albums)

  if (!albums)
    puts "You need to load albums first\n"
    return
  end

  album_id = read_integer_in_range("\nAlbum ID: ", 1, albums.length())
  tracks_count = albums[album_id - 1].tracks.length()
  
  if tracks_count == 0
    puts "There is no track to play\n"
    return
  end

  puts "There are #{tracks_count} tracks:"

  for i in 0..tracks_count-1
    puts "#{i+1}. #{albums[album_id - 1].tracks[i].track_name}"
  end

  choice = read_integer_in_range("\nEnter track you want to play:", 1, tracks_count)

  puts "\nPlaying track #{albums[album_id - 1].tracks[choice-1].track_name.chomp} from album #{albums[album_id - 1].title}"

  read_string("PRESS ENTER...\n")

end

# Update an existing album
def update_album(albums)

  if (!albums)
    puts "You need to load albums first\n"
    return
  end

  album_id = read_integer_in_range("\nAlbum ID: ", 1, albums.length())

  puts "\nWhat information do you want to update:"
  puts "1. Update title"
  puts "2. Update genre"

  choice = read_integer_in_range("\nYour choice: ", 1, 2)

  case choice
    when 1
      string = read_string("\nNew title: ")
      albums[album_id - 1].title = string
    when 2
      string = read_string("\nNew genre: ")
      albums[album_id - 1].genre = string
    else
      puts "Invalid choice"
  end

  puts "Updated album info:"
  puts "\nAlbum #{album_id}:"
  display_album(albums[album_id - 1])
  puts ""

  return albums

end

# Display main menu
def display_menu(albums)

  finished = false
  while not finished
    puts "Main Menu:"
    puts "1. Read in Albums"
    puts "2. Display Albums"
    puts "3. Play an Album"
    puts "4. Update an Album"
    puts "5. Exit"
    
    choice = read_integer_in_range("Please enter your choice:", 1, 5)
    
    case choice
      when 1
        albums = read_albums()
      when 2
        display_albums(albums)
      when 3
        play_album(albums)
      when 4
        albums = update_album(albums)
      when 5
        finished = true
      else
        puts "Invalid choice"
    end
  end
end

def main()
  albums = nil
  display_menu(albums)
end

main