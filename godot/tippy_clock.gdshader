shader_type spatial;

uniform vec3 full_color : source_color;
uniform vec3 empty_color : source_color;
uniform float radius;

void fragment() {
	// Called for every pixel the material is visible on.
    vec2 centered = UV - 0.5;
	if (length(centered) > radius) {
	        discard;
	}
}

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
