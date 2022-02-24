shader_type spatial;
render_mode cull_disabled, skip_vertex_transform, shadows_disabled;

uniform float speed = 1.0;
uniform float strength = 0.1;
uniform float detail = 1.0;
uniform vec2 direction = vec2(1.0, 0.0);
uniform float heightOffset = 0.0;

void vertex(){
	vec4 worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0);

	float time = TIME * speed + worldPos.x + worldPos.z;
	float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, VERTEX.y - heightOffset);
	vec2 dir = normalize(direction);
	worldPos.xz += vec2(wind * dir.x, wind * dir.y);
	VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz;
	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
}
uniform sampler2D diffuse : hint_albedo;

void fragment(){
	ALBEDO = texture(diffuse, UV).rgb;
	ALPHA = texture(diffuse, UV).a;
	}
