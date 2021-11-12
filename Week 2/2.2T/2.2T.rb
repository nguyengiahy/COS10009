require 'date'
require './input_functions'

# Multiply metres by the following to get inches:
INCHES = 39.3701

# Insert into the following your hello_user code
# from task 1.3P and modify it to use the functions
# in input_functions

def main()

  # HOW TO USE THE input_functions CODE
  # Example of how to read strings:

  name = read_string('What is your name?')
  puts("Your name is " + name + "!")

  family_name = read_string('What is your family name?')
  puts("Your family name is: " + family_name + "!")

  # Example of how to read integers:

  year_born = read_integer('What year were you born?')
  puts("So you are " + (Date.today.year - year_born).to_s + " years old")

  # Example of how to read floats:

  height = read_float('Enter your height in metres (i.e as a float): ')
  puts("Your height in inches is: ")
  puts(height * INCHES)

  puts 'Finished'

  if boolean = read_boolean("Do you want to continue?")
    puts "ok, lets continue"
  else
    puts "ok, goodbye"
  end
	 # Now if you know how to do all that
   # Copy in your code from your completed
	 # hello_user Task 1.3 P. Then modify it to
	 # use the code in input_functions.
   # use read_string for all strings (this will
   # remove all whitespace)
end

main()
