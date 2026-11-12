class_name ItemHoverTooltip
extends PanelContainer

@export var name_label: RichTextLabel
@export var rarity_label: RichTextLabel
@export var rarity_color_rect: ColorRect
@export var active_indicator: Control
@export var cooldown_label: RichTextLabel
@export var passive_indicator: Control
@export var description_label: RichTextLabel

var item: Item = null:
	set(new_item):
		item = new_item

		if item == null:
			hide()
		else:
			show()

			name_label.text = "[b]%s[/b]" % item.name
			rarity_label.text = "[b]%s[/b]" % item.rarity_name.to_upper()
			rarity_color_rect.color = item.rarity_color
			description_label.text = item.description_at_levels[item.item_level]

			if item.is_active_item:
				active_indicator.show()
				cooldown_label.text = "(%ss cooldown)" % item.active_item_cooldown_at_levels[item.item_level]
				passive_indicator.hide()
			else:
				active_indicator.hide()
				passive_indicator.show()


func _ready() -> void:
	item = null


func _physics_process(_delta: float) -> void:
	if visible:
		position = get_viewport().get_mouse_position()
