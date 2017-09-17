//  http://glslsandbox.com/e#42513.0
//
//  Made by FiTH
//
//  https://github.com/FiTH-is-my-name

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D backbuffer;

const float pi = 3.1415026;

vec2 to_polar(vec2 coord)
{
	float r = length(coord);

	if (coord.x > 0.0) {
		return vec2(r, atan(coord.y / coord.x));
	} else if (coord.x < 0.0) {
		if (coord.y >= 0.0)
			return vec2(r, atan(coord.y / coord.x) + pi);
		else
			return vec2(r, atan(coord.y / coord.x) - pi);
	}
	return vec2(r, pi);
}

void main()
{
	vec3 color = vec3(0.1);
	vec2 coord = gl_FragCoord.xy / resolution;
	float persp_coord_x = (2.0 * gl_FragCoord.x - resolution.x) / resolution.x;
	float persp_coord_y = (2.0 * gl_FragCoord.y - resolution.y) / resolution.y;
	float min_size = min(resolution.x, resolution.y);
	float delta = sin(gl_FragCoord.x * 0.01 + time) * 0.05;
	float time_val = time * 4.0;

	if (coord.y < 0.6 + delta)
	{
		color += smoothstep(0.85, 0.95, sin((gl_FragCoord.x - resolution.x * 0.5) / (4.0 - persp_coord_y * 8.0))) * vec3(0.1, 0.7, 0.6);
		color += smoothstep(0.98, 1.0, sin(((coord.y - delta) * (coord.y - delta)) * 60.0 + time_val)) * vec3(0.1, 0.7, 0.6);
	}
	else if (coord.y < 0.605 + delta)
		color += vec3(0.1, 0.7, 0.6);
	else
	{
		float sun_pos = smoothstep(min_size * 0.40, min_size * 0.405, distance(gl_FragCoord.xy, vec2(resolution / 2.0)));
		color += (1.0 - sun_pos) * vec3(0.35, 0.0, 0.6) * smoothstep(-0.5, 0.2, sin(gl_FragCoord.y * 0.4 - time_val));
		color += sun_pos * smoothstep(0.0, 0.8, sin(to_polar(coord - vec2(0.5, 0.6)).y * 15.0 + time_val)) * vec3(0.7, 0.3, 0.3);
		color = color * 0.3 + texture2D(backbuffer, coord).rgb * 0.8;
	}
	gl_FragColor = vec4(color, 1.0);
}
