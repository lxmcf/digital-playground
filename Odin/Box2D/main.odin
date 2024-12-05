package main

import db "shared:debug"

import b2 "vendor:box2d"
import rl "vendor:raylib"

GROUND_COUNT :: 14
BOX_COUNT :: 10

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080

UNITS_PER_METER :: 128
GRAVITY :: 9.8

Entity :: struct {
	body_id: b2.BodyId,
	// shape_id: b2.ShapeId,
	extent:  b2.Vec2,
	texture: rl.Texture,
}

main :: proc() {
	context.allocator = db.init_allocator()
	defer db.unload_allocator()

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Hello Box2D")
	defer rl.CloseWindow()

	// rl.SetTargetFPS(60)

	b2.SetLengthUnitsPerMeter(UNITS_PER_METER)
	world_def := b2.DefaultWorldDef()

	world_def.gravity.y = GRAVITY * UNITS_PER_METER
	world_id := b2.CreateWorld(world_def)
	defer b2.DestroyWorld(world_id)

	ground_texture := rl.LoadTexture("ground.png")
	defer rl.UnloadTexture(ground_texture)

	box_texture := rl.LoadTexture("box.png")
	defer rl.UnloadTexture(box_texture)

	ground_extent: b2.Vec2 = {f32(ground_texture.width), f32(ground_texture.height)} / 2
	box_extent: b2.Vec2 = {f32(box_texture.width), f32(box_texture.height)} / 2

	ground_polygon := b2.MakeBox(ground_extent.x, ground_extent.y)
	box_polygon := b2.MakeBox(box_extent.x, box_extent.y)

	ground_entities := make([]Entity, GROUND_COUNT)
	defer delete(ground_entities)

	box_entities := make([]Entity, BOX_COUNT)
	defer delete(box_entities)

	for &entity, index in ground_entities {
		body_def := b2.DefaultBodyDef()
		body_def.position = {
			(2 * f32(index) + 2) * ground_extent.x,
			WINDOW_HEIGHT - ground_extent.y - 100,
		}

		entity.body_id = b2.CreateBody(world_id, body_def)
		entity.extent = ground_extent
		entity.texture = ground_texture

		shape_def := b2.DefaultShapeDef()
		_ = b2.CreatePolygonShape(entity.body_id, shape_def, ground_polygon)
	}

	box_index: int
	for i in 0 ..< 4 {
		y := WINDOW_HEIGHT - ground_extent.y - 100 - (2.5 * f32(i) + 2) * box_extent.y - 20

		j := i
		for j < 4 {
			x := 0.5 * WINDOW_WIDTH + (3 * f32(j) - f32(i) - 3) * box_extent.x
			assert(box_index < BOX_COUNT)

			body_def := b2.DefaultBodyDef()
			body_def.type = .dynamicBody
			body_def.position = {x, y}

			entity := &box_entities[box_index]
			entity.body_id = b2.CreateBody(world_id, body_def)
			entity.texture = box_texture
			entity.extent = box_extent

			shape_def := b2.DefaultShapeDef()
			_ = b2.CreatePolygonShape(entity.body_id, shape_def, box_polygon)

			box_index += 1
			j += 1
		}
	}

	pause: bool

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.P) {
			pause = !pause
		}

		if !pause {
			delta_time := rl.GetFrameTime()
			b2.World_Step(world_id, delta_time, 4)
		}

		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.DARKGRAY)

		for entity in box_entities {
			draw_entity(entity)
		}

		for entity in ground_entities {
			draw_entity(entity)
		}

		rl.DrawFPS(8, 8)
	}
}

draw_entity :: proc(entity: Entity) {
	position := b2.Body_GetWorldPoint(entity.body_id, -entity.extent)
	rotation := b2.Body_GetRotation(entity.body_id)
	radians := b2.Rot_GetAngle(rotation)

	rl.DrawTextureEx(entity.texture, position, radians * rl.RAD2DEG, 1, rl.WHITE)
}
