shader_type spatial;

render_mode unshaded,
            depth_test_disabled;

uniform vec4 xray_color : source_color =
    vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
    ALBEDO = xray_color.rgb;
    EMISSION = xray_color.rgb;
}