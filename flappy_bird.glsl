//  http://glslsandbox.com/e#40607.0
//
//  Made by FiTH
//
//  fithisback@gmail.com
//  https://github.com/FiTH-is-my-name

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                     *
 *                                                                     *
 *                       F L A P P Y   B I R D                         *
 *                                                                     *
 *                                                                     *
 *                        Hello from May 2013                          *
 *                                                                     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                     *
 *  I N F O:                                                           *
 *                                                                     *
 *    * You lose if you touch pipes or floor                           *
 *    * It is impossible to win here, of course if you are not a God   *
 *    * Green number - current score                                   *
 *    * Orange number - last score                                     *
 *    * For faster or slower game change:                              *
 *        ~ render resolution                                          *
 *        ~ TOWER_SPEED - horizontal speed                             *
 *        ~ BIRD_GRAVITY / BIRD_POWER - vertical speed                 *
 *                                                                     *
 *  C O N T R O L:                                                     *
 *                                                                     *
 *    * To take off, move the mouse along the Y axis                   *
 *                                                                     *
 *                                                                     *
 *                              Have fun!                              *
 *                                                                     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

uniform float     time;
uniform vec2      mouse;
uniform vec2      resolution;
uniform sampler2D backbuffer;  //  need for data storage

//  game parameters
const float E                 = 0.01;
const float DELAY_BEFORE_GAME = 1.0;  //  delay before start new game
const float BIRD_SIZE         = 0.05;
const float BIRD_POS_X        = 0.15;
const float BIRD_POWER        = 0.01;
const float BIRD_GRAVITY      = 0.007;
const float TOWER_SPEED       = 0.002;
const vec3  DIGIT_DISABLE     = vec3(0.15, 0.15, 0.15);
const float TOWER_WIDTH       = 0.03;
const float TOWER_TOP_WIDTH   = 0.05;
const float TOWER_TOP_HEIGHT  = 0.03;
const float TOWER_DISTANCE    = 0.4;
float       CLOUD_PART_SIZE[5];
vec2        CLOUD_PART_POS[5];

//  game data locations
//  all data is stored in the bottom left corner
const float data_size                    = 0.01;  //  float is not very accurate, so we write down information in a lot of pixels, and read from the center of this area
const vec2  init_data_location           = vec2(0.0, 0.0);
const vec2  bird_pos_data_location       = vec2(1.0, 0.0);
const vec2  tower_high_pos_data_location = vec2(2.0, 0.0);
const vec2  tower_low_pos_data_location  = vec2(3.0, 0.0);
const vec2  last_tower_id_data_location  = vec2(4.0, 0.0);
const vec2  score_data_location          = vec2(5.0, 0.0);
const vec2  last_score_data_location     = vec2(6.0, 0.0);
const vec2  mouse_pos_data_location      = vec2(7.0, 0.0);
const vec2  delay_time_data_location     = vec2(8.0, 0.0);  //  need for delay before new game

vec2  coord;  //  modificated gl_FragCoord.xy
vec2  bird_pos;
vec2  tower_pos[3];
float last_tower_id;
vec4  score;
vec4  last_score;
float mouse_last_y;
float delay_time;

bool is_data_location(vec2 location) {
	location *= data_size;

	if (coord.x > location.x && coord.x < location.x + data_size
	    && coord.y > location.y && coord.y < location.y + data_size)
		return true;

	return false;
}

vec4 read_data_from_location(vec2 location) {
	return texture2D(backbuffer, (location + 0.5) * data_size);  //  location + 0.5 - center of this area
}

void start_game() {
	delay_time    = DELAY_BEFORE_GAME;
	bird_pos      = vec2(BIRD_POS_X, 0.5);
	tower_pos[0]  = vec2(0.5, 0.3 + sin(time) * 0.2);
	tower_pos[1]  = vec2(0.7, 0.3 + sin(time) * 0.2);
	tower_pos[2]  = vec2(0.9, 0.3 + sin(time) * 0.2);
	last_tower_id = 0.3;  //  should not be 0.0, in the new game id of the first tower that we cross will be '0' (0.0 color on display)
	last_score    = score;
	score         = vec4(0.0);
}

