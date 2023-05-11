class_name ImageLoader extends Object

signal covers_loaded
signal image_resized

enum DisplayFlag{
	SONGSPACE = 0,
	PLAYER = 1,
	IMAGE_VIEW = 2,
	PURE = 3,
}

enum ImageTypes {
	NONE = 0,
	PLAYLIST_HEADER = 1,
	IMAGE_VIEW_COVER = 2,
	USER_PROFILE = 3,
	ARTIST = 4
	COVER = 5
}


const std_cover : StreamTexture = preload("res://src/Assets/Icons/White/Audio/MusicNotes/music_note_500px.png")
const std_cover_low_res : StreamTexture = preload("res://src/Assets/Icons/White/Audio/MusicNotes/music_note_128px.png")

static func webp_to_png(var webp_data : PoolByteArray) -> PoolByteArray:
	var img : Image = Image.new()
	if img.load_webp_from_buffer(webp_data) != OK:
		Global.message("LOADING WEBP IMAGE FROM BUFFER" ,Enumerations.MESSAGE_ERROR)
		return PoolByteArray();
	return img.save_png_to_buffer()


static func get_cover(var path : String,  var image_type : int = ImageTypes.NONE, var playlist_name : String = "", var image_size : Vector2 = Vector2.ZERO) -> ImageTexture:
	# Retrieving Image from the File itself and returning is as a usable ImageTexture
	# If this process fails a standard StreamTexture will be returned
	var img : Image = Image.new()
	var texture
	var dir : Directory = Directory.new()
	if dir.file_exists(path):
		texture = ImageTexture.new()
		var img_data : PoolByteArray = SaveData.load_buffer(path)
		var image_header : String = img_data.subarray(0, 32).hex_encode()
		match FormatChecker.identify_image_file(image_header):
			0:
				if !img.load_jpg_from_buffer(img_data) == OK:
					return get_cover("", image_type)
			1:
				if !img.load_png_from_buffer(img_data) == OK:
					return get_cover("", image_type)
			2:
				if !img.load_webp_from_buffer(img_data) == OK:
					return get_cover("", image_type)
			-1:
				#intentionally loads this function with wrong path to get an "empty image"
				return get_cover("", image_type)
		
		img = squarify_image(img)
		
		if image_size != Vector2.ZERO:
			var aspect_ratio : float = img.get_size().aspect()
			image_size *= aspect_ratio
			img.resize(int(image_size.x * aspect_ratio), int(image_size.y), Image.INTERPOLATE_LANCZOS)
		
		texture.create_from_image(img, Texture.FLAGS_DEFAULT)
	else:
		# if the given path to an image doesn't exist
		match image_type:
			ImageTypes.NONE: 
				texture = std_cover
			ImageTypes.USER_PROFILE:
				texture = load("res://src/Assets/Icons/White/Users/empty_profile_img_96px.png")
			ImageTypes.ARTIST:
				texture = load("res://src/Assets/Icons/White/Users/Personal_Image_120px.png")
			ImageTypes.COVER:
				if playlist_name == "AllSongs" or playlist_name == "":
					# if no playlist was specifed on function call
					var std_cover_path : String = SettingsData.get_setting(SettingsData.SONG_SETTINGS, "StandardSongCover")
					if std_cover_path != "" and Directory.new().file_exists(std_cover_path):
						# Loads the std cover_edit Image Specified in the Settings
						texture = get_cover(std_cover_path, ImageTypes.NONE)
					else:
						# Loads the true std cover -> when no std cover was selected
						if image_size == Vector2.ZERO or image_size.x > 128:
							texture = std_cover
						else:
							texture = std_cover_low_res
				else:
					var playlist_cover_path : String = Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_name + ".png"
					texture = get_cover(playlist_cover_path, ImageTypes.PLAYLIST_HEADER)
			ImageTypes.PLAYLIST_HEADER:
				if playlist_name == "AllSongs" or playlist_name == "":
					texture = load("res://src/Assets/Icons/White/Users/image_120px.png")
				else:
					var playlist_cover_path : String = Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_name + ".png"
					texture = get_cover(playlist_cover_path, ImageTypes.PLAYLIST_HEADER)
	return texture


