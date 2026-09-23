#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D InputImage;

void main()
{
    ivec2 pixel_coordinates = ivec2(gl_GlobalInvocationID.xy);
    ivec2 resolution = imageSize(InputImage);

    if (pixel_coordinates.x > resolution.x || pixel_coordinates.y >= resolution.y) {
        return;
    }

    vec2 uv = (vec2(pixel_coordinates) + vec2(0.5)) / vec2(resolution);

    vec2 distance = uv - vec2(0.5);
    float vignette = 1.0 - length(distance) * 1.2;

    vec4 color = imageLoad(InputImage, pixel_coordinates);
    color.rgb *= clamp(vignette, 0.0, 1.0);

    imageStore(InputImage, pixel_coordinates, color);
}
