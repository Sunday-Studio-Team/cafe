#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D InputImage;

vec3 ConvertRGBToHSV(vec3 Color)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);

    //  vec4 p = (color.g >= color.b)
    //             ? vec4(color.g, color.b,  0.0, -1.0 / 3.0)
    //             : vec4(color.b, color.g, -1.0,  2.0 / 3.0);
    //
    //  vec4 q = (color.r >= p.x)
    //         ? vec4(color.r, p.y, p.z, p.w)
    //         : vec4(p.x, p.y, p.w, c.r);

    vec4 p = mix(vec4(Color.bg, K.wz), vec4(Color.gb, K.xy), step(Color.b, Color.g));
    vec4 q = mix(vec4(p.xyw, Color.r), vec4(Color.r, p.yzx), step(p.x, Color.r));

    float d = q.x - min(q.w, q.y);
    float epsilon = 1.0e-10; // to not just blow up the GPU from div by 0
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + epsilon)), d / (q.x + epsilon), q.x);
}

vec3 ConvertHSVToRGB(vec3 Color) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(Color.xxx + K.xyz) * 6.0 - K.www);
    return Color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), Color.y);
}

struct ColorStop {
    float Position; // normalized between 0f - 1f
    float Color;
};

#define STOP_COUNT 6

float ConstantValueRamp(float Position, ColorStop Stops[STOP_COUNT])
{
    Position = clamp(Position, 0, 1.0);

    float final_color = Stops[0].Color;

    for (uint i = 1; i < STOP_COUNT; ++i)
    {
        if (Position >= Stops[i].Position)
        {
            final_color = Stops[i].Color;
        }
        else
        {
            break;
        }
    }

    return final_color;
}

void main()
{
    ivec2 pixel_coordinates = ivec2(gl_GlobalInvocationID.xy);
    ivec2 resolution = imageSize(InputImage);

    if (pixel_coordinates.x > resolution.x || pixel_coordinates.y >= resolution.y) {
        return;
    }

    vec2 uv = (vec2(pixel_coordinates) + vec2(0.5)) / vec2(resolution);

    vec2 distance = uv - vec2(0.5);

    vec4 color = imageLoad(InputImage, pixel_coordinates);

    color.rgb = ConvertRGBToHSV(color.rgb); //clamp(vignette, 0.0, 1.0);
    ColorStop color_stops[STOP_COUNT] = ColorStop[STOP_COUNT](
            ColorStop(0.000, 0.216), // #373737
            ColorStop(0.035, 0.310), // #4F4F4F
            ColorStop(0.154, 0.427), // #6D6D6D
            ColorStop(0.469, 0.541), // #8A8A8A
            ColorStop(0.684, 0.647), // #A5A5A5
            ColorStop(0.800, 1.000) // #FFFFFF
        );
    color.b = ConstantValueRamp(color.b, color_stops);
    color.rgb = ConvertHSVToRGB(color.rgb);
    imageStore(InputImage, pixel_coordinates, color);
}
