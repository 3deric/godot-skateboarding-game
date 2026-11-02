shader_type canvas_item;
render_mode skip_vertex_transform, unshaded;

const vec2 target_resolution = vec2(320.0,180.0);
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

void fragment() {
	vec2 uv = floor(SCREEN_UV * target_resolution) / target_resolution;
	COLOR = texture(screen_texture, uv);
}