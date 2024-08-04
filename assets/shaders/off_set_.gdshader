shader_type canvas_item;

uniform float rotation_speed = 1.0; // Adjust for faster/slower rotation
uniform float inner_radius = 0.3; // Adjust based on your belt's inner radius
uniform float outer_radius = 0.5; // Adjust based on your belt's outer radius
uniform sampler2D conveyor_texture : filter_linear_mipmap, repeat_enable;

void fragment() {
    // Center the UV coordinates
    vec2 centered_uv = UV - 0.5;
    
    // Calculate the distance from the center
    float distance = length(centered_uv);
    
    // Calculate the angle of the current pixel
    float angle = atan(centered_uv.y, centered_uv.x);
    
    // Adjust the angle based on time for rotation
    float adjusted_angle = angle - TIME * rotation_speed;
    
    // Map the radius to our texture's v coordinate
    float v = (distance - inner_radius) / (outer_radius - inner_radius);
    
    // Map the angle to our texture's u coordinate
    float u = adjusted_angle / (2.0 * PI);
    
    // Sample the texture
    vec2 polar_uv = vec2(u, v);
    vec4 color = texture(conveyor_texture, polar_uv);
    
    // Discard pixels outside the belt
    if (distance < inner_radius || distance > outer_radius) {
        color.a = 0.0;
    }
    
    COLOR = color;
}