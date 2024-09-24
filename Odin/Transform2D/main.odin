package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Transform2D :: struct {
	position:       rl.Vector2,
	scale:          rl.Vector2,
	rotation:       f32,
	world_position: rl.Vector2,
	world_scale:    rl.Vector2,
	world_rotation: f32,
	parent:         int,
	calculated:     bool,
}

main :: proc() {
	rl.SetWindowState({.WINDOW_HIGHDPI})
	rl.InitWindow(640, 640, "Transform2D")
	defer rl.CloseWindow()

	transforms: [dynamic]Transform2D
	defer delete(transforms)

	append(&transforms, create_transform({320, 320}, 0, -1))
	append(&transforms, create_transform({128, 128}, 30, 0))
	append(&transforms, create_transform({64, 64}, 0, 1))
	append(&transforms, create_transform({48, 48}, 0, 2))

	for !rl.WindowShouldClose() {
		for i in 0 ..< len(transforms) {
			update_transform(transforms[:], i)
		}

		for &transform in transforms {
			transform.calculated = false
			transform.rotation += (rl.GetFrameTime() / 2) * rl.RAD2DEG

			sine := math.sin(f32(rl.GetTime()))

			transform.scale = rl.Vector2(sine)
		}

		rl.BeginDrawing()
		defer rl.DrawFPS(8, 8)
		defer rl.EndDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for transform in transforms {
			rectangle := rl.Rectangle {
				transform.world_position.x,
				transform.world_position.y,
				32 * transform.world_scale.x,
				32 * transform.world_scale.y,
			}

			rl.DrawRectanglePro(
				rectangle,
				transform.world_scale * 16,
				transform.world_rotation,
				rl.SKYBLUE,
			)

			if transform.parent != -1 {
				rl.DrawLineV(
					transform.world_position,
					transforms[transform.parent].world_position,
					rl.RED,
				)
			}
		}
	}
}

update_transform :: proc(transforms: []Transform2D, index: int) {
	parent_position := rl.Vector2(0)
	parent_scale := rl.Vector2(1)
	parent_rotation := f32(0)

	transform := &transforms[index]
	parent_index := transform.parent

	if parent_index != -1 {
		if !transforms[parent_index].calculated {
			transforms[parent_index].calculated = true
			update_transform(transforms, parent_index)
		}

		parent_position = transforms[parent_index].world_position
		parent_scale = transforms[parent_index].world_scale
		parent_rotation = transforms[parent_index].world_rotation
	}

	transform.world_position =
		parent_position + rl.Vector2Rotate(transform.position, parent_rotation * rl.DEG2RAD)
	transform.world_scale = transform.scale * parent_scale

	// Prevent massive numbers as stored in degrees
	transform.world_rotation = parent_rotation + transform.rotation
}

create_transform :: proc(position: rl.Vector2, rotation: f32, parent: int) -> Transform2D {
	transform: Transform2D

	transform.position = position
	transform.scale = rl.Vector2(1)
	transform.rotation = rotation
	transform.parent = parent

	return transform
}