void read_data() {
	if (read_data_from_location(init_data_location)[0] < 0.5) {  //  init data
		start_game();
		return;
	}

	bird_pos      = read_data_from_location(bird_pos_data_location).xy;
	tower_pos[0]  = read_data_from_location(tower_high_pos_data_location).xy;
	tower_pos[1]  = read_data_from_location(tower_high_pos_data_location).zw;
	tower_pos[2]  = read_data_from_location(tower_low_pos_data_location).xy;
	last_tower_id = read_data_from_location(last_tower_id_data_location).x;
	score         = read_data_from_location(score_data_location);
	last_score    = read_data_from_location(last_score_data_location);
	mouse_last_y  = read_data_from_location(mouse_pos_data_location).x;
	delay_time    = read_data_from_location(delay_time_data_location).x;
}

void save_data() {
	if (is_data_location(init_data_location)) {
		gl_FragColor = vec4(1.0);
		return;
	}

	if (is_data_location(bird_pos_data_location)) {
		gl_FragColor = vec4(bird_pos, vec2(0.0));
		return;
	}

	if (is_data_location(tower_high_pos_data_location)) {
		gl_FragColor = vec4(tower_pos[0], tower_pos[1]);
		return;
	}

	if (is_data_location(tower_low_pos_data_location)) {
		gl_FragColor = vec4(tower_pos[2], vec2(0.0));
		return;
	}

	if (is_data_location(last_tower_id_data_location)) {
		gl_FragColor = vec4(last_tower_id, vec3(0.0));
		return;
	}

	if (is_data_location(score_data_location)) {
		gl_FragColor = score;
		return;
	}

	if (is_data_location(last_score_data_location)) {
		gl_FragColor = last_score;
		return;
	}

	if (is_data_location(mouse_pos_data_location)) {
		gl_FragColor = vec4(mouse.y, vec3(0.0));
		return;
	}

	if (is_data_location(delay_time_data_location)) {
		gl_FragColor = vec4(delay_time, vec3(0.0));
		//  return - last operation, not need return
	}
}

void drawBackground() {
	gl_FragColor = vec4(vec3(0.0, 0.35, 0.4), 1.0);
}

void drawCloud(vec2 pos) {
	float temp;
	for (int i = 0; i < 5; ++i) {
		temp = max(temp, smoothstep(CLOUD_PART_SIZE[i] + 0.01, CLOUD_PART_SIZE[i], distance(coord, pos + CLOUD_PART_POS[i])));
	}

	if (temp > 0.0)
		gl_FragColor = vec4(vec3(mix(vec3(0.0, 0.35, 0.4), vec3(1.0), temp)), 1.0);
}

bool drawTowers(vec2 pos) {
	pos.x *= 1.65;

	//  bottom tower
	if (coord.y < pos.y) {
		if (coord.y > pos.y - TOWER_TOP_HEIGHT) {
			if (coord.x > pos.x - TOWER_TOP_WIDTH && coord.x < pos.x + TOWER_TOP_WIDTH) {
				float temp = 6.0 * (TOWER_TOP_WIDTH - distance(pos.x - TOWER_TOP_WIDTH * 0.4, coord.x));
				gl_FragColor = vec4(vec3(0.1 + temp, 0.45 + temp, 0.1 + temp), 1.0);
			}
		} else if (coord.x > pos.x - TOWER_WIDTH && coord.x < pos.x + TOWER_WIDTH) {
			float temp = 10.0 * (TOWER_WIDTH - distance(pos.x - TOWER_WIDTH * 0.4, coord.x));
			gl_FragColor = vec4(vec3(0.0 * temp, 0.7 + temp, 0.2 + temp), 1.0);
		}
	//  top tower
	} else if (coord.y > pos.y + TOWER_DISTANCE) {
		if (coord.y < pos.y + TOWER_DISTANCE + TOWER_TOP_HEIGHT) {
			if (coord.x > pos.x - TOWER_TOP_WIDTH && coord.x < pos.x + TOWER_TOP_WIDTH) {
				float temp = 6.0 * (TOWER_TOP_WIDTH - distance(pos.x - TOWER_TOP_WIDTH * 0.4, coord.x));
				gl_FragColor = vec4(vec3(0.1 + temp, 0.45 + temp, 0.1 + temp), 1.0);
			}
		} else if (coord.x > pos.x - TOWER_WIDTH && coord.x < pos.x + TOWER_WIDTH) {
			float temp = 10.0 * (TOWER_WIDTH - distance(pos.x - TOWER_WIDTH * 0.4, coord.x));
			gl_FragColor = vec4(vec3(0.0 * temp, 0.7 + temp, 0.2 + temp), 1.0);
		}
	}

	return false;
}

