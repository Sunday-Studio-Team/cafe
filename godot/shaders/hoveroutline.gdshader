shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

uniform float outline_thickness = 1.1;
uniform vec3 outline_color : source_color = vec3(1.0);

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX *= outline_thickness;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = outline_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
