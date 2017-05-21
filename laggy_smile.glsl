//  http://glslsandbox.com/e#40575.4
//
//  Made by FiTH
//
//  fithisback@gmail.com
//  https://github.com/FiTH-is-my-name/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2  mouse;
uniform vec2  resolution;
//  uniform sampler2D backbuffer;

bool        lag_time;
vec2        coord_r;
vec2        coord_g;
vec2        coord_b;
vec2        center           = resolution / 2.0;
const float deg              = 3.1415926 / 180.0;
const float background_color = 0.2;
const float head_size        = 150.0;
const float mouth_size       = 75.0;
const float eye_size         = 40.0;

vec2 circle_color(vec2 pos, float r, float color, float current_color, vec2 current_coord) {
	//  result[0] - result
	//  result[1] - if lower than 0.0 - nothing was drawn, if greater than 0.0 - something was drawn
	vec2 result = vec2(-1.0);

	if (distance(pos, current_coord) < r + 3.0) {
		float temp = smoothstep(r + 3.0, r, distance(pos, current_coord));
		result[0] = temp * color + (1.0 - temp) * current_color;
		result[1] = 1.0;
	}

	return result;
}

bool circle(vec2 pos, float r, vec3 color) {
	bool result = false;
	vec2 temp;

	temp = circle_color(pos, r, color.r, gl_FragColor.r, coord_r);
	if (temp[1] > 0.0) {
		gl_FragColor.r = temp[0];
		result = true;
	}

	temp = circle_color(pos, r, color.g, gl_FragColor.g, coord_g);
	if (temp[1] > 0.0) {
		gl_FragColor.g = temp[0];
		result = true;
	}

	temp = circle_color(pos, r, color.b, gl_FragColor.b, coord_b);
	if (temp[1] > 0.0) {
		gl_FragColor.b = temp[0];
		result = true;
	}

	return result;
}

vec2 dead_eye_color(vec2 pos, float size, float color, float current_color, vec2 current_coord) {
	//  result[0] - result
	//  result[1] - if lower than 0.0 - nothing was drawn, if greater than 0.0 - something was drawn
	vec2 result = vec2(-1.0);

	if (current_coord.y - pos.y >= tan(deg * 45.0) * (current_coord.x - pos.x) - size / 2.0
	   && current_coord.y - pos.y <= tan(deg * 45.0) * (current_coord.x - pos.x) + size / 2.0
	   || current_coord.y - pos.y >= tan(deg * -45.0) * (current_coord.x - pos.x) - size / 2.0
	   && current_coord.y - pos.y <= tan(deg * -45.0) * (current_coord.x - pos.x) + size / 2.0) {
		float temp = smoothstep(size + 3.0, size, distance(pos, current_coord));
		if (temp > 0.0) {
			result[0] = temp * color + (1.0 - temp) * current_color;
			result[1] = 1.0;
		}
	}

	return result;
}

bool dead_eye(vec2 pos, float size, vec3 color) {
	bool result = false;
	vec2 temp;

	temp = dead_eye_color(pos, size, color.r, gl_FragColor.r, coord_r);
	if (temp[1] > 0.0) {
		gl_FragColor.r = temp[0];
		result = true;
	}

	temp = dead_eye_color(pos, size, color.g, gl_FragColor.g, coord_g);
	if (temp[1] > 0.0) {
		gl_FragColor.g = temp[0];
		result = true;
	}

	temp = dead_eye_color(pos, size, color.b, gl_FragColor.b, coord_b);
	if (temp[1] > 0.0) {
		gl_FragColor.b = temp[0];
		result = true;
	}

	return result;
}

vec2 mouth_color(vec2 pos, float size, float color, float current_color, vec2 current_coord) {
	//  result[0] - result
	//  result[1] - if lower than 0.0 - nothing was drawn, if greater than 0.0 - something was drawn
	vec2 result = vec2(-1.0);

	if (distance(pos, current_coord) < size + 3.0 && distance(pos + vec2(0.0, size * 1.5), current_coord) > size * 2.0) {
		float temp = min(
			smoothstep(size + 3.0, size, distance(pos, current_coord)),
			smoothstep(size * 2.0, size * 2.0 + 3.0, distance(pos + vec2(0.0, size * 1.5), current_coord))
		);
		result[0] = temp * color + (1.0 - temp) * current_color;
		result[1] = 1.0;
	}

	return result;
}

bool mouth(vec2 pos, float size, vec3 color) {
	bool result = false;
	vec2 temp;

	temp = mouth_color(pos, size, color.r, gl_FragColor.r, coord_r);
	if (temp[1] > 0.0) {
		gl_FragColor.r = temp[0];
		result = true;
	}

	temp = mouth_color(pos, size, color.g, gl_FragColor.g, coord_g);
	if (temp[1] > 0.0) {
		gl_FragColor.g = temp[0];
		result = true;
	}

	temp = mouth_color(pos, size, color.b, gl_FragColor.b, coord_b);
	if (temp[1] > 0.0) {
		gl_FragColor.b = temp[0];
		result = true;
	}

	return result;
}

