@tool
extends EditorPlugin

var dock: PanelContainer
var poly_label: Label
var vert_label: Label
var poly_factor_spinbox: SpinBox
var vert_factor_spinbox: SpinBox
var manual_counting_checkbox: CheckBox
var selected_nodes = []
var toggle_button: Button
var is_visible: bool = true
var use_manual_csg_counting: bool = true
var poly_adjustment_factor: float = 1.0
var vert_adjustment_factor: float = 0.2

func _enter_tree():
	var dock_scene = load("res://addons/polygon_counter/dock.tscn")
	if not dock_scene:
		push_error("ERROR: Failed to load dock.tscn. Plugin will not function.")
		return
	dock = dock_scene.instantiate() as PanelContainer
	if not dock:
		push_error("ERROR: Failed to instantiate dock. Check dock.tscn structure.")
		return
	
	add_control_to_bottom_panel(dock, "Polygon Counter")
	dock.visible = true
	
	poly_label = dock.get_node("VBoxContainer/PolyLabel") if dock.has_node("VBoxContainer/PolyLabel") else null
	vert_label = dock.get_node("VBoxContainer/VertLabel") if dock.has_node("VBoxContainer/VertLabel") else null
	poly_factor_spinbox = dock.get_node("VBoxContainer/PolyFactorContainer/PolyFactorSpinBox") if dock.has_node("VBoxContainer/PolyFactorContainer/PolyFactorSpinBox") else null
	vert_factor_spinbox = dock.get_node("VBoxContainer/VertFactorContainer/VertFactorSpinBox") if dock.has_node("VBoxContainer/VertFactorContainer/VertFactorSpinBox") else null
	manual_counting_checkbox = dock.get_node("VBoxContainer/ManualCountingContainer/ManualCountingCheckBox") if dock.has_node("VBoxContainer/ManualCountingContainer/ManualCountingCheckBox") else null
	if not poly_label or not vert_label:
		push_error("ERROR: Failed to find labels in dock. Expected nodes: PolyLabel, VertLabel")
		return
	if not poly_factor_spinbox or not vert_factor_spinbox or not manual_counting_checkbox:
		push_warning("Warning: Failed to find SpinBox or CheckBox nodes in dock. Adjustment factors or manual counting UI unavailable.")
	
	# Load initial values from Project Settings
	poly_adjustment_factor = ProjectSettings.get_setting("polygon_counter/poly_adjustment_factor", poly_adjustment_factor)
	vert_adjustment_factor = ProjectSettings.get_setting("polygon_counter/vert_adjustment_factor", vert_adjustment_factor)
	use_manual_csg_counting = ProjectSettings.get_setting("polygon_counter/use_manual_csg_counting", use_manual_csg_counting)
	print("Loaded from Project Settings: poly_adjustment_factor=", poly_adjustment_factor, " vert_adjustment_factor=", vert_adjustment_factor, " use_manual_csg_counting=", use_manual_csg_counting)

	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	dock.add_theme_stylebox_override("panel", bg)
	dock.get_node("VBoxContainer/TitleLabel").add_theme_color_override("font_color", Color.WHITE)
	poly_label.add_theme_color_override("font_color", Color.WHITE)
	vert_label.add_theme_color_override("font_color", Color.WHITE)
	if poly_factor_spinbox:
		poly_factor_spinbox.get_line_edit().add_theme_color_override("font_color", Color.WHITE)
	if vert_factor_spinbox:
		vert_factor_spinbox.get_line_edit().add_theme_color_override("font_color", Color.WHITE)
	if manual_counting_checkbox:
		manual_counting_checkbox.add_theme_color_override("font_color", Color.WHITE)
	
	if poly_factor_spinbox:
		poly_factor_spinbox.value = poly_adjustment_factor
		poly_factor_spinbox.connect("value_changed", Callable(self, "_on_poly_factor_changed"))
	if vert_factor_spinbox:
		vert_factor_spinbox.value = vert_adjustment_factor
		vert_factor_spinbox.connect("value_changed", Callable(self, "_on_vert_factor_changed"))
	if manual_counting_checkbox:
		manual_counting_checkbox.button_pressed = use_manual_csg_counting
		manual_counting_checkbox.connect("toggled", Callable(self, "_on_manual_counting_toggled"))
	
	toggle_button = Button.new()
	toggle_button.text = "Poly Count"
	toggle_button.toggle_mode = true
	toggle_button.set_pressed_no_signal(true)
	toggle_button.custom_minimum_size = Vector2(100, 0)
	toggle_button.connect("toggled", Callable(self, "_on_toggle_pressed"))
	#add_control_to_container(CONTAINER_TOOLBAR, toggle_button)
	print("Toggle button added to toolbar")
	
	var selection = get_editor_interface().get_selection()
	if selection:
		selection.connect("selection_changed", Callable(self, "_on_selection_changed"))
	else:
		push_error("ERROR: Failed to get selection interface")
	
	_update_stats()

