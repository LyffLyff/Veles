class_name HexaDecimal extends Reference
#a class holding useful functions to handle hexaDecimal numbers


func hex_digit_to_decimal(var hex_digit : String) -> int:
	if hex_digit.is_valid_integer():
		return int(hex_digit)
	else:
		match hex_digit:
			"a":
				return 10
			"b":
				return 11
			"c":
				return 12
			"d":
				return 13
			"e":
				return 14
			"f":
				return 15
	return 0;