//  x * x   y * y
//  ----- = ----- = 1 - ellipse
//  a * a   b * b
vec2 dead_mouth_color(vec2 pos, float size, float color, float current_color, vec2 current_coord) {
	//  result[0] - result
	//  result[1] - if lower than 0.0 - nothing was drawn, if greater than 0.0 - something was drawn
	vec2  result     = vec2(-1.0);
	vec2  temp_coord = pos - current_coord;  //  distance from origin (dot (0; 0))
	float temp       = smoothstep(1.0, 0.9, (temp_coord.x * temp_coord.x) / (size * size) + (temp_coord.y * temp_coord.y) / (size * size * 0.25));

	if (temp > 0.0) {
		result[0] = temp * color + (1.0 - temp) * current_color;
		result[1] = 1.0;
	}

	return result;
}

bool dead_mouth(vec2 pos, float size, vec3 color) {
	bool result = false;
	vec2 temp;

	temp = dead_mouth_color(pos, size, color.r, gl_FragColor.r, coord_r);
	if (temp[1] > 0.0) {
		gl_FragColor.r = temp[0];
		result = true;
	}

	temp = dead_mouth_color(pos, size, color.g, gl_FragColor.g, coord_g);
	if (temp[1] > 0.0) {
		gl_FragColor.g = temp[0];
		result = true;
	}

	temp = dead_mouth_color(pos, size, color.b, gl_FragColor.b, coord_b);
	if (temp[1] > 0.0) {
		gl_FragColor.b = temp[0];
		result = true;
	}

	return result;
}

void preprocess() {
	if (lag_time) {
		if (sin(time * 4.0) > 0.2) {
			coord_r.x += 20.0;
			coord_g.x += 20.0;
			coord_b.x += 20.0;
		}
		
		if (sin(time * 8.0) > 0.2) {
			if (gl_FragCoord.x < center.x && gl_FragCoord.y > center.y) {
				coord_r.x += 20.0;
				coord_g.x += 40.0;
				coord_b.x += 30.0;
			} else if (gl_FragCoord.x > center.x && gl_FragCoord.y < center.y) {
				coord_r.x -= 40.0;
				coord_g.x -= 20.0;
				coord_b.x -= 20.0;
			}
		}
		
		//  turn upside down
		if (sin(time * 2.0) > 0.5) {
			coord_r.y = resolution.y - coord_r.y;
			coord_g.y = resolution.y - coord_g.y;
			coord_b.y = resolution.y - coord_b.y;
		}
		
		coord_r += 3.0;
		coord_g.x += sin(gl_FragCoord.y * 4.0) * 2.0 + cos(time * 10.0) * 2.0;

		if (sin(gl_FragCoord.x / 12.0) > 0.6)
			coord_g.y += 5.0;
		if (sin(gl_FragCoord.y / 10.0) > 0.0)
			coord_r.x += 3.0;
		
		coord_r.x += sin(gl_FragCoord.y / 12.0 + time * 12.0) * 2.0;
		coord_g.x += cos(gl_FragCoord.y / 12.0 + time * 12.0) * 2.0;
		coord_b.x += sin(gl_FragCoord.y / 12.0 + time * 12.0) * 2.0;
	}
}

void postprocess() {
	if (lag_time) {
		if (sin(gl_FragCoord.x / 8.0) > 0.0)
			gl_FragColor.b += 0.4;
		
		if (sin(gl_FragCoord.x) > 0.2 && fract(cos(gl_FragCoord.y) * resolution.y) > 0.1 && sin(time * 8.0) > 0.3) {
			gl_FragColor = vec4(gl_FragColor.rgb * 0.8 + 0.2, 1.0);
		}
	}
}

void main() {
	bool detected = false;
	coord_r       = gl_FragCoord.xy;  //  thanks to this we can control the displacement of each color separately
	coord_g       = gl_FragCoord.xy;  //
	coord_b       = gl_FragCoord.xy;  //
	gl_FragColor  = vec4(vec3(background_color), 1.0);	
	
	lag_time = sin(time * 3.0) > 0.2 ? true : false;
	
	//  preprocess
	preprocess();
	
	//  main image
	detected = circle(center, head_size, vec3(1.0, 1.0, 0.0));
	
	if (lag_time) {
		detected = dead_eye(center + vec2(-head_size * 0.4, head_size * 0.4), eye_size, vec3(0.0)) || detected;
		detected = dead_eye(center + vec2(head_size * 0.4, head_size * 0.4), eye_size, vec3(0.0))  || detected;
		detected = dead_mouth(center + vec2(0.0, -head_size * 0.5), mouth_size, vec3(0.0))         || detected;
	} else {
		detected = circle(center + vec2(-head_size * 0.4, head_size * 0.4), eye_size, vec3(0.0)) || detected;
		detected = circle(center + vec2(head_size * 0.4, head_size * 0.4), eye_size, vec3(0.0))  || detected;
		detected = mouth(center, mouth_size * 1.5, vec3(0.0))                                    || detected;
	}
	
	//  postprocess
	if (detected)
		postprocess();
}
