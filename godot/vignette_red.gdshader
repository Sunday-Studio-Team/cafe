shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float vignette_radius : hint_range(0.0, 3.0) = 0.8;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec2 uv = SCREEN_UV;
    
   
    vec2 centered = (uv - 0.5) * 2.0;
    
   
    float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;  
    
    centered.x *= aspect_ratio;   
    
    float distance = length(centered);
    
    
    float vignette = smoothstep(vignette_radius, vignette_radius - vignette_softness, distance);
    
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    
    float vignette_strength = (1.0 - vignette) * vignette_color.a * COLOR.a;
    COLOR = mix(screen_color, vignette_color, vignette_strength);
}