require './input_functions'

def read_patient_name()
	# write this function - use the function read_string(s)
	# from input_functions.rb to read in the name
	# make sure you 'return' the name you read to the calling module
	return read_string("Enter patient name: ")
end

def calculate_accommodation_charges()
	charge = read_float("Enter the accommodation charges: ")
	return charge
end

def calculate_theatre_charges()
	charge = read_float("Enter the theatre charges: ")
	return charge
end

def calculate_pathology_charges()
	# complete this function based on the above examples
	return read_float("Enter pathology charges: ")
end

def print_patient_bill(name, total)
	# write this procedure to print out the patient name
	# and the bill total - use the procedure (from input_functions)
	# print_float(value, decimal_places) to print the total
	puts "The patient name: " + name
	puts "The total amount due is: $" + total.to_s
end

def create_patient_bill()
	total = 0 # it is important to initial variables before use!
	patient_name = read_patient_name()
	total += calculate_accommodation_charges()
	total += calculate_theatre_charges()
	total += calculate_pathology_charges()
	print_patient_bill(patient_name, total)
end

def main()
	create_patient_bill()
end

main()