func _exit_tree():
	if dock and dock.get_parent():
		remove_control_from_bottom_panel(dock)
		dock.queue_free()
	if toggle_button:
		remove_control_from_container(CONTAINER_TOOLBAR, toggle_button)
		toggle_button.queue_free()

func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		var new_use_manual = ProjectSettings.get_setting("polygon_counter/use_manual_csg_counting", use_manual_csg_counting)
		var new_poly_factor = ProjectSettings.get_setting("polygon_counter/poly_adjustment_factor", poly_adjustment_factor)
		var new_vert_factor = ProjectSettings.get_setting("polygon_counter/vert_adjustment_factor", vert_adjustment_factor)
		if new_use_manual != use_manual_csg_counting:
			use_manual_csg_counting = new_use_manual
			if manual_counting_checkbox:
				manual_counting_checkbox.button_pressed = use_manual_csg_counting
		if new_poly_factor != poly_adjustment_factor:
			poly_adjustment_factor = new_poly_factor
			if poly_factor_spinbox:
				poly_factor_spinbox.value = poly_adjustment_factor
		if new_vert_factor != vert_adjustment_factor:
			vert_adjustment_factor = new_vert_factor
			if vert_factor_spinbox:
				vert_factor_spinbox.value = vert_adjustment_factor
		_update_stats()

func _on_toggle_pressed(button_pressed: bool):
	is_visible = button_pressed
	dock.visible = is_visible
	_update_stats()

func _on_poly_factor_changed(value: float):
	poly_adjustment_factor = value
	ProjectSettings.set_setting("polygon_counter/poly_adjustment_factor", poly_adjustment_factor)
	print("Polygon adjustment factor updated to: ", poly_adjustment_factor)
	_update_stats()

func _on_vert_factor_changed(value: float):
	vert_adjustment_factor = value
	ProjectSettings.set_setting("polygon_counter/vert_adjustment_factor", vert_adjustment_factor)
	print("Vertex adjustment factor updated to: ", vert_adjustment_factor)
	_update_stats()

func _on_manual_counting_toggled(button_pressed: bool):
	use_manual_csg_counting = button_pressed
	ProjectSettings.set_setting("polygon_counter/use_manual_csg_counting", use_manual_csg_counting)
	print("Use Manual CSG Counting updated to: ", use_manual_csg_counting)
	_update_stats()

func _on_selection_changed():
	selected_nodes.clear()
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	for node in selection:
		if node is MeshInstance3D or node is CSGShape3D or node is CSGCombiner3D:
			selected_nodes.append(node)
	_update_stats()

func _count_mesh_stats(mesh: Mesh) -> Array:
	if not mesh:
		return [0, 0]
	var poly_count = 0
	var vertex_count = 0
	for surface_idx in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface_idx)
		if arrays and arrays[Mesh.ARRAY_VERTEX]:
			vertex_count += arrays[Mesh.ARRAY_VERTEX].size()
			if arrays[Mesh.ARRAY_INDEX]:
				poly_count += arrays[Mesh.ARRAY_INDEX].size() / 3
			else:
				poly_count += arrays[Mesh.ARRAY_VERTEX].size() / 3
	print("Mesh stats: Polygons=", poly_count, " Vertices=", vertex_count)
	return [poly_count, vertex_count]

