class_name OptionsData
extends Resource

enum GraphicsOptionsPresets {
	HIGH,
	MEDIUM,
	LOW,
	MINIMUM,
}

@export var graphics_preset: GraphicsOptionsPresets = GraphicsOptionsPresets.HIGH

enum CrosshairOption {
	On,
	Off,
}
	
@export var crosshair_option: CrosshairOption = CrosshairOption.On

enum CameraMotionOption {
	On,
	Off,
}
	
@export var camera_motion_option: CameraMotionOption = CameraMotionOption.On

func apply_options() -> void:	
	Events.game_options_changed.emit(self)
