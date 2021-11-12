require './input_functions'

# write code that reads in a user's name from the terminal.  If the name matches
# your name or your tutor's name, then print out "<Name> is an awesome name!"
# Otherwise call a function called print_silly_name(name) - to match the expected output.

#def print_silly_name(name)
#
#end

def main()
  name = read_string("What is your name?")
  if name == "Ted" or name == "Fred"
    puts name + " is an awesome name!"
  else
    puts(name + " is a silly name")
  end
end

main()