void drawBird() {
	float temp = smoothstep(0.055, 0.05, distance(coord, bird_pos + vec2(0.0, (coord.x - BIRD_POS_X) * (bird_pos.y - 0.3))));
	if (temp > 0.0) {
		if (distance(coord, bird_pos + vec2(0.035, (coord.x - BIRD_POS_X) * (bird_pos.y - 0.3) + 0.015)) < 0.005)
			gl_FragColor = vec4(vec3(0.0, 0.0, 0.0), 1.0);  //  pupil (black part of eye)
		else if (distance(coord, bird_pos + vec2(0.03, (coord.x - BIRD_POS_X) * (bird_pos.y - 0.3) + 0.015)) < 0.01)
			gl_FragColor = vec4(vec3(1.0, 1.0, 1.0), 1.0);  //  sclera (white part of eye)
		else if (distance(coord, bird_pos + vec2(-0.005, (coord.x - BIRD_POS_X) * (bird_pos.y - 0.3) + sin(time * 5.0) * 0.02)) < 0.02)
			gl_FragColor = vec4(vec3(0.3, 0.3, 0.0), 1.0);  //  wing
		else
			gl_FragColor = vec4(mix(gl_FragColor.rgb, vec3(0.7, 0.7, 0.0), temp), 1.0);  //  body
	}
}

void drawBorder() {
	if (coord.x < TOWER_TOP_WIDTH || coord.x > 1.0 - TOWER_TOP_WIDTH)
		gl_FragColor = vec4(vec3(0.2), 1.0);
}

/* * * * * * * * * * * * * * * 
 *                           *
 *     7 segment display     *
 *                           *
 * * * * * * * * * * * * * * */
void print_a_element(vec2 pos, float digit_width, float digit_height, vec3 color) {
	if (coord.x > pos.x + digit_width * 0.2 && coord.x < pos.x + digit_width * 0.8
	    && coord.y > pos.y + digit_height * 0.85 && coord.y < pos.y + digit_height) {
		if (coord.x > pos.x * 1.005 + digit_width * 0.2 && coord.x < pos.x * 0.995 + digit_width * 0.8
		    && coord.y > pos.y * 1.005 + digit_height * 0.85 && coord.y < pos.y * 0.995 + digit_height)
			gl_FragColor = vec4(color, 1.0);
		else
			gl_FragColor = vec4(DIGIT_DISABLE, 1.0);
	}
}

void print_b_element(vec2 pos, float digit_width, float digit_height, vec3 color) {
	if (coord.x > pos.x + digit_width * 0.8 && coord.x < pos.x + digit_width
	    && coord.y > pos.y + digit_height * 0.575 && coord.y < pos.y + digit_height * 0.85) {
		if (coord.x > pos.x * 1.005 + digit_width * 0.8 && coord.x < pos.x * 0.995 + digit_width
		    && coord.y > pos.y * 1.005 + digit_height * 0.575 && coord.y < pos.y * 0.995 + digit_height * 0.85)
			gl_FragColor = vec4(color, 1.0);
		else
			gl_FragColor = vec4(DIGIT_DISABLE, 1.0);
	}
}

void print_c_element(vec2 pos, float digit_width, float digit_height, vec3 color) {
	if (coord.x > pos.x + digit_width * 0.8 && coord.x < pos.x + digit_width
	    && coord.y > pos.y + digit_height * 0.15 && coord.y < pos.y + digit_height * 0.425) {
		if (coord.x > pos.x * 1.005 + digit_width * 0.8 && coord.x < pos.x * 0.995 + digit_width
		    && coord.y > pos.y * 1.005 + digit_height * 0.15 && coord.y < pos.y * 0.995 + digit_height * 0.425)
			gl_FragColor = vec4(color, 1.0);
		else
			gl_FragColor = vec4(DIGIT_DISABLE, 1.0);
	}
}

void print_d_element(vec2 pos, float digit_width, float digit_height, vec3 color) {
	if (coord.x > pos.x + digit_width * 0.2 && coord.x < pos.x + digit_width * 0.8
	    && coord.y > pos.y && coord.y < pos.y + digit_height * 0.15) {
		if (coord.x > pos.x * 1.005 + digit_width * 0.2 && coord.x < pos.x * 0.995 + digit_width * 0.8
		    && coord.y > pos.y * 1.005 && coord.y < pos.y * 0.995 + digit_height * 0.15)
			gl_FragColor = vec4(color, 1.0);
		else
			gl_FragColor = vec4(DIGIT_DISABLE, 1.0);
	}
}

