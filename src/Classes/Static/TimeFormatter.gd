extends Reference

class_name TimeFormatter


const Months : Array = ["January","February","March","April","May","June","July","August","September","October","November","December"]
const DayExtension : Array = ["st","nd","rd","th"]


static func FormatSeconds(var Seconds_F : float) -> String:
	#Formatting a given float representing seconds to hours:minutes:seconds
	var Seconds_I: int = int(Seconds_F)
	var Min : String = str( Seconds_I /60 )
	var Seconds : int = Seconds_I % 60
	var Seconds_S : String
	if Seconds < 10:
		Seconds_S = "0" + str(Seconds)
	else:
		Seconds_S = str(Seconds)
	return Min + ":" + Seconds_S


static func FormatDayTime(var hour : int, var minute : int, var second : int) -> String:
	var FormattedDayTime : String = ""
	for n in [hour,minute,second]:
		if n < 10:
			FormattedDayTime += "0" + "%d"%n
		else:
			FormattedDayTime += "%d"%n
		FormattedDayTime += ":"
	return FormattedDayTime.substr(0,FormattedDayTime.length() - 1)


static func FormatDate(var Day : int, var MonthIdx : int, var Year : int) -> String:
	return "%d"%Day + GetDayExtension(Day) + " " + Months[MonthIdx - 1] + " " + "%d"%Year


static func GetDayExtension(var Day : int) -> String:
	if Day >= 3:
		return DayExtension[3]
	return DayExtension[Day]


static func LRCTimeStampToSeconds(var LRCTimestamp : String) -> float:
	#Input -> [20:30.01]
	#Output -> [1230.01 Seconds]
	
	var CombinedSeconds : float = 0.0;
	var Temp1 : int = -1
	var Temp2 : int = -1
	
	#Minutes
	Temp1 = LRCTimestamp.find("[",0)
	Temp2 = LRCTimestamp.find(":",Temp1 + 1)
	CombinedSeconds += int( LRCTimestamp.substr(Temp1,Temp2 - Temp1) ) * 60

	#Seconds
	CombinedSeconds += int( LRCTimestamp.substr(Temp2 + 1,2) )
	
	#Subsecond Part
	CombinedSeconds += float( LRCTimestamp.substr(Temp2 + 3,3) )
	
	return CombinedSeconds;


static func SecondsToLRCTimestamp(var Seconds : float) -> String:
	var timestamp_in_millsecs : String = str( Seconds * 1000 ).pad_decimals(0)  
	var LRCTimestamp : String = "["
	var minutes : String = str( int(Seconds) / 60 )
	if minutes.length() < 2:
		#Adding a Zero if minutes is less than double digits
		minutes = minutes.insert(0,"0")
	var seconds : String = str( int(Seconds) % 60 )
	if seconds.length() < 2:
		#Adding a Zero if minutes is less than double digits
		seconds = seconds.insert(0,"0")
	LRCTimestamp += minutes + ":"
	LRCTimestamp += seconds + "."
	
	#sub second value
	LRCTimestamp += timestamp_in_millsecs.substr(timestamp_in_millsecs.length()-3, 2) + "]"
	return LRCTimestamp
