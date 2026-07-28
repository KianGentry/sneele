shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform float player_depth : hint_range(0.0, 100.0) = 4.0;
uniform float cutout_radius : hint_range(0.0, 2.0) = 0.25;
uniform float feather : hint_range(0.0, 1.0) = 0.1;

uniform float depth_margin : hint_range(-2.0, 2.0) = 0.0; 

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

void fragment() {
	vec4 albedo_tex = texture(albedo_texture, UV);
	ALBEDO = albedo_tex.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;

	ALPHA = albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5; 

	float frag_distance = length(VERTEX);

	// Replaced the hardcoded -0.5 with our exposed depth_margin
	if (frag_distance < (player_depth + depth_margin)) {
		
		float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
		vec2 center_uv = SCREEN_UV - vec2(0.5, 0.5);
		center_uv.x *= aspect;

		float dist_from_center = length(center_uv);
		float inner_radius = max(0.0, cutout_radius - feather);
		float cutout_alpha = smoothstep(inner_radius, cutout_radius, dist_from_center);

		if (dither(FRAGCOORD.xy, cutout_alpha) == 0.0) {
			discard;
		}
	}
}