class_name OptionsMenu
extends Node


@export var _graphics_preset_option_view: OptionsMenuOptionView
@export var _save_settings_button: Button

const _graphics_option_presets: Dictionary[String, int] = {
	"Ultra": OptionsData.GraphicsOptionsPresets.HIGH,
	"High": OptionsData.GraphicsOptionsPresets.MEDIUM,
	"Low": OptionsData.GraphicsOptionsPresets.LOW,
	"Minimum": OptionsData.GraphicsOptionsPresets.MINIMUM,
}

var _options_data: OptionsData

func _init() -> void:
	SaveDataManager.load_options_data_from_file()
	_options_data = SaveDataManager.get_options_data()

func _ready() -> void:
	Global.in_options_menu = true
	
	_setup_option_views()
	_save_settings_button.pressed.connect(_on_save_settings_button_pressed)
	
func _setup_option_views() -> void:
	_graphics_preset_option_view.set_label("Graphics Preset")
	_graphics_preset_option_view.set_dropdown_options(_graphics_option_presets)
	_graphics_preset_option_view.set_selected_dropdown_option((_options_data.graphics_preset as int))
	_graphics_preset_option_view.changed_option.connect(_on_graphics_preset_option_view_changed_option)

func _on_graphics_preset_option_view_changed_option(index: int) -> void:
	_options_data.graphics_preset = (index as OptionsData.GraphicsOptionsPresets) 
	_options_data.apply_options()

func _on_save_settings_button_pressed() -> void:
	SaveDataManager.save_options_data_to_file()
	Global.in_options_menu = false
	queue_free()
