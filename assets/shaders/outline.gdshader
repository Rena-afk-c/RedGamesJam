shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0, 10) = 1.0;
uniform float outline_opacity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 sprite_color = texture(TEXTURE, UV);
    vec2 size = TEXTURE_PIXEL_SIZE * outline_width;
    
    float alpha = sprite_color.a;
    alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    
    vec4 final_color = mix(outline_color, sprite_color, sprite_color.a);
    vec4 outlined = mix(vec4(outline_color.rgb, 0.0), final_color, clamp(alpha, 0.0, 1.0));
    
    // Blend between the original sprite and the outlined version based on outline_opacity
    COLOR = mix(sprite_color, outlined, outline_opacity);
}