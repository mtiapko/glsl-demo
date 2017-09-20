//  http://glslsandbox.com/e#41584.0
//
//  Made by FiTH
//
//  https://github.com/mtiapko/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2  mouse;
uniform vec2  resolution;

//  from polar to rectangular
vec2 from_polar(float r, float angle)
{
	return vec2(r * cos(angle), r * sin(angle));
}

float rand(vec2 seed)
{
	return pow(fract(sin(dot(seed.xy, vec2(20.1996, 67.89))) * 65536.1337), 69.0);
}

void main()
{
	vec3 color;
	vec2 uv = vec2(gl_FragCoord.x, gl_FragCoord.y) / min(resolution.x, resolution.y);
	
	//  positions
	float sun_y = sin(time) * 0.5 + 0.3;
	float moon_y = sin(time) * 0.5 + 1.3;
	float ground_y = sin(uv.x * 3.0 + time * 1.5) * 0.1 + 0.2;
	vec2 figure_xy = vec2(0.5, 0.195 + sin(0.5 * 3.0 + time * 1.5) * 0.1 + 0.2);

	//  factors
	float sun_rgb = 1.0 - smoothstep(0.055, 0.1 + sin(time) * 0.04, distance(uv, vec2(0.85, sun_y)));
	float moon_rgb = 1.0 - smoothstep(0.095, 0.1, distance(uv, vec2(0.85, moon_y)));
	float ground_rgb = smoothstep(0.005, 0.0, uv.y - ground_y);
	float stars_rgb = 1.0 - smoothstep(-0.2, 0.0, sun_y);
	
	float center_r = smoothstep(0.045, 0.05, distance(uv + from_polar(0.085, -time * 1.50 + 2.0 * 3.1415926 * 0.00), figure_xy));
	float center_g = smoothstep(0.045, 0.05, distance(uv + from_polar(0.085, -time * 1.50 + 2.0 * 3.1415926 * 0.33), figure_xy));
	float center_b = smoothstep(0.045, 0.05, distance(uv + from_polar(0.085, -time * 1.50 + 2.0 * 3.1415926 * 0.66), figure_xy));
	
	float figure_r = 1.0 - smoothstep(0.095, 0.1, distance(uv + from_polar(0.085, -time * 1.50 + 2.0 * 3.1415926 * 0.00), figure_xy));
	float figure_g = 1.0 - smoothstep(0.095, 0.1, distance(uv + from_polar(0.085, -time * 1.50 + 2.0 * 3.1415926 * 0.33), figure_xy));
	float figure_b = 1.0 - smoothstep(0.095, 0.1, distance(uv + from_polar(0.085, -time * 1.50 + 2.0 * 3.1415926 * 0.66), figure_xy));

	//  figure
	color.r = 0.2 * sun_y + figure_r * center_r;
	color.g = 0.2 * sun_y + figure_g * center_g;
	color.b = 0.5 * sun_y + figure_b * center_b;
	
	// sun & ground
	color.r += sun_rgb - 2.0 * ground_rgb;
	color.g += sun_rgb * 0.7 + (0.4 - 0.7 * sun_rgb) * ground_rgb;
	color.b -= sun_rgb + ground_rgb;
	
	//  moon
	color.r += 2.0 * moon_rgb;
	color.g += 2.0 * moon_rgb;
	color.b += 2.0 * moon_rgb;
	
	//  stars
	color.r += 0.5 * stars_rgb * rand(uv) * (1.0 - ground_rgb) * (1.0 - figure_r * center_r) * (1.0 - figure_g * center_g) * (1.0 - figure_b * center_b);
	color.g += 0.5 * stars_rgb * rand(uv) * (1.0 - ground_rgb) * (1.0 - figure_r * center_r) * (1.0 - figure_g * center_g) * (1.0 - figure_b * center_b);
	color.b += 0.5 * stars_rgb * rand(uv) * (1.0 - ground_rgb) * (1.0 - figure_r * center_r) * (1.0 - figure_g * center_g) * (1.0 - figure_b * center_b);
	
	gl_FragColor = vec4(color, 1.0);
}
