shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 0.9, 0.65, 0.8);
uniform float angle : hint_range(-3.14159, 3.14159) = -0.3;
uniform float position : hint_range(-1.0, 1.0) = -0.2;
uniform float spread : hint_range(0.0, 1.0) = 0.5;
uniform float cutoff : hint_range(-1.0, 1.0) = 0.1;
uniform float falloff : hint_range(0.0, 1.0) = 0.2;
uniform float edge_fade : hint_range(0.0, 1.0) = 0.15;
uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float ray1_density : hint_range(1.0, 20.0) = 8.0;
uniform float ray2_density : hint_range(1.0, 50.0) = 30.0;
uniform float ray2_intensity : hint_range(0.0, 1.0) = 0.3;
uniform bool hdr = false;
uniform float seed = 5.0;
uniform float time_offset : hint_range(0.0, 100.0) = 0.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

mat2 rotate2d(float rotation_angle) {
    return mat2(vec2(cos(rotation_angle), -sin(rotation_angle)), 
                vec2(sin(rotation_angle), cos(rotation_angle)));
}

vec4 screen(vec4 base, vec4 blend) {
    return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment() {
    vec2 transformed_uv = (rotate2d(angle) * (UV - 0.5 - vec2(position, 0.0))) / (UV.y + spread - UV.y * spread) + 0.5;
    
    float time = TIME + time_offset;
    vec2 ray1 = vec2(transformed_uv.x * ray1_density + sin(time * 0.1 * speed) * (ray1_density * 0.2) + seed, 1.0);
    vec2 ray2 = vec2(transformed_uv.x * ray2_density + sin(time * 0.2 * speed) * (ray1_density * 0.2) + seed, 1.0);
    
    float cut = step(cutoff, transformed_uv.x) * step(cutoff, 1.0 - transformed_uv.x);
    ray1 *= cut;
    ray2 *= cut;
    
    float rays = hdr ? noise(ray1) + (noise(ray2) * ray2_intensity) :
                       clamp(noise(ray1) + (noise(ray2) * ray2_intensity), 0.0, 1.0);
    
    rays *= smoothstep(0.0, falloff, (1.0 - UV.y));
    rays *= smoothstep(0.0 + cutoff, edge_fade + cutoff, transformed_uv.x);
    rays *= smoothstep(0.0 + cutoff, edge_fade + cutoff, 1.0 - transformed_uv.x);
    
    vec4 screen_color = texture(TEXTURE, UV);
    vec3 shine = screen(screen_color, vec4(color.rgb, rays)).rgb;
    
    COLOR = vec4(shine, rays * color.a);
}