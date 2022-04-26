extends Control


const REMINDER = preload("res://instance/ReminderInstance.tscn")


onready var JsonIO = $JsonIO
onready var Calendar = $Margin/VBox/HBoxBody/VBoxLeft/Calendar
onready var ChangeStar = $Margin/VBox/HBoxHeader/ChangeStar
onready var NoteEditor = $Margin/VBox/HBoxBody/VBoxCentre/NoteEditor
onready var VBoxReminders = $Margin/VBox/HBoxBody/VBoxLeft/Scroll/VBoxReminders


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
		selected_filename = "user://%04d-%02d-%02d.json" % [selected_year, selected_month, selected_day]
		
		load_data()


func load_data():
	var data = JsonIO.load_json_file(selected_filename)
	if typeof(data) == TYPE_INT:
		if data == 1:
			#uh oh. something's wrong with the save file
			pass
		elif data == -1:
			#no existing file. that's probably fine
			NoteEditor.set_text("")
	else:
		#data is a dictionary, yay
		NoteEditor.set_text( data["notes"] )


func _on_ReminderInstance_ReminderCheck_toggled(text, button_pressed):
	save_reminder_data(text, button_pressed)


func _on_NoteEditor_text_changed():
	set_file_changed()


func _on_ButtonSave_pressed():
	#sooo...
	#maybe a confirmation popup goes here and then
	if has_file_changed:
		save_notes_data()
		has_file_changed = false
		ChangeStar.set_visible(false)


func save_notes_data():
#	var data = {
#		"year": selected_year,
#		"month": selected_month,
#		"day": selected_day,
#		"notes": NoteEditor.get_text(),
#		"events": null,
#		"reminders": null
#	}
	var data = JsonIO.load_json_file(selected_filename)
	if typeof(data) == TYPE_INT:
		#something has gone horribly wrong
		pass
	else:
		data["notes"] = NoteEditor.get_text()
		JsonIO.save_json_file(selected_filename, data)


func new_reminder(text):
	var data = JsonIO.load_json_file(selected_filename)
	if typeof(data) == TYPE_INT:
		#something has gone horribly wrong
		pass
	else:
		if data["reminders"].has(text):
			#already a reminder by this name
			pass
		else:
			var new = REMINDER.instance()
			new.set_text(text)
			new.connect("ReminderCheck_toggled", self, "_on_ReminderInstance_ReminderCheck_toggled")
			new.connect("Delete_pressed", self, "_on_ReminderInstance_Delete_pressed")
			VBoxReminders.add_child(new)
			
			data["reminders"][text] = false
			JsonIO.save_json_file(selected_filename, data)


func save_reminder_data(reminder_text, reminder_state):
	var data = JsonIO.load_json_file(selected_filename)
	if typeof(data) == TYPE_INT:
		#something has gone horribly wrong
		pass
	else:
		data["reminders"][reminder_text] = reminder_state
		JsonIO.save_json_file(selected_filename, data)


func _on_ReminderInstance_Delete_pressed(text):
	for each_child in VBoxReminders.get_children():
		if each_child.get_text() == text:
			each_child.queue_free()
			delete_reminder_data(text)


func delete_reminder_data(text):
	var data = JsonIO.load_json_file(selected_filename)
	if typeof(data) == TYPE_INT:
		#something has gone horribly wrong
		pass
	else:
		data["reminders"].erase(text)
		JsonIO.save_json_file(selected_filename, data)
	