void print_e_element(vec2 pos, float digit_width, float digit_height, vec3 color) {
	if (coord.x > pos.x && coord.x < pos.x + digit_width * 0.2
	    && coord.y > pos.y + digit_height * 0.15 && coord.y < pos.y + digit_height * 0.425) {
		if (coord.x > pos.x * 1.005 && coord.x < pos.x * 0.995 + digit_width * 0.2
		    && coord.y > pos.y * 1.005 + digit_height * 0.15 && coord.y < pos.y * 0.995 + digit_height * 0.425)
			gl_FragColor = vec4(color, 1.0);
		else
			gl_FragColor = vec4(DIGIT_DISABLE, 1.0);
	}
}

void print_f_element(vec2 pos, float digit_width, float digit_height, vec3 color) {
	if (coord.x > pos.x && coord.x < pos.x + digit_width * 0.2
	    && coord.y > pos.y + digit_height * 0.575 && coord.y < pos.y + digit_height * 0.85) {
		if (coord.x > pos.x * 1.005 && coord.x < pos.x * 0.995 + digit_width * 0.2
		    && coord.y > pos.y * 1.005 + digit_height * 0.575 && coord.y < pos.y * 0.995 + digit_height * 0.85)
			gl_FragColor = vec4(color, 1.0);
		else
			gl_FragColor = vec4(DIGIT_DISABLE, 1.0);
	}
}

void print_g_element(vec2 pos, float digit_width, float digit_height, vec3 color) {
	if (coord.x > pos.x + digit_width * 0.2 && coord.x < pos.x + digit_width * 0.8
	    && coord.y > pos.y + digit_height * 0.425 && coord.y < pos.y + digit_height * 0.575) {
		if (coord.x > pos.x * 1.005 + digit_width * 0.2 && coord.x < pos.x * 0.995 + digit_width * 0.8
		    && coord.y > pos.y * 1.005 + digit_height * 0.425 && coord.y < pos.y * 0.995 + digit_height * 0.575)
			gl_FragColor = vec4(color, 1.0);
		else
			gl_FragColor = vec4(DIGIT_DISABLE, 1.0);
	}
}

void print_0(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, color);
	print_b_element(pos, width, height, color);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, color);
	print_e_element(pos, width, height, color);
	print_f_element(pos, width, height, color);
	print_g_element(pos, width, height, DIGIT_DISABLE);
}

void print_1(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, DIGIT_DISABLE);
	print_b_element(pos, width, height, color);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, DIGIT_DISABLE);
	print_e_element(pos, width, height, DIGIT_DISABLE);
	print_f_element(pos, width, height, DIGIT_DISABLE);
	print_g_element(pos, width, height, DIGIT_DISABLE);
}

void print_2(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, color);
	print_b_element(pos, width, height, color);
	print_c_element(pos, width, height, DIGIT_DISABLE);
	print_d_element(pos, width, height, color);
	print_e_element(pos, width, height, color);
	print_f_element(pos, width, height, DIGIT_DISABLE);
	print_g_element(pos, width, height, color);
}

void print_3(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, color);
	print_b_element(pos, width, height, color);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, color);
	print_e_element(pos, width, height, DIGIT_DISABLE);
	print_f_element(pos, width, height, DIGIT_DISABLE);
	print_g_element(pos, width, height, color);
}

void print_4(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, DIGIT_DISABLE);
	print_b_element(pos, width, height, color);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, DIGIT_DISABLE);
	print_e_element(pos, width, height, DIGIT_DISABLE);
	print_f_element(pos, width, height, color);
	print_g_element(pos, width, height, color);
}

void print_5(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, color);
	print_b_element(pos, width, height, DIGIT_DISABLE);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, color);
	print_e_element(pos, width, height, DIGIT_DISABLE);
	print_f_element(pos, width, height, color);
	print_g_element(pos, width, height, color);
}

void print_6(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, color);
	print_b_element(pos, width, height, DIGIT_DISABLE);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, color);
	print_e_element(pos, width, height, color);
	print_f_element(pos, width, height, color);
	print_g_element(pos, width, height, color);
}

void print_7(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, color);
	print_b_element(pos, width, height, color);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, DIGIT_DISABLE);
	print_e_element(pos, width, height, DIGIT_DISABLE);
	print_f_element(pos, width, height, DIGIT_DISABLE);
	print_g_element(pos, width, height, DIGIT_DISABLE);
}

void print_8(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, color);
	print_b_element(pos, width, height, color);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, color);
	print_e_element(pos, width, height, color);
	print_f_element(pos, width, height, color);
	print_g_element(pos, width, height, color);
}

