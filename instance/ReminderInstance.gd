extends HBoxContainer


onready var ReminderCheck = $ReminderCheck

signal ReminderCheck_toggled(text, button_pressed)
signal Delete_pressed(text)


func _on_ReminderCheck_toggled(button_pressed):
	emit_signal("ReminderCheck_toggled", ReminderCheck.get_text(), button_pressed)


func set_text(text):
	ReminderCheck.set_text()


func _on_Delete_pressed():
	emit_signal("Delete_pressed", ReminderCheck.get_text())
