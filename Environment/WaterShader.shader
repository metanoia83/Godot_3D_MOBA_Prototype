shader_type spatial;
render_mode unshaded,depth_draw_opaque;

uniform vec4 foam_color : hint_color;
uniform vec4 specular_color : hint_color;
uniform vec4 surface_water : hint_color;
uniform vec4 deep_water : hint_color;
uniform sampler2D water_normal: hint_albedo;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform float time_factor = 0.035;
uniform float visible_depth = 32.0;
uniform float foam_range = 16.0;
uniform float wave_amp = 1.0;


varying vec3 eye_vector;

vec3 getPosition(mat4 camera) {
	return (-camera[3] * camera).xyz;
	}

void vertex(){
	vec3 vert_new = VERTEX;
	vert_new += (texture(water_normal, (UV*uv_scale)+TIME*time_factor).xyz 
					* vec3(2.0, 2.0, 1.0) - vec3(1.0, 1.0, 0.0)) 
				* wave_amp;
	VERTEX = vert_new;
	
	vec3 cam_pos = getPosition(INV_CAMERA_MATRIX).xyz;
	eye_vector = normalize(VERTEX - cam_pos);
	
}

float fresnel(float n1, float n2, float cos_theta) {
	float R0 = pow((n1 - n2) / (n1+n2), 2);
	return R0 + (1.0 - R0)*pow(1.0 - cos_theta, 5);
}

void fragment(){
	/** Handling depth issues for GLES2 Renderer **/
	vec4 depth_tex = texture(DEPTH_TEXTURE, SCREEN_UV) * 2.0 - 1.0;
	vec4 world_coord = INV_PROJECTION_MATRIX * vec4(SCREEN_UV, depth_tex.r, 1.0);
	world_coord.xyz /= world_coord.w;
	
	/** Begin actual shader code **/
	
	// Handle normal mapping
	NORMALMAP = texture(
				water_normal, (UV*uv_scale)+TIME*time_factor).xyz;
	NORMALMAP_DEPTH = 1.0;
	NORMAL = normalize(NORMAL + NORMALMAP * NORMALMAP_DEPTH);

	// Depth map based transparency	
	float alpha_component = clamp(
		smoothstep(world_coord.z, world_coord.z+visible_depth, VERTEX.z), surface_water.w, deep_water.w);
		
	// Edge transparency and foam
	float edge_percentage = clamp(
		smoothstep(world_coord.z, world_coord.z+foam_range, VERTEX.z), 0.0, 1.0);
	
	float n1 = 1.000;
	float n2 = 1.888;
	
	float theta = dot(eye_vector, NORMALMAP);
	
	float reflectiveness = fresnel(n1, n2, abs(theta));
	
	vec3 shallow2Deep = mix(surface_water.xyz, deep_water.xyz, alpha_component);
	vec3 foamAtEdge = mix(foam_color.xyz, shallow2Deep, edge_percentage);
	
	ALBEDO = mix(foamAtEdge, specular_color.xyz, reflectiveness*specular_color.w);
	
	ALPHA = alpha_component;
	
	
	/** Enable alpha clipping to handle depth texture read issues. Additionally added smoothing based on foam **/
	ALPHA *= clamp(smoothstep(world_coord.z, world_coord.z+foam_range/4.0, VERTEX.z), 0.0, 1.0);
}