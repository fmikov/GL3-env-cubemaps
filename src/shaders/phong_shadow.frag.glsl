precision highp float;

//varying ...
//varying ...
varying vec2 v2f_uv;
varying vec3 frag_pos;
varying vec3 normal;


uniform vec3 light_position; // light position in camera coordinates
uniform vec3 light_color;
uniform samplerCube cube_shadowmap;
uniform sampler2D tex_color;

void main() {

	float material_shininess = 12.;

	/* #TODO GL3.1.1
	Sample texture tex_color at UV coordinates and display the resulting color.
	*/
	vec3 material_color = vec3(texture2D(tex_color, v2f_uv));
	
	/*
	#TODO GL3.3.1: Blinn-Phong with shadows and attenuation

	Compute this light's diffuse and specular contributions.
	You should be able to copy your phong lighting code from GL2 mostly as-is,
	though notice that the light and view vectors need to be computed from scratch here; 
	this time, they are not passed from the vertex shader. 
	Also, the light/material colors have changed; see the Phong lighting equation in the handout if you need
	a refresher to understand how to incorporate `light_color` (the diffuse and specular
	colors of the light), `v2f_diffuse_color` and `v2f_specular_color`.
	
	To model the attenuation of a point light, you should scale the light
	color by the inverse distance squared to the point being lit.
	
	The light should only contribute to this fragment if the fragment is not occluded
	by another object in the scene. You need to check this by comparing the distance
	from the fragment to the light against the distance recorded for this
	light ray in the shadow map.
	
	To prevent "shadow acne" and minimize aliasing issues, we need a rather large
	tolerance on the distance comparison. It's recommended to use a *multiplicative*
	instead of additive tolerance: compare the fragment's distance to 1.01x the
	distance from the shadow map.

	Implement the Blinn-Phong shading model by using the passed
	variables and write the resulting color to `color`.

	Make sure to normalize values which may have been affected by interpolation!
	*/
	vec3 color = vec3(0., 0., 0.);

	vec3 direction_to_camera = normalize(-frag_pos);
	vec3 direction_to_light = normalize(light_position - frag_pos);
	float distance_to_light = length(light_position - frag_pos);


	vec3 light_color_scaled = light_color / (distance_to_light * distance_to_light);

	vec3 norm_normal = normalize(normal);
	vec3 norm_direction_to_light = normalize(direction_to_light);
	vec3 norm_direction_to_camera = normalize(direction_to_camera);

	vec3 diffuse = light_color_scaled * material_color * dot(norm_normal, norm_direction_to_light);

	vec3 specular_blinn;
	vec3 half_vector = normalize(norm_direction_to_light + norm_direction_to_camera);
	
	specular_blinn = light_color_scaled *  material_color * pow(dot(norm_normal, half_vector), material_shininess);
	vec3 blinn_light = diffuse + specular_blinn;

	if(dot(norm_normal, norm_direction_to_light) < 0.)
		color = vec3(0., 0., 0.);
	else if(dot(norm_normal, half_vector) < 0.)
		color = diffuse;
	else
		color = blinn_light;

	// shadow mapping
	
	float distance_shadow_map = textureCube(cube_shadowmap, normalize(frag_pos-light_position)).x;
	

	if(distance_to_light > distance_shadow_map * 1.01)
		color = vec3(0., 0., 0.);
		
	float material_ambient = 0.1;
	color += light_color_scaled * material_ambient * material_color;
	gl_FragColor = vec4(color, 1.); // output: RGBA in 0..1 range
}
