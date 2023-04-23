shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform sampler2D noise_texture;
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.01;

varying float height;
varying vec3 world_position;

uniform float edge_scale = 0.01;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;
uniform vec3 main_color : source_color;

float edge(float depth)
{
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}


void fragment() 
{
//	vec2 time = (TIME * wave_direction) * time_scale;
//	vec2 time2 = (TIME * wave_direction2) * time_scale;
	
	//vec3 normal_blend = mix(texture(texture_normal, world_position.xz + time).rgb, texture(texture_normal2, world_position.xz + time2).rgb, 0.5);
	
	float noise1 = texture(noise_texture, UV / 2.0 + TIME * time_scale).x;
	noise1 = round(noise1 * 4.0) / 4.0;
	float noise2 = texture(noise_texture, UV / 2.0 - TIME * time_scale).y;
	noise2 = round(noise2 * 4.0) / 4.0;
	float noise = (noise1 + noise2) / 4.0;
	
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_position = edge(FRAGCOORD.z);
	float z_difference = z_depth - z_position;

	vec3 color = mix(edge_color, main_color, step(edge_scale, z_difference));
	
	ALBEDO = clamp(color + noise, vec3(0), vec3(1));
	METALLIC = metallic;
	ROUGHNESS = roughness;
	//NORMAL_MAP = normal_blend;
}

void vertex()
{
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}


