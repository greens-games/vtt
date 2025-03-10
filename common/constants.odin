package common

BUF_SIZE :: 1024
WINDOW_WIDTH :: 960.0
WINDOW_HEIGHT :: 720.0

Entity :: struct {
	uuid: u8,
	pos: [2]i32,
	is_held: bool,
}

Game_State :: struct {
	entities: [dynamic]Entity,
}

Game_State_Protocol :: struct {
	
}

Request_Type :: enum u8 {
	NONE,
	GAME_STATE,
	INPUT,
	HOLD,
	DISCONNECT = 254,
}
