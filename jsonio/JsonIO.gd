extends Node


func load_json_file(file_path):
	var file = File.new()
	var out = 0
	
	if file.file_exists(file_path):
		file.open(file_path, File.READ)
		var text = file.get_as_text()
		
		if not validate_json(text): # no error message
			out = parse_json(text)
		else:
			print("JsonIO - \"%s\" load NOT successful" % file_path)
			out = 1
	
	else:
		print("JsonIO - \"%s\" does not exist" % file_path)
		out = -1
	
	file.close()
	return out


func save_json_file(file_path, data):
	var file = File.new()
	var out = 0
	
	file.open(file_path, File.WRITE)
	
	if not validate_json( to_json(data) ): # no error message
		file.store_line( to_json(data) )
	else:
		print("JsonIO - \"%s\" invalid data" % file_path)
		out = 1
	
	file.close()
	return out

