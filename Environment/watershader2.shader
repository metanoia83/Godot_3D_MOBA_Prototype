shader_type spatial;
render_mode unshaded,depth_draw_opaque, blend_mix ;


uniform sampler2D noise1;
uniform sampler2D noise2;
uniform sampler2D noise3;
uniform float speed: hint_range(-1,1) = 0.0;
uniform vec4 water_color: hint_color;
uniform bool is_displaced;



void fragment(){
	float t = TIME * speed;
	vec3 v1 = texture(noise1, UV + t).rgb;
	vec3 v2 = texture(noise2, UV - t).rgb;
	vec3 v3 = texture(noise3, UV + t).rgb;
	float sum = (v1.r + v2.r + v3.r) - 1.75;

	
	
	
	vec2 displacement = vec2(0);
	
	if (is_displaced && water_color.a < 1.0){
		displacement = vec2(sum * 0.008);
	}
	
	
	vec4 back = vec4(1.0);
	
	if (water_color.a < 1.0){
		back = texture(SCREEN_TEXTURE,SCREEN_UV + displacement)
	}
	

	
	float fin = 0.0;
	
	if (sum > 0.0 && sum < 0.2) fin  = 0.1;
	if (sum > 0.2 && sum < 0.5) fin  = 0.05;
	if (sum > 0.5) fin  = 0.6;
	

	
	ALBEDO = vec3(fin) + mix(back.rgb, water_color.rgb, water_color.a);
}

