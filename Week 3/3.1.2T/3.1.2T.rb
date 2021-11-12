require './input_functions'

# you need to complete the following procedure that prints out 
# "<Name> is a " then print 'silly' (60 times) on one long line
# then print ' name.' \newline

def print_silly_name(name)
	puts(name + " is a")
	i = 0
	while i < 60
		print 'silly '
		i += 1
	end
	puts 'name!'
end

# copy your code from the previous stage below and 
# change it to call the procedure above, passing in the name:


# put your main() from stage one here
def main()
	name = read_string("What is your name?")
	if name == "Ted" or name == "Fred"
		puts name + " is an awesome name!"
	else
		print_silly_name(name)
	end
end

main()
