shader_type spatial;
render_mode unshaded;

uniform sampler2D cloud_noise_texture_1;
uniform sampler2D cloud_noise_texture_2;

uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.01;

uniform vec2 wave_direction_1;
uniform vec2 wave_direction_2;

void fragment()
{
	vec2 time_1 = (TIME * wave_direction_1) * time_scale;
	vec2 time_2 = (TIME * wave_direction_2) * time_scale;
	
	// Rounding creates cartoon-y banding
	vec3 cloud_1 = floor(3.0 * texture(cloud_noise_texture_1, UV + time_1).rgb) / 6.0;
	vec3 cloud_2 = floor(3.0 * texture(cloud_noise_texture_2, UV + time_2).rgb) / 6.0;
	vec3 cloud_noise = mix(cloud_1, cloud_2, 0.5);
	
	ALBEDO = cloud_noise;
}