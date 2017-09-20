//  http://glslsandbox.com/e#40586.1
//
//  Made by FiTH
//
//  fithisback@gmail.com
//  https://github.com/mtiapko/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                             *
 *                        T H E   P O N G                      *
 *                                                             *
 *                                                             *
 *                  Parameters for game control                *
 *                                                             *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

//#define USE_DELAY           //  comment this line for faster game
#define START_GAME_DELAY 6  //  delay before start new game
#define BOT_SPEED 0.02      //  bot move speed

uniform float     time;
uniform vec2      mouse;
uniform vec2      resolution;
uniform sampler2D backbuffer;  //  need for data storage

//  game data
vec2  ball_pos;
vec2  ball_dir;
float bot_pos;
float player_score;
float bot_score;
float start_game;
bool  is_tick;

//  game data save direction
//  all data is stored in the bottom left corner
const vec2  init_data_pos         = vec2(0.0, 0.0);  //  is data init ?
const vec2  time_data_pos         = vec2(0.0, 1.0);
const vec2  ball_pos_data_pos     = vec2(1.0, 0.0);
const vec2  ball_dir_data_pos     = vec2(2.0, 0.0);
const vec2  bot_pos_data_pos      = vec2(1.0, 1.0);
const vec2  player_score_data_pos = vec2(0.0, 2.0);
const vec2  bot_score_data_pos    = vec2(1.0, 2.0);
const vec2  start_game_data_pos   = vec2(2.0, 1.0);

//  game param
const float data_size = 0.01;  //  float is not very accurate, so we write down information in a lot of pixels, and read from the center of this area
const float bot_speed = BOT_SPEED;
const float ball_size = 0.02;

bool is_data_pos(vec2 pos) {
	if (gl_FragCoord.x > resolution.x * data_size * pos.x && gl_FragCoord.x < resolution.x * data_size * (pos.x + 1.0)
	    && gl_FragCoord.y > resolution.y * data_size * pos.y && gl_FragCoord.y < resolution.y * data_size * (pos.y + 1.0))
		return true;

	return false;
}

void count_down_for_start() {
	bool temp = int(time * 1000.0) - (int(time * 1000.0) / START_GAME_DELAY) * START_GAME_DELAY == 0;  //  remove for faster game

	for (float i = 0.0; i < 3.0; ++i) {
		if (i * 0.3 <= start_game) {
			if (gl_FragCoord.y > resolution.y * 0.4 && gl_FragCoord.y < 0.6 * resolution.y
			    && gl_FragCoord.x > resolution.x * (0.45 + i * 0.04) && gl_FragCoord.x < resolution.x * (0.47 + i * 0.04)) {
				gl_FragColor = vec4(0.3, 0.7, 0.5, 1.0);
			}
		}
	}
	
	if (temp && is_tick) {
		is_tick = false;
	} else if (!temp) {
		is_tick = true;
		return;
	}
	
	ball_pos      = vec2(0.5);
	ball_dir      = vec2(cos(time * 4.0) > -0.2 ? 0.515 : 0.485, sin(time / 2.0) < 0.3 ? 0.515 : 0.485);
	bot_pos       = 0.5;
	start_game   -= 0.1;
}

void update() {
	//  move ball
	ball_pos.x += ball_dir.x - 0.5;
	ball_pos.y += ball_dir.y - 0.5;

	if (ball_pos.x + ball_size > 0.925
	    && ball_pos.y > bot_pos - 0.1
	    && ball_pos.y < bot_pos + 0.1 && ball_dir.x > 0.5) {  //  bot hit
		ball_dir.x = 1.0 - ball_dir.x;
	} else if (ball_pos.x + ball_size >= 0.95 && ball_dir.x > 0.5) {  //  bot lose
		start_game    = 1.0;
		player_score += 0.1;
		if (player_score > 0.4) {
			bot_score    = 0.0;
			player_score = 0.0;
		}
	} else if (ball_pos.x - ball_size < 0.075
		   && ball_pos.y > max(min(mouse.y, 0.8), 0.2) - 0.1
		   && ball_pos.y < max(min(mouse.y, 0.8), 0.2) + 0.1 && ball_dir.x < 0.5) {  //  player hit
		ball_dir.x = 1.0 - ball_dir.x;
	} else if (ball_pos.x  - ball_size <= 0.05 && ball_dir.x < 0.5) {  //  player lose
		start_game  = 1.0;
		bot_score  += 0.1;
		if (bot_score > 0.4) {
			bot_score    = 0.0;
			player_score = 0.0;
		}
	}

	//  ball hit top or bottom
	if (ball_pos.y + ball_size >= 0.9 && ball_dir.y > 0.5) {
		ball_dir.y = 1.0 - ball_dir.y;
	} else if (ball_pos.y - ball_size <= 0.1 && ball_dir.y < 0.5) {
		ball_dir.y = 1.0 - ball_dir.y;
	}
	
	//  control bot
	if (bot_pos + 0.05 < ball_pos.y) {
		bot_pos += bot_speed;
		bot_pos  = min(bot_pos, 0.8);
	} else if (bot_pos - 0.05 > ball_pos.y) {
		bot_pos -= bot_speed;
		bot_pos  = max(bot_pos, 0.2);
	}
}

