shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D noise_texture_1;
uniform sampler2D noise_texture_2;
uniform sampler2D wave;

uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform vec4 dark_color : source_color;
uniform vec4 light_color : source_color;
uniform vec4 fresnel_color : source_color;

uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.01;
uniform float height_scale : hint_range(0.0, 1.0) = 0.02;

varying float height;
varying vec3 world_position;

uniform float edge_scale = 0.01;
uniform float near = 1.0;
uniform float far = 100.0;
uniform float noise_scale = 10.0;

uniform vec2 wave_direction_1;
uniform vec2 wave_direction_2;

uniform vec3 edge_color : source_color;

float edge(float depth)
{
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() 
{
	vec2 time_1 = (TIME * wave_direction_1) * time_scale;
	vec2 time_2 = (TIME * wave_direction_2) * time_scale;
	
	vec3 displacement_1 = floor(2.0 * texture(noise_texture_1, world_position.xz + time_1).rgb) / 4.0;
	vec3 displacement_2 = floor(2.0 * texture(noise_texture_2, world_position.xz + time_2).rgb) / 4.0;
	vec3 displacement_noise = mix(displacement_1, displacement_2, 0.5);
	
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_position = edge(FRAGCOORD.z);
	float z_difference = z_depth - z_position;

	vec3 color = mix(edge_color, dark_color.rgb, step(edge_scale, z_difference));
	
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(color, fresnel_color.rgb, fresnel);
	
	ALBEDO = clamp(surface_color + displacement_noise, vec3(0), vec3(1));
	METALLIC = metallic;
	ROUGHNESS = roughness;
	//NORMAL_MAP = normal_blend;
}

void vertex()
{
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_position.xz / noise_scale * TIME * time_scale).r;
	VERTEX.y += height * height_scale;
}


