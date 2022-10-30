extends Reference

class_name Binary

#A class that hold useful function to handle binary data


func ByteArrayToInt32(var Bytes : PoolByteArray) -> int:
	#The Max Input of this Function should be 4 Bytes
	#Any more would not be a Int32 anymore
	#Converted Using BIG Endian
	var ShiftLength : int = 0
	var Int32 : int = 0
	for i in Bytes.size():
		if i == 4:
			break;
		Int32 += Bytes[i] << ShiftLength
		#Each Byte is 8 Bit -> for each Index the Shift length has to increase by 8
		ShiftLength += 8 
	return Int32;


func Binary2Decimal(var BinaryValue : int) -> int:
	#Converting a binary Number represented using an integer
	#to an actual decimal integer
	var DecimalValue : int = 0
	var Count : int = 0
	var Temp : int
	
	while( BinaryValue != 0 ):
		Temp = BinaryValue % 10
		BinaryValue /= 10
		DecimalValue += Temp * int( pow(2, Count) )
		Count += 1
	
	return DecimalValue


func Decimal2Binary(var DecimalValue,var Bits : int) -> String:
	var BinaryString = "" 
	var Temp : int
	var Count = Bits - 1
	
	while(Count >= 0):
		Temp = DecimalValue >> Count 
		if(Temp & 1):
			BinaryString = BinaryString + "1"
		else:
			BinaryString = BinaryString + "0"
		Count -= 1
	
	return BinaryString

