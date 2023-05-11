class_name HexaDecimal extends Reference
#a class holding useful functions to handle hexaDecimal numbers


func hex_digit_to_decimal(var hex_digit : String) -> int:
	if hex_digit.is_valid_integer():
		return int(hex_digit)
	else:
		match hex_digit.to_upper():
			"A":
				return 10
			"B":
				return 11
			"C":
				return 12
			"D":
				return 13
			"E":
				return 14
			"F":
				return 15
	return 0;
