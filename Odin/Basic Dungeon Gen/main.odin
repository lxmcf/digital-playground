package main

import "core:fmt"
import r "core:math/rand"
import rl "vendor:raylib"

DUNGEON_SIZE :: 11
CELL_SIZE :: 48
ROOM_COUNT :: 10

dungeon: [DUNGEON_SIZE][DUNGEON_SIZE]bool

main :: proc() {
	rl.InitWindow(1280, 720, "Dungeon Generator")
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		if rl.IsMouseButtonReleased(.LEFT) {
			generate_dungeon()
		}

		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.BLACK)

		for x in 0 ..< DUNGEON_SIZE {
			new_x: i32 = i32(x) * CELL_SIZE

			for y in 0 ..< DUNGEON_SIZE {
				new_y := i32(y) * CELL_SIZE

				if dungeon[x][y] {
					rl.DrawRectangle(new_x, new_y, CELL_SIZE, CELL_SIZE, rl.WHITE)
					rl.DrawRectangleLines(new_x, new_y, CELL_SIZE, CELL_SIZE, rl.LIGHTGRAY)
				} else {
					rl.DrawRectangle(new_x, new_y, CELL_SIZE, CELL_SIZE, rl.DARKGRAY)
				}
			}
		}
	}
}


generate_dungeon :: proc() {
	for x in 0 ..< DUNGEON_SIZE {
		for y in 0 ..< DUNGEON_SIZE {
			dungeon[x][y] = false
		}
	}

	pos_x, pos_y := 5, 5
	placed_rooms: int

	dungeon[pos_x][pos_y] = true

	Direction :: enum {
		North,
		East,
		South,
		West,
	}

	for {
		if placed_rooms == ROOM_COUNT {
			break
		}

		dir := r.choice_enum(Direction)

		switch (dir) {
		case .North:
			pos_y -= 1

		case .East:
			pos_x += 1

		case .South:
			pos_y += 1

		case .West:
			pos_x -= 1
		}

		pos_y = clamp(pos_y, 0, DUNGEON_SIZE - 1)
		pos_x = clamp(pos_x, 0, DUNGEON_SIZE - 1)

		if !dungeon[pos_x][pos_y] {
			dungeon[pos_x][pos_y] = true
			placed_rooms += 1
			continue
		}
	}
}
