extends RichTextLabel
# a script that holds texts that are encoded using BBCodes 
# and are used as the Infotexts in the Info Suboption

var general_infos : Dictionary = {
	"Introduction" : 
		"""
	[i]Introduction[/i]
	
	Veles is an Open Source and Free Application created by LyffLyff
	and licensed und the GNU General Public License v3.0, it can be used to play, organize, download and tag music files.
	This application does not gather and therefore share any of your data with third parties.
		""",
	"Source Code" : 
		"""
	[i]Source Code[/i]
	
	Since Veles is licensed under the GPL 3.0 License, it's code is therefore openly available.
	Github Project:
[table=2][cell]	Veles:[/cell][cell][url]https://github.com/LyffLyff/Veles[/url][/cell]
[cell]	VelesNative:[/cell][cell][url]https://github.com/LyffLyff/VelesNative/tree/veles_native_dev[/url][/cell]
"""
}
var playback : Dictionary = {
	"Supported Formats" : 
	"""
	[i]Supported Formats[/i]
	
	1.) .mp3
	2.) .ogg
	3.) .wav
	
	These 3 formats are fully supported by Veles, even though other formats may be recognized
	by reading some of it's metadata and being displayed under all songs, it won't be possible for them
	to be played. For Information on what formats can be tagged, go to the Tagging Subinfos
	"""
}
var playlists : Dictionary = {
	"Playlists" :
	"""
	[i]Playlists[/i]
	
	Normal Playlists in Veles can hold manually added songs.
	Each song has to be added by manually adding it to the specific playlist.
	Right Click On Song -> Add To Playlist
""",
	"Smart Playlist" : 
	"""
	[i]Smart Playlists[/i]
	
	Smart Playlists are created by giving certain conditions a song must follow to be automatically added to it.
	It is NOT possible to manually add songs to this type of Playlist!
	Since a smart playlist is created during runtime it may need a bit more of time to load compared to normal playlists.
	"""
}
var tagging : Dictionary = {
	"Supported Formats" : 
	"""
	[i]Supported Formats:[/i]
	
	Veles has different tiers of support for different fileformats when it comes to tagging and metadata changes.
	In this Infotext every supported fileformat will be highlighted and how you can change it's metadata.
	
	[i]MP3:[/i]
	
	The most common format for modern day music listeners is the MP3 format. Therefore, Veles fully supports it, by 
	integrating the official ID3 Tags, that allow you to:
	1.) Change Text Tags (Title, Artist, Comment,....)
	2.) Covers
	3.) Lyrics (Unsynched and Synched)
	
	Veles also uses some of the frames, which you can read about [url=https://id3.org/id3v2.3.0]HERE[/url].
	Some include:
		
	.) Popularimeter [POPM], to save Songratings
	.) Synchronised lyrics/text [SYLT], to save synched Lyrics
	.) Unsychronised lyrics/text transcription [USLT], to save unsynched lyrics
	It is my goal to add as many specific frames as possible to Veles to be able to organize your collection of mp3 files in the best ways possible.
	
	[i]OGG-VORBIS:[/i]
	
	Another very common format for playing music is the OGG-Vorbis format. 
	OGG-Vorbis uses the Xiph-Comment for it's metadata.
	Since, this format support for metadata inclusion in files is way more messy and less uniform across the world,
	the options in Veles are smaller compared to mp3 files.
	1.) Change Text Tags (Title, Artist, Comment,....)
	2.) Covers
	
	For the time Being Veles has no support for Lyrics or any other type of metdata, except for the two above.
	
	[i]WAV / RIFF WAVE:[/i]
	
	Even though the need for tagging on .wav files may be disputed, Veles still supports it by integrating the ID3 type tags.
	1.) Change Text Tags (Title, Artist, Comment,....)
	2.) Covers
	3.) Lyrics (Unsynched and Synched)
	
	[i]FLAC:[/i]
	
	The FLAC format is a favourite among music enthusiasts, since it has the positives of mp3 files while having lossless compression.
	1.) Change Text Tags (Title, Artist, Comment,....)
	2.) Covers
	
	[i]Other Formats:[/i]
	
	Each of the now specified music formats simply support the setting of simple text tags.
	
	1.) APE
	2.) ASF
	3.) OGG-OPUS
	4.) OGG-SpeeX
	5.) S3M
	6.) WAVPACK / WV
	7.) XM
	8.) TrueAudio
	9.) MPC
	""",
	"Multitagging" : 
"""
	[i]Multitagging:[/i]

	By either adding multiple songs or selecting multiple songs on a playlist using the SHIFT-Key,
	Veles will allow you to tag multiple songs at the same time.
	This will be done by overwriting the tags of all the selected songs with the same tags.
	The Displayed Cover and Text Tags will be from the first selected song.
"""
}
var lyrics : Dictionary = {
	
}
var downloads : Dictionary = {
	"General" :
		"""
	[i]General[/i]
		
	Using the Download feature of this Software requires the Download of two executables. 
	You can find tutorial on how and where to install them properly on on of the next Suboptions.
	Also You can find a links citing all the supported Pages and limitations of such.
	
	Lastly, this Downloader and corresponding Converter is in no way my property and is not developed by me, 
	if any problenms occur during the download of certain files, I will not take any responsibilty.
		""",
	"Setup":
		"""
	[i]Setup Download:[/i]
	
	For The Download Section of Veles to work you need to install two .exe files. For that follow the Links down below.
	
	1.) [url=https://ffmpeg.org/download.html#build-wi ndows]Download Here[/url] for your specifc OS, only the ones with GPL and without SHARED in their title are valid. 
	2.) Extract the dowloaded .zip file so that multiple .exe file are visible
	3.) Move those .exe files into [url=user://]THIS[/url] folder
	
	If all of these steps are finished you should be able to use the downloads subsection.
		""",
	"Supported Pages" : 
		"""
	[i]Supported Pages[/i]
	
	To find the supported Pages click on the Link Below:
	[url]https://github.com/blackjack4494/yt-dlc/blob/master/docs/supportedsites.md[/url]
		"""
}
var statistics : Dictionary = {
	"General" : 
		"""
	[i]General:[/i]
	
	When playing any audio file Veles tracks it and adds it to the stats.
	In total there can be 3 plays accounted when playing a song:
	
	1st: 30sec 
	2nd: 60sec
	3rd: 2min
"""
}
var credits : Dictionary = {
	"Creator" : 
"""
	[i]Main Creator:[/i]
	
	Sebastian Hinterberger
	LyffLyff

	Itch.io: [url]https://lyfflyff.itch.io/[/url]
	Github: [url]https://github.com/LyffLyff[/url]
		""",
	"Assets" : 
		"""
	[i]Assets:[/i]

	Icons by:
	[url]https://roundicons.com/[/url], License: [url]https://roundicons.com/usage-license/[/url]
	'Kenney Game Icons' Pack, CC0 1.0, [url]https://www.kenney.nl/assets/game-icons[/url]
	Color picker icons created by AriqStock:[url] https://www.flaticon.com/free-icons/color-picker[/url]
		""",
	"Software" :
		"""
	[i]Software[/i]
	
	Copyright (c) 2007-2021 Juan Linietsky, Ariel Manzur. Copyright (c) 2014-2022 Godot Engine contributors.
	Portions of this software are copyright ©2021 The FreeType Project (www.freetype.org). All rights reserved.
	""",
	"Fonts" : 
		"""
	[i]Montserrat[/i]
	-Copyright 2011 The Montserrat Project Authors (https://github.com/JulietaUla/Montserrat)
""",
}
var licenses : Dictionary = {
	"Godot" : 
		""" 
	[i]Godot License:[/i]
	
	This Software was created using the Godot Engine
	[url]https://godotengine.org/license[/url]
		""",
	"GNU GPLv3 " : 
		""" 
	[i]GNU GPLv3[/i]
	
	[url]https://choosealicense.com/licenses/gpl-3.0/[/url]
		"""
}
var shortcuts : Dictionary = {
	"Global" : 
"""
	[i]Global Shortcuts[/i]
	[table=2]
[cell]	Toggle Pause:[/cell][cell]SPACE[/cell]
[cell]	Toggle Shuffle:[/cell][cell]S[/cell]
[cell]	Toggle Replay:[/cell][cell]R[/cell]
[cell]	Toggle Image View:[/cell][cell]I[/cell]
[/table]
""",
"Options" : 
"""
	[i]Options Shortcuts[/i]
	[table=2]
[cell]	Load Playlists:[/cell][cell]L + P[/cell]
[cell]	Load All Songs:[/cell][cell]L + O[/cell]
[cell]	Load Select Folders:[/cell][cell]L + F[/cell]
[cell]	Load Artists:[/cell][cell]L + A[/cell]
[cell]	Load Change Tags:[/cell][cell]L + C[/cell]
[cell]	Load Downloads:[/cell][cell]L + D[/cell]
[cell]	Load Lyrics:[/cell][cell]L + Y[/cell]
[cell]	Load Stats:[/cell][cell]L + S[/cell]
[cell]	Load Settings:[/cell][cell]L + E[/cell]
[cell]	Load Infos:[/cell][cell]L + I[/cell]
[/table]
""",
	"Lyrics Editor" : 
"""
	[i]Lyrics Editor Shortcuts[/i]
	[table=2]
[cell]	Save:[/cell][cell]CTRL + S[/cell]
[cell]	Save As:[/cell][cell]CTRL + SHIFT + S[/cell]
[cell]	Add Verse[/cell][cell]V + A[/cell]
[cell]	Cut Last Verse[/cell][cell]V + D[/cell]
[cell]	Add Timestamp[/cell][cell]T + A[/cell]
[cell]	Cut Last Timestamp[/cell][cell]T + D[/cell]
[cell]	Append Timestamp at song position[/cell][cell]P[/cell]
[/table]
"""
}
var infos : Dictionary = {
	"GeneralInfos" : general_infos,
	"Shortcuts" : shortcuts,
	"PlayingMusic" : playback,
	"Playlists" : playlists,
	"Tags" : tagging,
	"Lyrics" : lyrics,
	"Downloads" : downloads,
	"Statistics" : statistics,
	"Credits" : credits,
	"Licenses" : licenses,
}