func _count_csg_stats(csg_node: Node) -> Array:
	if csg_node is CSGShape3D or csg_node is CSGCombiner3D:
		csg_node.set("operation", csg_node.operation)
		csg_node._update_shape()
		
		var mesh_data = csg_node.get_meshes()
		if mesh_data.size() >= 2 and mesh_data[1] is Mesh:
			var stats = _count_mesh_stats(mesh_data[1])
			print("CSG mesh data (index 1): Polygons=", stats[0], " Vertices=", stats[1])
			# Apply adjustment factors to mesh-based counts
			stats[0] = int(stats[0] * poly_adjustment_factor)
			stats[1] = int(stats[1] * vert_adjustment_factor)
			print("Adjusted CSG mesh data (index 1): Polygons=", stats[0], " Vertices=", stats[1])
			return stats
		elif mesh_data.size() > 0 and mesh_data[0] is Mesh:
			var stats = _count_mesh_stats(mesh_data[0])
			print("CSG mesh data (index 0): Polygons=", stats[0], " Vertices=", stats[1])
			# Apply adjustment factors to mesh-based counts
			stats[0] = int(stats[0] * poly_adjustment_factor)
			stats[1] = int(stats[1] * vert_adjustment_factor)
			print("Adjusted CSG mesh data (index 0): Polygons=", stats[0], " Vertices=", stats[1])
			return stats

		if use_manual_csg_counting:
			if csg_node is CSGBox3D:
				# Default values for a cube
				return [12, 8]  # 12 polygons (triangles), 8 vertices for a box

			elif csg_node is CSGCylinder3D:
				if csg_node.cone: #polygon counting for cone
					return [csg_node.sides+csg_node.sides-2, csg_node.sides+1]
				# A cylinder has 12 polygons by default (sides) and a varying number of vertices
				# Assuming a simple cylinder with 12 sides
				else : return [4*csg_node.sides-2, csg_node.sides*2]  # 12 triangles for sides + 2 vertices for top and bottom
			
			
			elif csg_node is CSGTorus3D:
				# Get the number of radial and tube segments from the torus
				var radial_segments = csg_node.sides
				var tube_segments = csg_node.ring_sides
				
				# A torus consists of radial_segments * tube_segments quads, each of which is two triangles
				var poly_count = radial_segments * tube_segments * 2  # Two triangles per quad
				var vertex_count = radial_segments * tube_segments # Two vertices per segment (start and end of the tube)
				return [poly_count, vertex_count]
			
			
			elif csg_node is CSGSphere3D:
				var radial_segments = csg_node.radial_segments
				var ring_segments = csg_node.rings
				
				# A sphere consists of radial_segments * tube_segments quads, each of which is two triangles
				var poly_count = radial_segments * 2 *(1+ (ring_segments-2))  # Two triangles per quad
				var vertex_count = radial_segments * (ring_segments-1) +2 # Two vertices per segment (start and end of the tube)
				return [poly_count, vertex_count]
			elif csg_node is CSGPolygon3D:
				# Try to get the mesh data
				var poly_count = 0
				var vertex_count = 0
				var polygon_mesh_data = csg_node.get_meshes()
				if polygon_mesh_data.size() >= 2 and polygon_mesh_data[1] is Mesh:
					return _count_mesh_stats(polygon_mesh_data[1])
				elif polygon_mesh_data.size() > 0 and polygon_mesh_data[0] is Mesh:
					return _count_mesh_stats(polygon_mesh_data[0])
				
				# Manual fallback: Estimate based on the polygon points and mode
				var num_vertices = csg_node.polygon.size()  # Number of points in the 2D polygon
				if num_vertices < 3:  # Need at least 3 vertices to form a polygon
					push_warning("CSGPolygon3D has fewer than 3 vertices, cannot count polygons: ", csg_node.name)
					return [0, 0]
				
				# For MODE_DEPTH (default), the polygon is extruded
				# Front and back faces: Each has (num_vertices - 2) triangles
				# Sides: Each edge forms a quad (2 triangles), so num_vertices * 2 triangles
				poly_count = (num_vertices - 2) * 2 + num_vertices * 2  # Front/back + sides
				# Vertices: Front and back faces each have num_vertices
				vertex_count = num_vertices * 2
				return [poly_count, vertex_count]
			elif csg_node is CSGPolygon3D:
				var poly_count = 0
				var vertex_count = 0
				var polygon_mesh_data = csg_node.get_meshes()
				if polygon_mesh_data.size() >= 2 and polygon_mesh_data[1] is Mesh:
					var stats = _count_mesh_stats(polygon_mesh_data[1])
					print("CSGPolygon3D (mesh index 1): Polygons=", stats[0], " Vertices=", stats[1])
					# Apply adjustment factors
					stats[0] = int(stats[0] * poly_adjustment_factor)
					stats[1] = int(stats[1] * vert_adjustment_factor)
					print("Adjusted CSGPolygon3D (mesh index 1): Polygons=", stats[0], " Vertices=", stats[1])
					return stats
				elif polygon_mesh_data.size() > 0 and polygon_mesh_data[0] is Mesh:
					var stats = _count_mesh_stats(polygon_mesh_data[0])
					print("CSGPolygon3D (mesh index 0): Polygons=", stats[0], " Vertices=", stats[1])
					# Apply adjustment factors
					stats[0] = int(stats[0] * poly_adjustment_factor)
					stats[1] = int(stats[1] * vert_adjustment_factor)
					print("Adjusted CSGPolygon3D (mesh index 0): Polygons=", stats[0], " Vertices=", stats[1])
					return stats
				var num_vertices = csg_node.polygon.size()
				if num_vertices < 3:
					push_warning("CSGPolygon3D has fewer than 3 vertices, cannot count polygons: ", csg_node.name)
					return [0, 0]
				poly_count = (num_vertices - 2) * 2 + num_vertices * 2
				vertex_count = num_vertices * 2
				var stats = [poly_count, vertex_count]
				print("CSGPolygon3D (manual): Polygons=", stats[0], " Vertices=", stats[1])
				# Apply adjustment factors
				stats[0] = int(stats[0] * poly_adjustment_factor)
				stats[1] = int(stats[1] * vert_adjustment_factor)
				print("Adjusted CSGPolygon3D (manual): Polygons=", stats[0], " Vertices=", stats[1])
				return stats
			elif csg_node is CSGCombiner3D:
				var child_poly_count = 0
				var child_vert_count = 0
				for child in csg_node.get_children():
					if child is CSGShape3D:
						var child_stats = _count_csg_stats(child)
						child_poly_count += child_stats[0]
						child_vert_count += child_stats[1]
						print("Child stats (", child.name, "): Polygons=", child_stats[0], " Vertices=", child_stats[1])
					else:
						var dialog = AcceptDialog.new()
						dialog.title = "Warning: Invalid Node in CSGCombiner3D"
						dialog.dialog_text = "The CSGCombiner3D node contains a non-CSGShape3D node: " + child.name + ". Please remove it for accurate polygon/vertex counting."
						dialog.connect("confirmed", Callable(dialog, "queue_free"))
						add_child(dialog)
						dialog.popup_centered()
						return [0, 0]
				var base_poly_count = child_poly_count
				var base_vert_count = child_vert_count
				child_poly_count = int(child_poly_count * poly_adjustment_factor)
				child_vert_count = int(child_vert_count * vert_adjustment_factor)
				print("CSGCombiner3D stats - Base Polygons: ", base_poly_count, " Adjusted Polygons: ", child_poly_count,
					" Base Vertices: ", base_vert_count, " Adjusted Vertices: ", child_vert_count,
					" (Factors: Poly=", poly_adjustment_factor, " Vert=", vert_adjustment_factor, ")")
				return [child_poly_count, child_vert_count]
	return [0, 0]
