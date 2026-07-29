shader_type canvas_item;

uniform float tightness : hint_range(0.0, 1.0) = 0.0;
uniform float softness : hint_range(0.01, 1.0) = 0.5;

void fragment() {
    // distance from centre
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    
    float radius = mix(0.7, 0.0, tightness);
    float vignette = smoothstep(radius, radius - softness, dist);
   
    COLOR = vec4(vec3(0.0), 1.0 - vignette);
}