void print_9(vec2 pos, float width, float height, vec3 color) {
	print_a_element(pos, width, height, color);
	print_b_element(pos, width, height, color);
	print_c_element(pos, width, height, color);
	print_d_element(pos, width, height, color);
	print_e_element(pos, width, height, DIGIT_DISABLE);
	print_f_element(pos, width, height, color);
	print_g_element(pos, width, height, color);
}

void printScore(vec4 value, vec2 pos, float width, float height, vec3 color) {
	for (int i = 0; i < 4; ++i) {
		int digit = 0;
		for (int j = 1; j < 10; ++j) {
			if (value[i] > float(j) * 0.1 - 0.05)
				digit = j;
		}

		     if (digit == 0) print_0(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 1) print_1(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 2) print_2(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 3) print_3(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 4) print_4(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 5) print_5(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 6) print_6(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 7) print_7(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 8) print_8(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
		else if (digit == 9) print_9(vec2(pos.x - width * 1.5 * float(i), pos.y), width, height, color);
	}
}

void update() {
	//  delay before start new game
	if (delay_time > E) {
		if (int(time) - (int(time) / 2) * 2 == 0)
			delay_time -= 0.05;

		return;
	}

	if (mouse.y < mouse_last_y - E || mouse.y > mouse_last_y + E) {
		bird_pos.y += BIRD_POWER;
		bird_pos.y  = min(bird_pos.y, 0.9);
	} else {
		bird_pos.y -= BIRD_GRAVITY;
		
		if (bird_pos.y < 0.01)
			start_game();
	}
	
	for (int i = 0; i < 3; ++i) {
		tower_pos[i].x -= TOWER_SPEED;
		if (tower_pos[i].x < 0.0) {
			tower_pos[i] = vec2(0.6, 0.3 + sin(time) * 0.2);
		} else if (bird_pos.x >= tower_pos[i].x * 1.65 && (last_tower_id < float(i) * 0.1 - 0.05 || last_tower_id > float(i) * 0.1 + 0.05)) {
			last_tower_id = float(i) * 0.1;
			if (score[0] > 0.85) {
				score[0] = 0.0;
				if (score[1] > 0.85) {
					score[1] = 0.0;
					if (score[2] > 0.85) {
						score[2] = 0.0;
						if (score[3] > 0.85)
							score[3] = 0.0;  //  congrats, you win!
						else
							score[3] += 0.1;
					} else
						score[2] += 0.1;
				} else
					score[1] += 0.1;
			} else
				score[0] += 0.1;
		}
	}
}

bool check_collision() {
	for (int i = 0; i < 3; ++i) {
		if (distance(bird_pos.x, tower_pos[i].x * 1.65) < BIRD_SIZE + TOWER_WIDTH) {
			if (bird_pos.y < tower_pos[i].y || distance(bird_pos.y, tower_pos[i].y) < BIRD_SIZE)
				return true;
			else if (bird_pos.y > tower_pos[i].y + TOWER_DISTANCE || distance(bird_pos.y, tower_pos[i].y + TOWER_DISTANCE) < BIRD_SIZE)
				return true;
		}
	}

	return false;
}

void main() {
	bool is_lose = false;
	coord = gl_FragCoord.xy / resolution;

	CLOUD_PART_SIZE[0] = 0.05;
	CLOUD_PART_SIZE[1] = 0.05;
	CLOUD_PART_SIZE[2] = 0.03;
	CLOUD_PART_SIZE[3] = 0.06;
	CLOUD_PART_SIZE[4] = 0.05;

	CLOUD_PART_POS[0] = vec2(-0.1,   0.0);
	CLOUD_PART_POS[1] = vec2( 0.0,   0.0);
	CLOUD_PART_POS[2] = vec2( 0.06,  0.0);
	CLOUD_PART_POS[3] = vec2(-0.04,  0.06);
	CLOUD_PART_POS[4] = vec2( 0.02,  0.05);

	read_data();

	drawBackground();
	drawCloud(vec2(0.45, 0.7));
	drawCloud(vec2(0.8, 0.8));
	is_lose = drawTowers(tower_pos[0]) || is_lose;
	is_lose = drawTowers(tower_pos[1]) || is_lose;
	is_lose = drawTowers(tower_pos[2]) || is_lose;
	drawBird();
	drawBorder();
	printScore(score, vec2(0.85, 0.77), 0.07, 0.2, vec3(0.0, 1.0, 0.0));
	printScore(last_score, vec2(0.47, 0.87), 0.035, 0.1, vec3(1.0, 0.3, 0.0));

	update();
	if (check_collision())
		start_game();

	save_data();  //  must always be the last, if something drawn to the data location save_data() redraws it
}
