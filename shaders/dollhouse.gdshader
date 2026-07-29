shader_type spatial;
// cull_disabled ensures we see the inside of walls if they are thin
render_mode depth_draw_opaque, cull_disabled; 

uniform sampler2D albedo_tex : source_color, filter_nearest; // filter_nearest for PS1 pixelation
uniform vec4 albedo : source_color = vec4(1.0);

// Dollhouse variables
global uniform vec3 global_player_pos;
uniform float cutout_radius = 3.0;     // How wide the hole around the player is
uniform float fade_falloff = 1.5;      // How smooth the dither transition is
uniform bool use_dithering = true;     // Toggle between PS1 dither or hard cut

varying vec3 world_pos;

void vertex() {
    // Get the world space position of the vertex
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec4 tex = texture(albedo_tex, UV);
    ALBEDO = tex.rgb * albedo.rgb;

    // 1. Calculate distances
    float dist_to_player = distance(world_pos, global_player_pos);
    float dist_to_cam = distance(world_pos, CAMERA_POSITION_WORLD);
    float player_to_cam = distance(global_player_pos, CAMERA_POSITION_WORLD);

    float current_alpha = 1.0;

    // 2. Only fade if the wall fragment is BETWEEN the camera and the player
    // Subtracting a small buffer (0.5) ensures floors/walls right under the player don't vanish
    if (dist_to_cam < (player_to_cam - 0.5)) {
        // Calculate alpha based on how close the pixel is to the player
        current_alpha = smoothstep(cutout_radius, cutout_radius + fade_falloff, dist_to_player);
    }

    // 3. Apply PS1-style screen-space dithering
    if (use_dithering) {
        ivec2 pixel_coords = ivec2(FRAGCOORD.xy);
        // 4x4 Bayer matrix for classic dithering
        const float dither[16] = float[](
            0.0625, 0.5625, 0.1875, 0.6875,
            0.8125, 0.3125, 0.9375, 0.4375,
            0.2500, 0.7500, 0.1250, 0.6250,
            1.0000, 0.5000, 0.8750, 0.3750
        );
        int index = (pixel_coords.y % 4) * 4 + (pixel_coords.x % 4);

        if (current_alpha < dither[index]) {
            discard; // Drops the pixel entirely, keeping depth sorting perfect
        }
    } else {
        // Fallback for standard alpha transparency (requires changing render_mode)
        ALPHA = current_alpha;
    }
}