static func create_image_from_data(var data : PoolByteArray):
	if data.size() == 0:
		return null
	var new_image : Image = Image.new()
	var error_code : int = -1
	match FormatChecker.identify_image_file(data.subarray(0, 512 * int(!data.empty())).hex_encode()):
			0:
				error_code = new_image.load_jpg_from_buffer(data)
			1:
				error_code = new_image.load_png_from_buffer(data)
			2:
				error_code = new_image.load_webp_from_buffer(data)
			_:
				return null
	if error_code != OK:
		Global.message("Unable to Load Image from Buffer", Enumerations.MESSAGE_ERROR)
	return new_image


static func image_to_texture(var img : Image):
	var texture : ImageTexture = ImageTexture.new()
	if !img.is_empty():
		texture.create_from_image(img)
	return texture


static func identify_image_mime_type(var cover_path : String) -> String:
	return get_image_mime_type(FormatChecker.identify_image_file(SaveData.load_buffer(cover_path, 256).hex_encode()))



static func get_data_mime_type(var cover_header : PoolByteArray) -> String:
	return get_image_mime_type(FormatChecker.identify_image_file(cover_header.hex_encode()))


static func get_image_mime_type(var file_id : int) -> String:
	match file_id:
		0:
			return "image/jpeg";
		1:
			return "image/png";
		2:
			return "image/webp";
		_:
			return "";


static func get_covercache_texture(var coverhash : String, var playlist_name : String = ""):
	var data : PoolByteArray = SaveData.load_buffer(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + coverhash)
	var img : Image = create_image_from_data(data)
	
	if !img:
		if playlist_name != "":
			return get_cover(Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_name + ".png", ImageTypes.PLAYLIST_HEADER)
		return std_cover
	else:
		img = squarify_image(img)
	return image_to_texture(img)


static func squarify_image(var img : Image) -> Image:
	# squarifying the cover_edit
	# extracting the biggest square out of the given image
	var new_rect : Rect2 = Rect2()
	
	# get biggest square out of image
	if img.get_width() > img.get_height():
		new_rect.size = Vector2(img.get_height(), img.get_height())
	else:
		new_rect.size = Vector2(img.get_width(), img.get_width())
	
	new_rect.position = Vector2((img.get_size() / 2.0) - (new_rect.size / 2.0))
	
	# extracting calculated square out of image
	if img.get_width() > 0:
		return img.get_rect(new_rect)
	else:
		return img


static func resize_texture(var original_texture : Texture, var new_size : Vector2) -> ImageTexture:
	var new_texture : ImageTexture = ImageTexture.new()
	var new_img : Image = original_texture.get_data()
	if new_img != null:
		new_img.resize(int(new_size.x), int(new_size.y), Image.INTERPOLATE_LANCZOS)
		new_texture.create_from_image(new_img, Texture.FLAGS_DEFAULT)
	return new_texture


func get_embedded_covers(var src_path : String) -> Array:
	# returns all the covers within a given file as an Array of Textures
	# also returns the corresponding path of the covers origin -> Threads
	var cover_data : Array = Tagging.new().get_embedded_covers(src_path)
	var loaded_covers : Array = []
	for i in range(len(cover_data)):
		loaded_covers.push_back(self.image_data_2_texture(cover_data[i]))
	self.call_deferred("emit_signal", "covers_loaded")
	return [loaded_covers, src_path]


func get_embedded_cover(var src_path : String):
	var temp_cover : PoolByteArray = Tagging.new().get_embedded_cover(src_path)
	if temp_cover.size() == 0:
		return null
	return image_data_2_texture(temp_cover)


func image_data_2_texture(var image_data : PoolByteArray) -> Texture:
	var img : Image = create_image_from_data(image_data)
	img = squarify_image(img)
	return image_to_texture(img)
