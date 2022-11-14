class_name ImageLoader extends Reference

enum DisplayFlag{
	SONGSPACE = 0,
	PLAYER = 1,
	IMAGE_VIEW = 2,
	PURE = 3,
}


static func webp_to_png(var webp_data : PoolByteArray) -> PoolByteArray:
	var img : Image = Image.new()
	if img.load_webp_from_buffer(webp_data) != OK:
		Global.root.message("LOADING WEBP IMAGE FROM BUFFER" ,SaveData.MESSAGE_ERROR)
		return PoolByteArray();
	return img.save_png_to_buffer()


static func get_cover(var path : String, var playlist_name : String = "", var ImageSize : Vector2 = Vector2.ZERO) -> ImageTexture:
	#Retrieving Image from the File itself and returning is as a usable ImageTexture
	#If this process fails a standard StreamTexture will be returned
	var img : Image = Image.new()
	var texture
	var dir : Directory = Directory.new()
	if dir.file_exists(path):
		texture = ImageTexture.new()
		var img_data : PoolByteArray = SaveData.load_buffer(path)
		var image_header : String = SaveData.load_buffer(path,512).hex_encode()
		match FormatChecker.identify_image_file(image_header):
			0:
				if !img.load_jpg_from_buffer(img_data) == OK:
					return get_cover("")
			1:
				if !img.load_png_from_buffer(img_data) == OK:
					return get_cover("")
			2:
				if !img.load_webp_from_buffer(img_data) == OK:
					return get_cover("")
			-1:
				#intentionally loads this function with wrong path to get an "empty image"
				texture = get_cover("")
		
		if ImageSize != Vector2.ZERO:
			var AspectRatio : float = img.get_size().aspect()
			ImageSize *= AspectRatio
			img.resize( int(ImageSize.x * AspectRatio) , int( ImageSize.y ) )
		img = squarify_image(img)
		texture.create_from_image(img,Texture.FLAGS_DEFAULT)
	else:
		#if the given path to an image doesn't exist
		if playlist_name == "AllSongs" or playlist_name == "":
			#if no playlist was specifed on function call
			var std_cover_path : String = SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "StandardSongCover")
			if std_cover_path != "" and Directory.new().file_exists(std_cover_path):
				#Loads the std Cover Image Specified in the Settings
				texture = get_cover( SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "StandardSongCover") )
			else:
				#Loads the true std cover -> when no std cover was selected
				texture = load("res://src/Assets/Icons/White/Audio/MusicNotes/icons8-musik-1000.png")
		else:
			var playlist_cover_path : String = Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + playlist_name + ".png"
			texture = get_cover(playlist_cover_path)
	return texture


static func create_image_from_data(var data : PoolByteArray):
	if data.size() == 0:
		return null
	var new_image : Image = Image.new()
	match FormatChecker.identify_image_file( data.subarray(0,128).hex_encode() ):
			0:
				if new_image.load_jpg_from_buffer(data) != OK:
					Global.root.message("LOADING JPG FROM BUFFER" ,SaveData.MESSAGE_ERROR)
			1:
				if new_image.load_png_from_buffer(data) != OK:
					Global.root.message("LOADING PNG FROM BUFFER" ,SaveData.MESSAGE_ERROR)
			2:
				if new_image.load_webp_from_buffer(data) != OK:
					Global.root.message("LOADING WebP FROM BUFFER" ,SaveData.MESSAGE_ERROR)
			_:
				return null
	return new_image


static func image_to_texture(var img : Image):
	var texture : ImageTexture = ImageTexture.new()
	texture.create_from_image(img)
	return texture


static func get_image_mime_type(var cover_path : String) -> String:
	match FormatChecker.identify_image_file( SaveData.load_buffer(cover_path, 256).hex_encode() ):
		0:
			return "image/jpeg";
		1:
			return "image/png";
		2:
			return "image/webp";
		_:
			return "";


static func get_covercache_texture(var coverhash : String, var playlist_name : String = ""):
	var data : PoolByteArray = SaveData.load_buffer( Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + coverhash + ".png")
	var img : Image = create_image_from_data(data)
	
	if !img:
		if playlist_name != "":
			return get_cover(Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + playlist_name + ".png")
		return load("res://src/Assets/Icons/White/Audio/MusicNotes/icons8-musik-1000.png")
	else:
		img = squarify_image(img)
	return image_to_texture(img)


static func squarify_image(var img : Image) -> Image:
	# squarifying the Cover
	# extracting the biggest square out of the given image
	var new_rect : Rect2 = Rect2()
	new_rect.size = Vector2(img.get_width() / img.get_size().aspect(), img.get_height())
	
	# fixing the issue of one invalid line of pixels being shown at the bottom in some cases
	new_rect.size.y -= 1
	
	new_rect.position = Vector2(
		(img.get_size() / 2.0) - (new_rect.size / 2.0)
	)
	
	# extracting calculated square
	return img.get_rect(new_rect)
