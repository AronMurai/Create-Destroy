shader_type spatial;
render_mode unshaded;

uniform float rotate_time_scale : hint_range(0.0, 0.3, 0.05);
uniform sampler2D radial_noise_texture;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	uv -= pivot;
	return vec2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x 
	) + pivot;
}

void fragment() 
{
	// Spin
	vec3 radial_noise = texture(radial_noise_texture, rotateUV(UV, vec2(0.5), rotate_time_scale * TIME)).rgb;
	ALBEDO = radial_noise;
}
