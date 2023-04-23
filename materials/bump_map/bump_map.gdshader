shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform sampler2D cloud_noise_texture_1;
uniform sampler2D cloud_noise_texture_2;
uniform sampler2D radial_noise_texture;
uniform sampler2D bump_map_texture;

varying float height;
varying vec3 world_position;

uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.01;
uniform float noise_scale = 0.1;
uniform float wave_height_scale = 0.1;
// Waves
void vertex()
{
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(bump_map_texture, world_position.xz / noise_scale * TIME * time_scale).r;
	VERTEX.y += height * wave_height_scale;
}