shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 1.0); // Adjust blur strength
uniform float opacity_reduction : hint_range(0.0, 1.0); // Adjust opacity reduction
uniform int kernel_size : hint_range(1, 10) = 3; // Kernel size for blur, default 3x3

// Function for Gaussian blur
vec4 apply_blur(sampler2D tex, vec2 uv, float strength, int kernel) {
    vec4 color = vec4(0.0);
    float total_weight = 0.0;
    
    // Loop through neighboring pixels
    for (int x = -kernel; x <= kernel; x++) {
        for (int y = -kernel; y <= kernel; y++) {
            float weight = max(0.0, 1.0 - length(vec2(float(x), float(y))) * strength); // Convert x, y to float
            vec2 offset = vec2(float(x), float(y)) / vec2(textureSize(tex, 0)); // Convert x, y to float
            color += texture(tex, uv + offset) * weight;
            total_weight += weight;
        }
    }
    return color / total_weight;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Apply blur effect with adjustable strength
    tex_color = apply_blur(TEXTURE, UV, blur_strength, kernel_size);

    // Reduce opacity
    tex_color.a *= (1.0 - opacity_reduction);

    COLOR = tex_color;
}