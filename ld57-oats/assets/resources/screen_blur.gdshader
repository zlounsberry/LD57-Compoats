shader_type fragment;

uniform float blur_radius : hint_range(1.0, 10.0) = 3.0; // Controls the strength of the blur

void fragment() {
    vec2 texel_size = 1.0 / textureSize(TEXTURE, 0); // Get the size of a single texel
    
    // The 3x3 blur kernel
    vec4 color = texture(TEXTURE, FRAGCOORD.xy / VIEWPORT_SIZE); // Center pixel
    color += texture(TEXTURE, (FRAGCOORD.xy + vec2(texel_size.x, 0.0)) / VIEWPORT_SIZE); // Right pixel
    color += texture(TEXTURE, (FRAGCOORD.xy - vec2(texel_size.x, 0.0)) / VIEWPORT_SIZE); // Left pixel
    color += texture(TEXTURE, (FRAGCOORD.xy + vec2(0.0, texel_size.y)) / VIEWPORT_SIZE); // Bottom pixel
    color += texture(TEXTURE, (FRAGCOORD.xy - vec2(0.0, texel_size.y)) / VIEWPORT_SIZE); // Top pixel
    color += texture(TEXTURE, (FRAGCOORD.xy + vec2(texel_size.x, texel_size.y)) / VIEWPORT_SIZE); // Bottom-right pixel
    color += texture(TEXTURE, (FRAGCOORD.xy - vec2(texel_size.x, texel_size.y)) / VIEWPORT_SIZE); // Top-left pixel
    color += texture(TEXTURE, (FRAGCOORD.xy + vec2(-texel_size.x, texel_size.y)) / VIEWPORT_SIZE); // Bottom-left pixel
    color += texture(TEXTURE, (FRAGCOORD.xy + vec2(texel_size.x, -texel_size.y)) / VIEWPORT_SIZE); // Top-right pixel

    // Average the colors to create the blur effect
    color /= 9.0;

    // Set the final pixel color
    COLOR = color;
}