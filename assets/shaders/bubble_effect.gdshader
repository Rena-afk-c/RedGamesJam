shader_type canvas_item;

uniform vec4 bubble_color : source_color = vec4(0.7, 0.8, 1.0, 0.7);
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 0.1) = 0.03;
uniform float wobble_speed : hint_range(0.1, 5.0) = 1.5;
uniform float wobble_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float sparkle_speed : hint_range(0.1, 5.0) = 2.0;
uniform int num_sparkles = 3;
uniform bool pop_bubble = false;
uniform float pop_progress : hint_range(0.0, 1.0) = 0.0;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 rotate(vec2 uv, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
}

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 uv = UV - center;
    float dist = length(uv);
    
    // Wobble effect
    float wobble = sin(TIME * wobble_speed + UV.x * 10.0 + UV.y * 8.0) * wobble_amplitude;
    dist += wobble;
    
    // Enhanced pop effect
    float pop_scale = 1.0;
    float pop_fade = 1.0;
    float shockwave = 0.0;
    float particles = 0.0;
    
    if (pop_bubble) {
        // Dramatic expansion and contraction
        pop_scale = 1.0 + sin(pop_progress * 3.14159) * 0.3;
        pop_fade = smoothstep(0.8, 1.0, 1.0 - pop_progress);
        
        // Shockwave effect
        float shockwave_radius = pop_progress * 0.5;
        shockwave = smoothstep(shockwave_radius - 0.05, shockwave_radius, dist) * 
                    smoothstep(shockwave_radius + 0.05, shockwave_radius, dist) * 
                    (1.0 - pop_progress);
        
        // Particle burst effect
        for (int i = 0; i < 20; i++) {
            float angle = float(i) / 20.0 * 6.28318;
            vec2 particle_pos = rotate(vec2(pop_progress * 0.5, 0.0), angle);
            float particle_dist = length(uv - particle_pos);
            particles += smoothstep(0.02, 0.01, particle_dist) * (1.0 - pop_progress);
        }
    }
    
    dist /= pop_scale;
    
    // Create bubble shape with soft edge
    float bubble = smoothstep(0.48, 0.45, dist);
    
    // Create outline
    float outline = smoothstep(0.5, 0.5 - outline_thickness, dist) - smoothstep(0.48, 0.48 - outline_thickness, dist);
    
    // Add highlights
    vec2 light_dir = normalize(vec2(0.2, -0.2));
    float highlight = smoothstep(0.35, 0.3, distance(UV, center + light_dir * 0.2));
    
    // Add sparkles
    float sparkle = 0.0;
    for (int i = 0; i < num_sparkles; i++) {
        vec2 sparkle_pos = vec2(
            random(vec2(float(i), 1.0)),
            random(vec2(float(i), 2.0))
        );
        float sparkle_size = random(vec2(float(i), 3.0)) * 0.03 + 0.02;
        float sparkle_speed_var = random(vec2(float(i), 4.0)) * 0.5 + 0.75;
        
        float d = distance(UV, sparkle_pos);
        sparkle += smoothstep(sparkle_size, 0.0, d) * sin(TIME * sparkle_speed * sparkle_speed_var);
    }
    sparkle = max(0.0, sparkle);
    
    // Combine colors
    vec4 final_color = mix(vec4(0.0), bubble_color, bubble);
    final_color.rgb += highlight * 0.2;
    final_color.rgb += sparkle * 0.5;
    final_color = mix(final_color, outline_color, outline);
    
    // Apply enhanced pop effect
    final_color.rgb += shockwave * vec3(0.5, 0.7, 1.0); // Blue-ish shockwave
    final_color.rgb += particles * vec3(1.0, 1.0, 0.8); // Yellowish particles
    final_color.a *= pop_fade;
    
    COLOR = final_color;
}