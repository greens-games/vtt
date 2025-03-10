package common

import "core:fmt"

//Utilities for a lot of client-server communication

serialize_game_state :: proc(gs: Game_State, data: []byte) {
	data[0] = u8(Request_Type.GAME_STATE)
	data[1] = u8(len(gs.entities))
	i := 2
	for entity in gs.entities {
		mouse_over_x, mouse_over_y := entity.pos.x/256, entity.pos.y/256
		mouse_offset_x, mouse_offset_y := i64(entity.pos.x)%256, i64(entity.pos.y)%256
		if i < BUF_SIZE - 2 {
			data[i]   = entity.uuid
			data[i+1] = auto_cast mouse_over_x
			data[i+2] = auto_cast mouse_offset_x
			data[i+3] = auto_cast  mouse_over_y
			data[i+4] = auto_cast mouse_offset_y
			i += 5
		}
	}
}

deserialize_game_state :: proc(game_state:^Game_State, buf: []byte, should_print := false) {
	if buf[0] == u8(Request_Type.GAME_STATE) {
		num_entities := buf[1]
		index := 2
		for i in 1..=num_entities {
			entity_index := find_entity(game_state^, buf[index])
			entity:^Entity
			if entity_index != -1 {
				entity = &game_state.entities[entity_index]
			} else {
				entity = new(Entity)
				defer free(entity)
			}
			x_pos := i32(buf[index+1]) * 256 + i32(buf[index+2])
			y_pos := i32(buf[index+3]) * 256 + i32(buf[index+4])
			entity.pos = {x_pos, y_pos}
			if entity_index == -1 {
				entity.uuid = buf[index]
				//TODO: CLEANUP
				append(&game_state.entities, entity^)
			}

			if should_print {
				fmt.println("Entity during serializing", entity)
			}
			index += 5
		}
	}
}

find_entity :: proc(game_state: Game_State, uuid: u8) -> int {
	for entity, i in game_state.entities {
		if 	entity.uuid == uuid {
			return i
		}
	}
	return -1
}
