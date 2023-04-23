shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform sampler2D cloud_noise_texture_1;
uniform sampler2D cloud_noise_texture_2;
uniform sampler2D radial_noise_texture;
uniform sampler2D bump_map_texture;
uniform sampler2D distortion_map_texture;

varying float height;
varying vec3 world_position;

uniform vec4 main_color : source_color;
uniform vec4 fresnel_color : source_color;

uniform float rotate_time_scale: hint_range(0.0, 0.5, 0.005) = 0.3;
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.01;
uniform float distortion_time_scale : hint_range(0.0, 0.5, 0.005) = 0.3;
uniform float wave_height_scale : hint_range(0.0, 0.05) = 0.015;

uniform float edge_scale = 0.01;
uniform float near = 1.0;
uniform float far = 100.0;
uniform float noise_scale = 10.0;
uniform float distortion_strength : hint_range(0.0, 1.0)= 1.0;

uniform vec2 wave_direction_1;
uniform vec2 wave_direction_2;

uniform vec3 edge_color : source_color;

// Logarithmic z-buffer
// https://www.sjbaker.org/steve/omniv/love_your_z_buffer.html
float edge(float depth)
{
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

// https://godotengine.org/qa/41400/simple-texture-rotation-shader
vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	uv -= pivot;
	return vec2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x 
	) + pivot;
}

// Calculates view normal from camera to mesh
float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() 
{
	vec2 time_1 = (TIME * wave_direction_1) * time_scale;
	vec2 time_2 = (TIME * wave_direction_2) * time_scale;
	
	// Distort texture
	vec2 distortion = texture(distortion_map_texture, UV - TIME / 8.0).rg;
	// Center displacement
	distortion = ((distortion * 2.0) - 1.0) * distortion_strength;
	
	// Rounding creates cartoon-y banding
	vec3 cloud_1 = floor(3.0 * texture(cloud_noise_texture_1, world_position.xz + time_1 + distortion).rgb) / 6.0;
	vec3 cloud_2 = floor(3.0 * texture(cloud_noise_texture_2, world_position.xz + time_2 + distortion).rgb) / 6.0;
	vec3 cloud_noise = mix(cloud_1, cloud_2, 0.5);
	
	// Spin
	vec3 radial_noise = texture(radial_noise_texture, rotateUV(UV, vec2(0.5), rotate_time_scale * TIME)).rgb;
	
	// Calculates edge texture based on distance from mesh collision
	// Creates "foam on the sides" of the mesh
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_position = edge(FRAGCOORD.z);
	float z_difference = z_depth - z_position;
	
	// Combine edge color and main color
	vec3 color = mix(edge_color, main_color.rgb, step(edge_scale, z_difference));

	// Adds greater light as you view the mesh at an angle
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(color, fresnel_color.rgb, fresnel);
	
	// Combine everything
	ALBEDO = clamp(surface_color + cloud_noise + radial_noise, vec3(0), vec3(1));
}

// Waves
void vertex()
{
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(bump_map_texture, world_position.xz / noise_scale * TIME * time_scale).r;
	VERTEX.y += height * wave_height_scale;
}

