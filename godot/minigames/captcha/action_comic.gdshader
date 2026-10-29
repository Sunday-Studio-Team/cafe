// shader is from Basado en: https://www.shadertoy.com/view/wsfcDM with some adjustments to the fragment shader
shader_type canvas_item;

uniform float Speed : hint_range(0.0, 5.0) = 0.5;
uniform float LineLength : hint_range(0.0, 4.0) = 1.0;
uniform vec4 LineColor : source_color = vec4(0.0, 0.0, 0.0,0.5);
uniform float Softness : hint_range(0.0, 1.0) = 0.1;
uniform float Weirdness : hint_range(0.0, 1.0) = 0.1;

uniform float Radius : hint_range(0.0, 2.0) = 1.3;
uniform float Freq  : hint_range(3.0, 50.0) = 10.0;

float hash(vec2 v) {
    return fract(sin(dot(v, vec2(89.44, 19.36))) * 22189.22);
}

float iHash(vec2 v, vec2 r) {
    vec4 h = vec4(
        hash(floor(v * r + vec2(0.0, 0.0)) / r),
        hash(floor(v * r + vec2(0.0, 1.0)) / r),
        hash(floor(v * r + vec2(1.0, 0.0)) / r),
        hash(floor(v * r + vec2(1.0, 1.0)) / r)
    );
    vec2 ip = smoothstep(vec2(0.0), vec2(1.0), mod(v * r, 1.0));
    return mix(mix(h.x, h.y, ip.y), mix(h.z, h.w, ip.y), ip.x);
}

float noise(vec2 v) {
    float sum = 0.0;
    for (int i = 1; i < 7; i++) {
        sum += iHash(v + vec2(float(i)), vec2(2.0 * pow(2.0, float(i)))) / pow(2.0, float(i));
    }
    return sum;
}

vec2 getuv(vec2 p, vec2 resolution) {
    return vec2(0.5 + (p.x - 0.5) * (resolution.x / resolution.y), p.y);
}

void fragment() {
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 fragCoord = UV * resolution;

    vec2 uv = (fragCoord * 2.0 - resolution) / resolution;

    vec2 puv = vec2(
        Weirdness * length(uv) + Speed * TIME,
        Freq * atan(uv.y, uv.x)
    );

    float value = noise(puv);
    value = length(uv) - Radius - LineLength * (value - 0.5);
    value = smoothstep(-Softness, Softness, value);

    vec3 color = LineColor.rgb;
    
    float alpha = value * LineColor.a; 
    
    COLOR = vec4(color, alpha);
}
