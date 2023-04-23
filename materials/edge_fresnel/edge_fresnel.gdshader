shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform sampler2D cloud_noise_texture_1;
uniform sampler2D cloud_noise_texture_2;
uniform sampler2D radial_noise_texture;
uniform sampler2D bump_map_texture;

varying float height;
varying vec3 world_position;

uniform vec4 main_color : source_color;
uniform vec4 fresnel_color : source_color;

uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.01;

uniform float edge_scale = 0.01;
uniform float near = 1.0;
uniform float far = 100.0;
uniform float noise_scale = 10.0;
uniform float distortion_strength : hint_range(0.0, 1.0)= 1.0;

uniform vec3 edge_color : source_color;

// Logarithmic z-buffer
// https://www.sjbaker.org/steve/omniv/love_your_z_buffer.html
float edge(float depth)
{
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

// Calculates view normal from camera to mesh
float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() 
{
	// Calculates edge texture based on distance from mesh collision
	// Creates "foam on the sides" of the mesh
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_position = edge(FRAGCOORD.z);
	float z_difference = z_depth - z_position;
	
	// Combine edge color and main color
	vec3 color = mix(edge_color, vec3(0.0), step(edge_scale, z_difference));

	// Adds greater light as you view the mesh at an angle
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(color, fresnel_color.rgb, fresnel);
	
	// Combine everything
	ALBEDO = clamp(surface_color, vec3(0), vec3(1));
}
