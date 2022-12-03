class_name TimeFormatter extends Reference
# a class to format times from string to int, timestamp to seconds,.....

const months : Array = ["January","February","March","April","May","June","July","August","September","October","November","December"]
const day_extensions : Array = ["st","nd","rd","th"]


static func format_seconds(var seconds_f : float) -> String:
	# formatting a given float representing seconds to hours:minutes:seconds
	var seconds_i: int = int(seconds_f)
	var minutes : String = str( seconds_i /60 )
	seconds_i = seconds_i % 60
	var seconds_s : String
	if seconds_i < 10:
		seconds_s = "0" + str(seconds_i)
	else:
		seconds_s = str(seconds_i)
	return minutes + ":" + seconds_s


static func format_daytime(var hour : int, var minute : int, var second : int) -> String:
	var formatted_daytime : String = ""
	for time in [hour,minute,second]:
		if time < 10:
			formatted_daytime += "0" + "%d"%time
		else:
			formatted_daytime += "%d"%time
		formatted_daytime += ":"
	return formatted_daytime.substr(0,formatted_daytime.length() - 1)


static func format_date(var day : int, var month_idx : int, var year : int) -> String:
	return "%d"%day + get_day_extension(day) + " " + months[month_idx - 1] + " " + "%d"%year


static func get_day_extension(var day : int) -> String:
	if day >= 3:
		return day_extensions[3]
	return day_extensions[day]


static func lrc_timestamp_to_seconds(var lrc_timestamp : String) -> float:
	# input -> [20:30.01]
	# output -> [1230.01 Seconds]
	
	var combined_seconds : float = 0.0;
	var temp1 : int = -1
	var temp2 : int = -1
	
	# minutes
	temp1 = lrc_timestamp.find("[", 0)
	temp2 = lrc_timestamp.find(":", temp1 + 1)
	combined_seconds += int( lrc_timestamp.substr(temp1, temp2 - temp1) ) * 60

	# seconds
	combined_seconds += int( lrc_timestamp.substr(temp2 + 1, 2) )
	
	# subsecond Part
	combined_seconds += float( lrc_timestamp.substr(temp2 + 3, 3) )
	
	return combined_seconds;


static func seconds_to_lrc_timestamp(var seconds_f : float) -> String:
	var timestamp_in_millsecs : String = str( seconds_f * 1000 ).pad_decimals(0)  
	var lrc_timestamp : String = "["
	
	var minutes : String = str( int(seconds_f) / 60 )
	if minutes.length() < 2:
		# adding a Zero if minutes is less than double digits
		minutes = minutes.insert(0,"0")
	
	var seconds_s : String = str( int(seconds_f) % 60 )
	if seconds_s.length() < 2:
		# adding a Zero if minutes is less than double digits
		seconds_s = seconds_s.insert(0,"0")
	
	# adding divisors between values
	lrc_timestamp += minutes + ":"
	lrc_timestamp += seconds_s + "."
	
	# sub second value
	lrc_timestamp += timestamp_in_millsecs.substr(timestamp_in_millsecs.length()-3, 2) + "]"
	
	return lrc_timestamp
