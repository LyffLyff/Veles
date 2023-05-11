class_name Binary  extends Reference
# a class that hold useful function to handle binary data


func byte_array_to_int32_little_endian(var bytes : PoolByteArray) -> int:
	# the max input should be 4 bytes -> 4 * 8 = 32
	# any more would not be a Int32 anymore
	# convert using little endian
	var shift_length : int = 0
	var int32 : int = 0
	for i in bytes.size():
		if i == 4:
			break;
		int32 += bytes[i] << shift_length
		# each Byte is 8 bit -> for each Index the Shift length has to increase by 8
		shift_length += 8 
	return int32;


func binary_to_decimal(var binary_number : int) -> int:
	# converting a binary Number represented using an integer
	# to an actual decimal integer
	var decimal_number : int = 0
	var count : int = 0
	var temp : int
	
	while( binary_number != 0 ):
		temp = binary_number % 10
		binary_number /= 10
		decimal_number += temp * int( pow(2, count) )
		count += 1
	
	return decimal_number


func decimal_to_binary(var decimal_value , var bits : int) -> String:
	# converting a decimal number given as an integer to a binary number represented as a string
	var binary_string = "" 
	var temp : int
	var count = bits - 1
	
	while(count >= 0):
		temp = decimal_value >> count 
		if(temp & 1):
			binary_string = binary_string + "1"
		else:
			binary_string = binary_string + "0"
		count -= 1
	
	return binary_string

