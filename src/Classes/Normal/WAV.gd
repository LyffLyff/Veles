class_name WAV extends Reference

#A class surrounding the .wav Musicformat
#to read/calculate certain properties of .wav files

#all values this class reads from the properties are relative,
#since in some files the fmt specifier is not on the usual Byte Index


func IsChannelTypeStereo(var Header : PoolByteArray, var FmtOffset : int) -> bool:
	#0x200 -> Stereo
	#0x100 -> Mono
	return true if Binary.new().ByteArrayToInt32( Header.subarray(6 + FmtOffset,7 + FmtOffset) ) == 2 else false


func GetMixRate(var Header : PoolByteArray, var FmtOffset : int) -> int:
	return Binary.new().ByteArrayToInt32(Header.subarray(8 + FmtOffset,11 + FmtOffset) )


func GetBitRate(var Header : PoolByteArray, var FmtOffset : int) -> int:
	#in kilobit per second -> kbps
	#Typical Value: 128kbps, 352kbps, 705.6kbps
	return GetBitsPerSample(Header, FmtOffset) * GetByteRate(Header, FmtOffset)


func GetByteRate(var Header : PoolByteArray,var FmtOffset : int) -> int:
	return Binary.new().ByteArrayToInt32(Header.subarray(12 + FmtOffset,15 + FmtOffset) )


func GetBitsPerSample(var Header : PoolByteArray, var FmtOffset : int) -> int:
	return Binary.new().ByteArrayToInt32(Header.subarray(18 + FmtOffset,19 + FmtOffset) )


func GetWAVFormatType(var Header : PoolByteArray, var FmtOffset : int) -> int:
	return Binary.new().ByteArrayToInt32(Header.subarray(4 + FmtOffset,5 + FmtOffset) )


func FindFMTInFile(var Data : PoolByteArray) -> int:
	#/2 -> Hex Encoded the data is half a long
	# +4 -> Offset since the first index that is not "fmt " is needed
	#Only Hex Encodes the first 1024 Bytes since the whole takes too long
	var Header : PoolByteArray = []
	if Data.size() > 1024:
		Header = Data.subarray(0,1024)
	else:
		Header = Data
	
	return Header.hex_encode().find("666d7420",0) / 2 + 4;


func AudioPopWorkAround(var SongData : PoolByteArray) -> PoolByteArray:
	#This function strip the first few Bytes of a Wav file, dependung on its size
	#this is done to counter a popping noise that can be heard when playing any .wav file
	#this is the only option that seems to work in most cases I've tested, even though it's an ugly
	#the missing bytes are in multiples of 32 so the BitsPerSample, should fit with  any file that is not larger than 32Bits per Sample
	#I could not hear any missing Sounds
	var SizeGoals : PoolIntArray = [1000,100000,1000000,2000000]
	var BytesToStrip : PoolIntArray = [32,128,1024,2048]
	for n in SizeGoals.size():
		if SongData.size() < SizeGoals[n]:
			SongData = SongData.subarray( BytesToStrip[n],SongData.size() - 1)
	return SongData


func Convert32And24BitsTo16(var Data : PoolByteArray, var DataBits : int) -> PoolByteArray:
	#Copyright (c) 2020 Gianclgar (Giannino Clemente) gianclgar@gmail.com        
	#Converts 24Bits and 32Bits Data files to 16Bits Data                                                       
	var time = OS.get_ticks_msec()
	# 24 bit .wav's are typically stored as integers
	# so we just grab the 2 most significant bytes and ignore the other
	if DataBits == 24:
		var j = 0
		for i in range(0, Data.size(), 3):
			Data[j] = Data[i+1]
			Data[j+1] = Data[i+2]
			j += 2
		Data.resize(Data.size() * 2 / 3)
	# 32 bit .wav's are typically stored as floating point numbers
	# so we need to grab all 4 bytes and interpret them as a float first
	if DataBits == 32:
		var spb := StreamPeerBuffer.new()
		var single_float: float
		var value: int
		for i in range(0, Data.size(), 4):
			spb.data_array = Data.subarray(i, i+3)
			single_float = spb.get_float()
			#half of an integer -> 32768
			value = int( single_float ) * 32768
			Data[i/2] = value
			Data[i/2+1] = value >> 8
		Data.resize(Data.size() / 2)
	print("Took %f seconds for slow conversion" % ((OS.get_ticks_msec() - time) / 1000.0))
	return Data