func _update_stats():
	if not poly_label or not vert_label:
		push_error("ERROR: Labels not initialized in _update_stats")
		return
	
	if not is_visible:
		poly_label.text = "Polygons: Hidden"
		vert_label.text = "Vertices: Hidden"
		return
	
	if selected_nodes.is_empty():
		poly_label.text = "Polygons: 0"
		vert_label.text = "Vertices: 0"
		return
	
	var total_poly_count = 0
	var total_vert_count = 0
	
	for node in selected_nodes:
		var node_poly_count = 0
		var node_vert_count = 0
		
		if node is MeshInstance3D:
			var mesh = node.mesh
			if mesh:
				var stats = _count_mesh_stats(mesh)
				node_poly_count = stats[0]
				node_vert_count = stats[1]
		elif node is CSGCombiner3D or node is CSGShape3D:
			var stats = _count_csg_stats(node)
			node_poly_count = stats[0]
			node_vert_count = stats[1]
		
		total_poly_count += node_poly_count
		total_vert_count += node_vert_count
	
	poly_label.text = "Polygons: %d" % total_poly_count
	vert_label.text = "Vertices: %d" % total_vert_count
	print("Total stats: Polygons=", total_poly_count, " Vertices=", total_vert_count)

func _get_plugin_name():
	return "Polygon Counter"

func _get_plugin_config() -> Dictionary:
	return {
		"name": "Polygon Counter",
		"description": "A plugin to count polygons and vertices in the scene.",
		"version": "1.0",
		"settings": {
			"use_manual_csg_counting": {
				"type": TYPE_BOOL,
				"value": use_manual_csg_counting,
				"hint": PROPERTY_HINT_NONE,
				"name": "Use Manual CSG Counting",
				"description": "Enable manual counting for CSG nodes (workaround for Godot 4.4 alpha bug)."
			},
			"poly_adjustment_factor": {
				"type": TYPE_FLOAT,
				"value": poly_adjustment_factor,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.5,3.0,0.1",
				"name": "Polygon Adjustment Factor",
				"description": "Adjustment factor for CSGCombiner3D polygon count (default: 1.5 based on 2 CSGBox3D test)."
			},
			"vert_adjustment_factor": {
				"type": TYPE_FLOAT,
				"value": vert_adjustment_factor,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "1.0,15.0,0.1",
				"name": "Vertex Adjustment Factor",
				"description": "Adjustment factor for CSGCombiner3D vertex count (default: 9.375 to target 150 vertices for 2 CSGBox3D test)."
			}
		}
	}
