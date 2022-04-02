extends Control


onready var Calendar = $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer2/ItemList


var calendar_padding = 0


func _ready():
	var time = OS.get_datetime()
	var padding_needed = get_first_weekday(time["day"],time["weekday"]) -1
	
	for pad in range(padding_needed):
		Calendar.add_item( "", null, false )
		Calendar.move_item( Calendar.get_item_count()-1, 7 )
		calendar_padding += 1
	
	for excess_days in range(get_number_of_days(time["month"],time["year"]), 31):
		Calendar.remove_item( Calendar.get_item_count()-1 )


func get_first_weekday(current_day, current_weekday):
	# efficiency doesn't matter anyway
	var working_day = current_day
	var working_weekday = current_weekday
	while working_day > 1:
		working_day -= 1
		working_weekday -= 1
		if working_weekday == 0:
			working_weekday = 7
	return working_weekday


func get_number_of_days(current_month, current_year):
	match current_month:
		1:
			return 31
		2:
			if current_year % 4 != 0:
				return 28
			elif current_year % 100 != 0:
				return 29
			elif current_year % 400 != 0:
				return 28
			else:
				return 29
		3:
			return 31
		4:
			return 30
		5:
			return 31
		6:
			return 30
		7:
			return 31
		8:
			return 31
		9:
			return 30
		10:
			return 31
		11:
			return 30
		12:
			return 31
