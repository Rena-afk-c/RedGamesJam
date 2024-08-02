shader_type canvas_item;

uniform vec4 bubble_color : source_color = vec4(0.7, 0.8, 1.0, 0.5);
uniform float border_thickness : hint_range(0.0, 0.5) = 0.05;
uniform float wobble_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wobble_amplitude : hint_range(0.0, 0.1) = 0.03;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    float wobble = sin(TIME * wobble_speed + UV.x * 10.0) * wobble_amplitude;
    dist += wobble;
    
    // Create bubble shape
    float circle = smoothstep(0.5, 0.5 - border_thickness, dist);
    
    vec2 light_dir = normalize(vec2(0.2, 0.2));
    float highlight = smoothstep(0.45, 0.4, distance(UV, center + light_dir * 0.2));
    
    vec4 final_color = mix(vec4(0.0), bubble_color, circle);
    final_color.rgb += highlight * 0.2;
    
    COLOR = final_color;
}