void init_or_read() {
	if (texture2D(backbuffer, data_size * (init_data_pos + 0.5))[0] < 0.9) {
		ball_pos     = vec2(0.5);
		bot_pos      = 0.5;
		bot_score    = 0.0;
		player_score = 0.0;
		start_game   = 1.0;
	} else {
		ball_pos     = texture2D(backbuffer, data_size * (ball_pos_data_pos + vec2(0.5))).rg;
		ball_dir     = texture2D(backbuffer, data_size * (ball_dir_data_pos + vec2(0.5))).rg;
		bot_pos      = texture2D(backbuffer, data_size * (bot_pos_data_pos + vec2(0.5))).r;
		player_score = texture2D(backbuffer, data_size * (player_score_data_pos + vec2(0.5))).r;
		bot_score    = texture2D(backbuffer, data_size * (bot_score_data_pos + vec2(0.5))).r;
		is_tick      = texture2D(backbuffer, data_size * (time_data_pos + vec2(0.5))).r > 0.5;
		start_game   = texture2D(backbuffer, data_size * (start_game_data_pos + vec2(0.5))).r;
	}

	if (is_data_pos(init_data_pos))
		gl_FragColor = vec4(1.0);
}

void tick() {
	if (start_game > 0.0) {
		count_down_for_start();
	} else {
	
#ifdef USE_DELAY
		bool temp = int(time * 1000.0) - (int(time * 1000.0) / 2) * 2 == 0;  //  remove for faster game

		if (temp && is_tick) {
			update();
			is_tick = false;
		} else if (!temp) {
			is_tick = true;
		}
#else
		update();
#endif
	}
}

void saveData() {
	if (is_data_pos(ball_pos_data_pos)) {
		gl_FragColor = vec4(ball_pos, vec2(0.0));
	}

	if (is_data_pos(ball_dir_data_pos)) {
		gl_FragColor = vec4(ball_dir, vec2(0.0));
	}

	if (is_data_pos(bot_pos_data_pos)) {
		gl_FragColor = vec4(bot_pos, vec3(0.0));
	}
	
	if (is_data_pos(player_score_data_pos)) {
		gl_FragColor = vec4(player_score, vec3(0.0));
	}
	
	if (is_data_pos(bot_score_data_pos)) {
		gl_FragColor = vec4(bot_score, vec3(0.0));
	}

	if (is_data_pos(time_data_pos)) {
		gl_FragColor = vec4(is_tick ? 1.0 : 0.0, vec3(0.0));
	}
	
	if (is_data_pos(start_game_data_pos)) {
		gl_FragColor = vec4(start_game, vec3(0.0));
	}
}

void drawPlaygound() {
	if (gl_FragCoord.x > 0.05 * resolution.x && gl_FragCoord.x < 0.95 * resolution.x
	   && gl_FragCoord.y > 0.1 * resolution.y && gl_FragCoord.y < 0.9 * resolution.y) {
		if (gl_FragCoord.x > resolution.x * 0.495 && gl_FragCoord.x < resolution.x * 0.505)
			gl_FragColor = vec4(vec3(0.3, 0.3, 0.4), 1.0);
		else
			gl_FragColor = vec4(vec3(0.4, 0.2, 0.2), 1.0);
	}
}

void drawScore() {
	for (float i = 0.0; i < 0.4; i += 0.1) {
		if (i < player_score) {
			if (distance(gl_FragCoord.xy, vec2((i * 0.5 + 0.05) * resolution.x, 0.95 * resolution.y)) < 0.011 * resolution.x)
				gl_FragColor = vec4(smoothstep(0.011 * resolution.x, 0.01 * resolution.x,
					distance(gl_FragCoord.xy, vec2((i * 0.5 + 0.05) * resolution.x, 0.95 * resolution.y))), 0.0, 0.0, 1.0);
		}
		
		if (i < bot_score) {
			if (distance(gl_FragCoord.xy, vec2((0.95 - i * 0.5) * resolution.x, 0.95 * resolution.y)) < 0.011 * resolution.x)
				gl_FragColor = vec4(0.0, 0.0, smoothstep(0.011 * resolution.x, 0.01 * resolution.x,
					distance(gl_FragCoord.xy, vec2((0.95 - i * 0.5) * resolution.x, 0.95 * resolution.y))), 1.0);
		}
	}
}

void drawPlayer() {
	if (gl_FragCoord.x > 0.05 * resolution.x && gl_FragCoord.x < 0.075 * resolution.x
	    && gl_FragCoord.y > max(min(mouse.y, 0.8), 0.2) * resolution.y - resolution.y * 0.1
	    && gl_FragCoord.y < max(min(mouse.y, 0.8), 0.2) * resolution.y + resolution.y * 0.1) {
		gl_FragColor = vec4(vec3(0.6), 1.0);
	}
}

void drawBot() {
	if (gl_FragCoord.x > 0.925 * resolution.x && gl_FragCoord.x < 0.95 * resolution.x
	    && gl_FragCoord.y > bot_pos * resolution.y - resolution.y * 0.1 && gl_FragCoord.y < bot_pos * resolution.y + resolution.y * 0.1) {
		gl_FragColor = vec4(vec3(0.6), 1.0);
	}
}

void drawBall() {
	if (distance(gl_FragCoord.xy / resolution, ball_pos) < ball_size) {
		gl_FragColor = vec4(vec3(1.0), 1.0);
	}
}

void main() {
	if (true) {
		//  read or init data
		init_or_read();

		//  draw
		drawPlaygound();
		drawScore();
		drawPlayer();
		drawBot();
		drawBall();
		
		//  update all and save
		tick();
		saveData();
	} else {
		gl_FragColor = vec4(0.0);
	}
}
