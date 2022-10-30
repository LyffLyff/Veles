extends Reference

class_name HexaDecimal

#A class holding useful functions to Interface with HexaDecimal Numbers


func SingleHexToDecimal(var Hex : String) -> int:
	if Hex.is_valid_integer():
		return int(Hex)
	else:
		match Hex:
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
