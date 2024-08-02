shader_type canvas_item;

// Chroma key uniforms
uniform vec3 chroma_key_color : source_color = vec3(0.0, 1.0, 0.0);
uniform float similarity : hint_range(0.0, 1.0) = 0.4;
uniform float smoothness : hint_range(0.0, 1.0) = 0.08;
uniform float spill : hint_range(0.0, 1.0) = 0.1;

// Outline uniforms
uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform int outline_width : hint_range(0, 10) = 1;
uniform float outline_threshold : hint_range(0.0, 1.0) = 0.5;
uniform bool enable_outline = true;

// Pixelation uniforms
uniform bool enable_pixelation = false;
uniform float pixelation_amount : hint_range(1.0, 1000.0) = 10.0;

vec4 get_pixelated_color(sampler2D tex, vec2 uv, float pixel_amount) {
    vec2 dimensions = vec2(textureSize(tex, 0));
    vec2 pixelated_uv = floor(uv * dimensions / pixel_amount) * pixel_amount / dimensions;
    return texture(tex, pixelated_uv);
}

vec4 apply_chroma_key(vec4 color) {
    float mask = smoothstep(similarity, similarity + smoothness,
        length(abs(chroma_key_color - color.rgb)));
    
    // Apply spill suppression
    float max_color = max(color.r, color.b);
    float green = color.g;
    float spill_val = smoothstep(max_color, max_color + spill * 0.707, green);
    color.g = mix(green, max_color, spill_val);
    
    // Apply the mask
    color.a *= mask;
    
    return color;
}

void fragment() {
    vec2 uv = UV;
    vec4 final_color;
    
    if (enable_pixelation) {
        final_color = get_pixelated_color(TEXTURE, uv, pixelation_amount);
    } else {
        final_color = texture(TEXTURE, uv);
    }
    
    final_color = apply_chroma_key(final_color);
    
    if (enable_outline) {
        float alpha = 0.0;
        vec2 pixel_size = TEXTURE_PIXEL_SIZE;
        
        for (int x = -outline_width; x <= outline_width; x++) {
            for (int y = -outline_width; y <= outline_width; y++) {
                if (x != 0 || y != 0) {
                    vec2 offset = vec2(float(x), float(y)) * pixel_size;
                    vec4 neighbor_color;
                    if (enable_pixelation) {
                        neighbor_color = get_pixelated_color(TEXTURE, uv + offset, pixelation_amount);
                    } else {
                        neighbor_color = texture(TEXTURE, uv + offset);
                    }
                    neighbor_color = apply_chroma_key(neighbor_color);
                    alpha = max(alpha, neighbor_color.a);
                }
            }
        }
        
        if (alpha > outline_threshold && final_color.a < outline_threshold) {
            final_color = outline_color;
        }
    }
    
    COLOR = final_color;
}