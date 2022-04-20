extends Control


onready var JsonIO = $JsonIO
onready var Calendar = $Margin/VBox/HBoxBody/VBoxLeft/Calendar
onready var ChangeStar = $Margin/VBox/HBoxHeader/ChangeStar


var selected_year = 2022
var selected_month = 04
var selected_day = 16
var selected_filename = ""

var has_file_changed = false


var calendar_padding = 0 # this isn't used for anything? what was i thinking


func _ready():
	#why are Items "selectable" even when they're "disabled"? what nonsense
	for index in range(7):
		Calendar.set_item_selectable(index, false)
	
	
	var time = OS.get_datetime()
	
	#messing with the time for testing
	#time["month"] = 5
	#time["day"] = 1
	#time["weekday"] = 7
	
	
	var padding_needed = get_first_weekday(time["day"],time["weekday"]) -1
	
	for pad in range(padding_needed):
		Calendar.add_item( "", null, false )
		Calendar.move_item( Calendar.get_item_count()-1, 7 )
		calendar_padding += 1
	
	for excess_days in range(get_number_of_days(time["month"],time["year"]), 31):
		Calendar.remove_item( Calendar.get_item_count()-1 )
	
	var current_index = get_day_index(time["day"])
	Calendar.select( current_index )
	Calendar.emit_signal("item_selected", current_index) #doesn't happen with select()


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


func get_day_index(current_day):
	for index in range( Calendar.get_item_count() ):
		if int(Calendar.get_item_text(index)) == current_day:
			return index


func get_number_of_days(current_month, current_year): #30 days hath september...
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


func set_file_changed():
	has_file_changed = true
	ChangeStar.set_visible(true)

func _on_Calendar_item_selected(index):
	if Calendar.is_item_selectable(index):
		selected_day = int(Calendar.get_item_text(index))
		selected_filename = "%04d-%02d-%02d.json" % [selected_year, selected_month, selected_day]
		JsonIO.load_json_file(selected_filename)


func _on_ReminderCheck_toggled(button_pressed):
	set_file_changed()


func _on_NoteEditor_text_changed():
	set_file_changed()
