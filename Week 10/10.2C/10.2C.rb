# Recursive Factorial

# Complete the following
def factorial(n)
	if n == 0
		return 1
    else
        return n * factorial(n-1)
    end
end

# Check if a string is a number
def is_number(string)
	return string.to_f.to_s == string.to_s || string.to_i.to_s == string.to_s
end

# Add to the following code to prevent errors for ARGV[0] < 1 and ARGV.length < 1
def main
	if is_number(ARGV[0]) && ARGV[0].to_i >= 0
    	puts factorial(ARGV[0].to_i)	
  	else
  		puts("Incorrect argument - need a single argument with a value of 0 or more.\n")
  	end
end

main