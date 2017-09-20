//  http://glslsandbox.com/e#40566.2
//
//  Made by FiTH
//
//  fithisback@gmail.com
//  https://github.com/mtiapko/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2  mouse;
uniform vec2  resolution;

#define ENABLE_PREPROCESS
#define ENABLE_POSTPROCESS

//  small circles move only in a straight line
vec2        center = resolution.xy / 2.0;                         //  center of display
float       speed  = time * 1.0;                                  //  small circles rotation speed
float       R      = resolution.y * min(max(mouse.y, 0.1), 0.4);  //  radius of big circle
float       ball_R = R * min(max(mouse.x, 0.01), 0.05);           //  radius of small circles
const float deg    = 3.1415926 / 180.0;                           //  degrees -> radians
const float delta  = 15.0;                                        //  angle betwen small circles (count of small circles = 180 degrees / delta)
const float E      = 0.02;                                        //  epsilon (float minus float not always 0)

//  x - x1    x - y1
//  ------- = ------- - equation of a straight line passing through 2 dots
//  x2 - x1   y2 - y1
bool line(vec2 current_coord, vec2 pos1, vec2 pos2, float max_size) {
	float x = pos2.x - pos1.x;
	float y = pos2.y - pos1.y;
	
	if (distance(pos1, current_coord.xy) <= max_size) {
		//  draw line
		if ((current_coord.x - pos1.x) / x <= (current_coord.y - pos1.y) / y + E
	   	    && (current_coord.x - pos1.x) / x >= (current_coord.y - pos1.y) / y - E) {
			gl_FragColor = vec4(vec3(1.0), 1.0);
			return true;
		//  draw line parallel to the axis OY
		} else if (x >= -E && x <= E && current_coord.x <= pos1.x + 1.0 && current_coord.x >= pos1.x - 1.0) {
			gl_FragColor = vec4(vec3(1.0), 1.0);
			return true;
		//  draw line parallel to the axis OX
		} else if (y >= -E && y <= E && current_coord.y <= pos1.y + 1.0 && current_coord.y >= pos1.y - 1.0) {
			gl_FragColor = vec4(vec3(1.0), 1.0);
			return true;
		}
	}

	return false;
}

/*float lineSmooth(vec2 p, vec2 a, vec2 b) {
	vec2 aTob = b - a;
	vec2 aTop = p - a;
	
	float t = dot(aTop, aTob) / dot(aTob, aTob);
	
	t = clamp(t, 0.0, 1.0);
	
	float d = length(p - (a + aTob * t));
	d = E / d;
	
	return clamp(d, 0.0, 1.0);
}*/

bool circle(vec2 current_coord, vec2 pos, float r) {
	if (distance(pos, current_coord.xy) <= r + 5.0) {
		gl_FragColor = vec4(vec3(smoothstep(r + 5.0, r, distance(pos, current_coord.xy)), 0.5, 0.0), 1.0);
		return true;
	}

	return false;
}

bool circleSmooth(vec2 current_coord, vec2 pos, float r) {
	if (distance(pos, current_coord.xy) <= r + 5.0) {
		gl_FragColor = vec4(vec3(1.0, smoothstep(r + 5.0, r, distance(pos, current_coord.xy)) * 0.8, 0.0), 1.0);
		return true;
	}

	return false;
}

bool ball(vec2 current_coord, float angle, float start) {
	//  cos(deg * angle), sin(deg * angle) - angle of circle axis
	//  sin(speed + start)                 - circle position on his axis
	return circle(current_coord, vec2(center.x + cos(deg * angle) * sin(speed + start) * (R - ball_R), center.y + sin(deg * angle) * sin(speed + start) * (R - ball_R)), ball_R);
}

vec2 preprocess() {
#ifdef ENABLE_PREPROCESS
	//  waves (same horizontal and vertical)
	vec2 temp = gl_FragCoord.xy + sin(gl_FragCoord.x / 8.0 + time * 3.0) * 3.0;
	
	//  angle
	temp.x = temp.x - 100.0 * gl_FragCoord.y / resolution.y;
	
	return temp;
#else
	return gl_FragCoord.xy;
#endif
}

void postprocess(vec2 current_coord) {
#ifdef ENABLE_POSTPROCESS
	//  shadow for waves
	gl_FragColor = vec4(gl_FragColor.rgb * (sin(current_coord.x / 8.0 + time * 3.0) + 2.0) / 2.0, 1.0);

	//  cloth texture
	gl_FragColor = gl_FragColor * max(sin(gl_FragCoord.x * 2.0) * cos(gl_FragCoord.y * 2.0), 0.5);
#endif
}

void main() {
	//  is it something drawn or is it a background?
	bool flag_detected          = false;
	bool circle_smooth_detected = false;
	bool line_detected          = false;
	bool ball_detected          = false;
	
	//  preprocess
	vec2 current_coord = preprocess();
	
	//  flag
	if (current_coord.x > center.x - R * 2.0 && current_coord.x < center.x + R * 2.0
	    && current_coord.y > center.y - R * 1.5 && current_coord.y < center.y + R * 1.5) {
		gl_FragColor = vec4(vec3(0.2, 0.0, 0.0), 1.0);
		flag_detected = true;
	} else
		//  background
		gl_FragColor = vec4(vec3(0.2), 1.0);
	
	//  big circle
	circle_smooth_detected = circleSmooth(current_coord, center, R);
	
	//  lines
	for (float i = 0.0; i < 180.0 / delta; ++i)
		line_detected = line(current_coord, center, vec2(center.x + R * cos(i * delta * deg), center.y + R * sin(i * delta * deg)), R) || line_detected;
	
	//  small circles
	for (float i = 0.0; i < 180.0 / delta; ++i) 
		ball_detected = ball(current_coord, delta * i, deg * delta * i) || ball_detected;

	//  postprocess if it is not background
	if (flag_detected || circle_smooth_detected || line_detected || ball_detected)
		postprocess(current_coord);
}
