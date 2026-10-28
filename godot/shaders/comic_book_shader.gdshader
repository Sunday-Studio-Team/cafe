//erinixie - https://godotshaders.com/shader/actionlines-comic-anime/

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float Speed : hint_range(0.0, 5.0) = 0.8;
uniform vec4 LineColor : source_color = vec4(1.0);
uniform float Radius : hint_range(0.0, 3.0) = 3.0;

const float Softness = 0.4;
const float Freq = 5.0;

//random float
float hash(vec2 v) {
    return fract(sin(dot(v, vec2(89.44, 19.36))) * 22189.22);
}

//smooth the value because hash might gernerate REALLY random value
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

//each noice do it for 7 times to make it more
float noise(vec2 v) {
    float sum = 0.0;
    for (int i = 1; i < 7; i++) {
        sum += iHash(v + vec2(float(i)), vec2(2.0 * pow(2.0, float(i)))) / pow(2.0, float(i));
    }
    return sum;
}

void fragment() {
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE; //get screen size
    vec2 uv = SCREEN_UV * 2.0 - 1.0;// make the location middle

    vec2 puv = vec2(Speed * TIME, Freq * atan(uv.y, uv.x));

    float noise_value = noise(puv); // get the noise value
    float value = length(uv) - Radius - 2.0 * (noise_value - 0.5); //Radius, and apply noise onto it
    value = smoothstep(-Softness, Softness, value); // smooth the value

    vec4 tex = texture(screen_texture, SCREEN_UV);
    vec3 color = mix(tex.rgb, LineColor.rgb, value * LineColor.a);

    COLOR = vec4(color, 1.0);
}
