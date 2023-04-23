shader_type spatial;
render_mode unshaded;

varying float height;
varying vec3 world_position;

uniform sampler2D noise_texture;

uniform float distortion_strength : hint_range(0.0, 0.15)= 1.0;

void fragment() 
{
	// Distort texture
	vec2 distortion = texture(noise_texture, UV - TIME / 8.0).rg;
	// Center displacement
	distortion = ((distortion * 2.0) - 1.0) * distortion_strength;
	
	// Rounding creates cartoon-y banding
	vec3 noise = texture(noise_texture, UV + distortion).rgb;
	
	ALBEDO = clamp(noise, vec3(0), vec3(1));
}