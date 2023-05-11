class_name WAV extends Reference
# a class surrounding the .wav Musicformat
# to read/calculate certain properties of .wav files

# all values this class reads from the properties are relative,
# since in some files the fmt specifier is not on the usual Byte Index

func is_channel_stereo(var header : PoolByteArray, var fmt_offset : int) -> bool:
	# 0x200 -> Stereo
	# 0x100 -> Mono
	return true if Binary.new().byte_array_to_int32_little_endian( header.subarray(6 + fmt_offset, 7 + fmt_offset) ) == 2 else false


func get_mix_rate(var header : PoolByteArray, var fmt_offset : int) -> int:
	return Binary.new().byte_array_to_int32_little_endian(header.subarray(8 + fmt_offset, 11 + fmt_offset) )


func get_bit_rate(var header : PoolByteArray, var fmt_offset : int) -> int:
	# in kilobit per second -> kbps
	# typical values: 128kbps, 352kbps, 705.6kbps
	return get_bits_per_sample(header, fmt_offset) * get_byte_rate(header, fmt_offset)


func get_byte_rate(var header : PoolByteArray,var fmt_offset : int) -> int:
	return Binary.new().byte_array_to_int32_little_endian(header.subarray(12 + fmt_offset, 15 + fmt_offset) )


func get_bits_per_sample(var header : PoolByteArray, var fmt_offset : int) -> int:
	return Binary.new().byte_array_to_int32_little_endian(header.subarray(18 + fmt_offset,19 + fmt_offset) )


func get_format_type(var header : PoolByteArray, var fmt_offset : int) -> int:
	return Binary.new().byte_array_to_int32_little_endian(header.subarray(4 + fmt_offset,5 + fmt_offset) )


func find_fmt_in_file(var data : PoolByteArray) -> int:
	# /2 -> Hex Encoded the data is half a long
	# +4 -> Offset since the first index that is not "fmt " is needed
	# only Hex Encodes the first 1024 Bytes since the whole takes too long
	var header : PoolByteArray = []
	if data.size() > 1024:
		header = data.subarray(0,1024)
	else:
		header = data
	
	return header.hex_encode().find("666d7420",0) / 2 + 4;


func audio_pop_workaround(var SongData : PoolByteArray) -> PoolByteArray:
	# this function strip the first few Bytes of a Wav file, dependung on its size
	# this is done to counter a popping noise that can be heard when playing any .wav file
	# this is the only option that seems to work in most cases I've tested, even though it's an ugly
	# the missing bytes are in multiples of 32 so the BitsPerSample, should fit with any file that is not larger than 32Bits per Sample
	# I could not identify anything missing from the playback
	var SizeGoals : PoolIntArray = [1000,100000,1000000,2000000]
	var BytesToStrip : PoolIntArray = [32,128,1024,2048]
	for n in SizeGoals.size():
		if SongData.size() < SizeGoals[n]:
			SongData = SongData.subarray( BytesToStrip[n],SongData.size() - 1)
	return SongData


func convert_32_and_24_to_16_bits(var data : PoolByteArray, var data_bits : int) -> PoolByteArray:
	# Copyright (c) 2020 Gianclgar (Giannino Clemente) gianclgar@gmail.com        
	# converts 24bits and 32bits data files to 16bits audio data                                                     
	var time = OS.get_ticks_msec()
	# 24 bit .wav's are typically stored as integers
	# so we just grab the 2 most significant bytes and ignore the other
	if data_bits == 24:
		var j = 0
		for i in range(0, data.size(), 3):
			data[j] = data[i+1]
			data[j+1] = data[i+2]
			j += 2
		data.resize(data.size() * 2 / 3)
	# 32 bit .wav's are typically stored as floating point numbers
	# so we need to grab all 4 bytes and interpret them as a float first
	if data_bits == 32:
		var spb := StreamPeerBuffer.new()
		var single_float: float
		var value: int
		for i in range(0, data.size(), 4):
			spb.data_array = data.subarray(i, i+3)
			single_float = spb.get_float()
			# half of an integer -> 32768
			value = int( single_float ) * 32768
			data[i/2] = value
			data[i/2+1] = value >> 8
		data.resize(data.size() / 2)
	print("Took %f seconds for slow conversion" % ((OS.get_ticks_msec() - time) / 1000.0))
	return data
