shader_type spatial;

render_mode blend_mix, 
    cull_disabled, 
    depth_draw_opaque, 
    shadows_disabled, 
    specular_disabled, 
    vertex_lighting;

// PS1 UNIFORMS
uniform bool affine_mapping = false;
uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform float alpha_scissor : hint_range(0, 1) = 0.6;
uniform float jitter: hint_range(0, 1) = 0.3;
uniform ivec2 resolution = ivec2(160, 120);

// CUTOUT UNIFORMS
global uniform float player_depth;
global uniform float player_y;
global uniform vec2 player_screen_offset;

uniform float cutout_radius : hint_range(0.0, 2.0) = 0.3;
uniform float feather : hint_range(0.0, 1.0) = 0.1;
uniform float depth_margin : hint_range(-2.0, 2.0) = 0.0; 
uniform float ground_margin : hint_range(-2.0, 2.0) = 0.0; 
uniform float floor_threshold : hint_range(0.0, 1.0) = 0.1;
uniform float facing_threshold : hint_range(0.0, 1.0) = 0.4; 

// DITHERING
const mat4 dither_table = mat4(
    vec4(0.0, 0.5, 0.125, 0.625),
    vec4(0.75, 0.25, 0.875, 0.375),
    vec4(0.1875, 0.6875, 0.0625, 0.5625),
    vec4(0.9375, 0.4375, 0.8125, 0.3125)
);

float dither(vec2 pixel_pos, float alpha) {
    vec2 uv_fract = fract(pixel_pos / 4.0);
    int index_x = int(uv_fract.x * 4.0);
    int index_y = int(uv_fract.y * 4.0);
    
    float limit = 0.0;
    if (index_y == 0) limit = dither_table[0][index_x];
    else if (index_y == 1) limit = dither_table[1][index_x];
    else if (index_y == 2) limit = dither_table[2][index_x];
    else if (index_y == 3) limit = dither_table[3][index_x];

    return float(alpha > limit);
}

// PS1 VERTEX SNAPPING
vec4 snap_to_position(vec4 base_position) {
    vec4 snapped_position = base_position;
    snapped_position.xyz = base_position.xyz / base_position.w;
    
    vec2 snap_resulotion = floor(vec2(resolution) * (1.0 - jitter));
    snapped_position.x = floor(snap_resulotion.x * snapped_position.x) / snap_resulotion.x;
    snapped_position.y = floor(snap_resulotion.y * snapped_position.y) / snap_resulotion.y;
    
    snapped_position.xyz *= base_position.w;
    return snapped_position;
}

void vertex() {
    // PS1 vertex snapping logic
    vec4 snapped_position = snap_to_position(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
    if (affine_mapping) {
        POSITION = snapped_position;
        POSITION /= abs(POSITION.w);
    } else {
        POSITION = snapped_position;
    }
}

void fragment() {
    vec4 color_base = COLOR;
    vec4 albedo_tex = texture(albedo_texture, UV);

    ALBEDO = (color_base * albedo_tex).rgb;
    ALPHA = albedo_tex.a * color_base.a;
    ALPHA_SCISSOR_THRESHOLD = alpha_scissor; 
    
    // Hardcoded material properties for PS1 look
    METALLIC = 0.0;
    ROUGHNESS = 1.0;
    SPECULAR = 0.0;

    // evaluate Cutout Logic
    float frag_distance = -VERTEX.z;
    
    vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

    bool is_flat = world_normal.y > floor_threshold;
    bool is_below_player = world_pos.y < (player_y + ground_margin);
    bool is_ground = is_flat && is_below_player;

    float facing_dot = dot(NORMAL, -normalize(VERTEX));
    bool is_facing_camera = facing_dot > facing_threshold;

    if (frag_distance < (player_depth + depth_margin) && !is_ground && is_facing_camera) {
        
        float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
        vec2 screen_center = vec2(0.5, 0.5) + player_screen_offset;
        vec2 center_uv = SCREEN_UV - screen_center;
        center_uv.x *= aspect;

        float dist_from_center = length(center_uv);
        float inner_radius = max(0.0, cutout_radius - feather);
        float cutout_alpha = smoothstep(inner_radius, cutout_radius, dist_from_center);

        if (dither(FRAGCOORD.xy, cutout_alpha) == 0.0) {
            discard;
        }
    }
}