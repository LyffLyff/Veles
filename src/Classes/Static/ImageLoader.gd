extends Reference

class_name ImageLoader


#ENUMS
enum DisplayFlag{
	SongsSpace = 0,
	Player = 1,
	ImageView = 2,
	Pure = 3
}


static func WebpToPng(var WebpData : PoolByteArray) -> PoolByteArray:
	var img : Image = Image.new()
	if img.load_webp_from_buffer(WebpData) != OK:
		Global.root.Message("LOADING WEBP IMAGE FROM BUFFER" ,SaveData.MESSAGE_ERROR)
		return PoolByteArray();
	return img.save_png_to_buffer()


static func GetCover(var path : String,var PlaylistName : String = "",var ImageSize : Vector2 = Vector2.ZERO) -> ImageTexture:
	#Retrieving Image from the File itself and returning is as a usable ImageTexture
	#If this process fails a standard StreamTexture will be returned
	var img : Image = Image.new()
	var texture
	var dir : Directory = Directory.new()
	if dir.file_exists(path):
		texture = ImageTexture.new()
		var img_data : PoolByteArray = SaveData.LoadBuffer(path)
		var image_header : String = SaveData.LoadBuffer(path,512).hex_encode()
		match FormatChecker.ReturnImgFormat(image_header):
			0:
				if !img.load_jpg_from_buffer(img_data) == OK:
					return GetCover("")
			1:
				if !img.load_png_from_buffer(img_data) == OK:
					return GetCover("")
			2:
				if !img.load_webp_from_buffer(img_data) == OK:
					return GetCover("")
			-1:
				#intentionally loads this function with wrong path to get an "empty image"
				texture = GetCover("")
		
		if ImageSize != Vector2.ZERO:
			var AspectRatio : float = img.get_size().aspect()
			ImageSize *= AspectRatio
			img.resize( int(ImageSize.x * AspectRatio) , int( ImageSize.y ) )
		img = SquarifyImage(img)
		texture.create_from_image(img,Texture.FLAGS_DEFAULT)
	else:
		#if the given path to an image doesn't exist
		if PlaylistName == "AllSongs" or PlaylistName == "":
			#if no playlist was specifed on function call
			var StdCoverPath : String = SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "StandardSongCover")
			if StdCoverPath != "" and Directory.new().file_exists(StdCoverPath):
				#Loads the std Cover Image Specified in the Settings
				texture = GetCover( SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "StandardSongCover") )
			else:
				#Loads the true std cover -> when no std cover was selected
				texture = load("res://src/Assets/Icons/White/Audio/MusicNotes/icons8-musik-1000.png")
		else:
			print("get playlist coiver")
			var playlist_cover_path : String = Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + PlaylistName + ".png"
			texture = GetCover(playlist_cover_path)
	return texture


static func CreateImageFromData(var data : PoolByteArray):
	if data.size() == 0:
		return null
	var NewImage : Image = Image.new()
	match FormatChecker.ReturnImgFormat( data.subarray(0,128).hex_encode() ):
			0:
				if NewImage.load_jpg_from_buffer(data) != OK:
					Global.root.Message("LOADING JPG FROM BUFFER" ,SaveData.MESSAGE_ERROR)
			1:
				if NewImage.load_png_from_buffer(data) != OK:
					Global.root.Message("LOADING PNG FROM BUFFER" ,SaveData.MESSAGE_ERROR)
			2:
				if NewImage.load_webp_from_buffer(data) != OK:
					Global.root.Message("LOADING WebP FROM BUFFER" ,SaveData.MESSAGE_ERROR)
			_:
				return null
	return NewImage


static func CreateTextureFromImage(var CoverImg : Image):
	var Cover : ImageTexture = ImageTexture.new()
	Cover.create_from_image(CoverImg)
	return Cover


static func GetImageMimeType(var CoverPath : String) -> String:
	match FormatChecker.ReturnImgFormat( SaveData.LoadBuffer(CoverPath, 256).hex_encode() ):
		0:
			return "image/jpeg";
		1:
			return "image/png";
		2:
			return "image/webp";
		_:
			return "";


static func GetCoverCacheImageTexture(var CoverHash : String, var PlaylistName : String = ""):
	var data : PoolByteArray = SaveData.LoadBuffer( Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + CoverHash + ".png")
	var img : Image = CreateImageFromData(data)
	
	if !img:
		if PlaylistName != "":
			return GetCover(Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + PlaylistName + ".png")
		return load("res://src/Assets/Icons/White/Audio/MusicNotes/icons8-musik-1000.png")
	else:
		img = SquarifyImage(img)
	return CreateTextureFromImage(img)


static func SquarifyImage(var img : Image) -> Image:
	#Squarifying the Cover
	#Extracting the Biggest Square out of the given Image
	var NewSize : Vector2 = Vector2(img.get_width() / img.get_size().aspect(), img.get_height())
	var LeftPos : Vector2 = Vector2(
		(img.get_size() / 2.0) - (NewSize / 2.0)
	)
	img = img.get_rect( Rect2(LeftPos,NewSize) )
	return img
