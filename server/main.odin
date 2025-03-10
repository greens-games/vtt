package main

import "../common"

import "core:net"
import rng "core:math/rand"
import "core:fmt"
import "core:strings"
import "core:thread"
import "core:sync"
import win "core:sys/windows"


game_state := common.Game_State{}
clients:[dynamic]net.TCP_Socket
clients_mutex:sync.Mutex

should_print := false

//TODO: We will start with a thread per client, look into a way to not need a thread + socket for each client (more scalable?)
main :: proc() {
	thread_per_client()
}

thread_per_client :: proc() {
	fmt.println("Starting server and opening Port 8000")
	sock1, err := net.listen_tcp(net.Endpoint{address = net.IP4_Loopback, port = 8080})	
	sock2, err2 := net.listen_tcp(net.Endpoint{address = net.IP4_Loopback, port = 8001})	

	if err != nil {
		fmt.println(err)
		panic("FAILED")
	}
	first_entity := common.Entity{
		uuid = auto_cast rng.uint32(),
		pos = {50,50}
	}
	append(&game_state.entities, first_entity)
	fmt.println("Waiting for client to connect")
	thread.run_with_data(&sock1, job)
	thread.run_with_data(&sock2, job)

	for {
		for client in clients {
			sync_game_state(client)
		}
		//Process some server wide stuff
		//This is all based on what the clients send us
	}
}

job :: proc(sock: rawptr) {
	sock := cast(^net.TCP_Socket)sock
	client, endpoint, accept_error := net.accept_tcp(sock^)
	if accept_error != nil {

		fmt.println(accept_error)
		panic("Failed to accept")
	}
	sync.lock(&clients_mutex)
	append_elem(&clients, client)
	sync.unlock(&clients_mutex)
	fmt.println("Client Connected polling for input")


	resp:[common.BUF_SIZE]byte
	common.serialize_game_state(game_state, resp[:])
	net.send_tcp(client, resp[:])

	buffer: [common.BUF_SIZE]byte
	//SEND INTIAL STATE
	for {
		read, error := net.recv_tcp(client, buffer[:])
		if buffer[0] == u8(common.Request_Type.DISCONNECT) {
			client, endpoint, accept_error = net.accept_tcp(sock^)
			if accept_error != nil {

				fmt.println(accept_error)
				panic("Failed to accept")
			}
			sync_game_state(client)
		}
		fmt.printfln("received %s", buffer)

		if error != nil {
			fmt.println("ERROR: ", error)
			panic("Failed to READ")
		}

		if read >= -1 {
			if buffer[0] == u8(common.Request_Type.INPUT) {
				input_type := buffer[1]
				switch input_type {
				case 0:	
					mouse_x := i32(buffer[4]) * 256 + i32(buffer[5])
					mouse_y := i32(buffer[6]) * 256 + i32(buffer[7])
					game_state.entities[0].pos = {mouse_x, mouse_y}
				case 1:
					fmt.println(Keys(buffer[1]))
					fmt.println(Actions(buffer[2]))
				}
			}
		}

	}
}

sync_game_state :: proc(client: net.TCP_Socket) {
	resp:[common.BUF_SIZE]byte
	common.serialize_game_state(game_state, resp[:])
	net.send_tcp(client, resp[:])
}

Mouse_Buttons :: enum {
	MOUSE_BUTTON_1 = 0, // LEFT
	MOUSE_BUTTON_2 = 1, // RIGHT
	MOUSE_BUTTON_3 = 2, // MIDDLE
	MOUSE_BUTTON_4 = 3,
	MOUSE_BUTTON_5 = 4,
	MOUSE_BUTTON_6 = 5,
	MOUSE_BUTTON_7 = 6,
	MOUSE_BUTTON_8 = 7,
}

Keys :: enum {
	KEY_A = 65,
	KEY_B = 66,
	KEY_C = 67,
	KEY_D = 68,
	KEY_E = 69,
	KEY_F = 70,
	KEY_G = 71,
	KEY_H = 72,
	KEY_I = 73,
	KEY_J = 74,
	KEY_K = 75,
	KEY_L = 76,
	KEY_M = 77,
	KEY_N = 78,
	KEY_O = 79,
	KEY_P = 80,
	KEY_Q = 81,
	KEY_R = 82,
	KEY_S = 83,
	KEY_T = 84,
	KEY_U = 85,
	KEY_V = 86,
	KEY_W = 87,
	KEY_X = 88,
	KEY_Y = 89,
	KEY_Z = 90,
}

Actions :: enum {
	RELEASE,
	PRESS,
	REPEAT
}
