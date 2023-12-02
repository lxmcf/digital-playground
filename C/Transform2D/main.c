#include <raylib.h>
#include <raymath.h>

typedef struct Transform2D {
    Vector2 position;
    float rotation;

    Vector2 world_position;
    float world_rotation;

    // Index of parent transform
    int parent;
    int calculated;
} Transform2D;

// TRANSFORM
#define MAX_TRANSFORMS 4
Transform2D transforms[MAX_TRANSFORMS];

// FUNCTIONS
void UpdateTransform (int index);
Transform2D CreateTransform (Vector2 position, float rotation, int parent);

int main (int argc, const char* argv[]) {
    InitWindow (640, 640, "Transform2D");
    // SetTargetFPS (60);

    transforms[0] = CreateTransform ((Vector2){ 320.0f, 320.0f }, 0.0f, -1);
    transforms[1] = CreateTransform ((Vector2){ 128.0f, 128.0f }, 30.0f, 0);
    transforms[2] = CreateTransform ((Vector2){ 64.0f, 64.0f }, 0.0f, 1);
    transforms[3] = CreateTransform ((Vector2){ 48.0f, 48.0f }, 0.0f, 0);

    while (!WindowShouldClose ()) {
        for (int i = 0; i < MAX_TRANSFORMS; i++) {
            UpdateTransform (i);
        }

        for (int i = 0; i < MAX_TRANSFORMS; i++) {
            transforms[i].calculated = false;
        }

        transforms[0].rotation += (GetFrameTime () / 2) * RAD2DEG;

        BeginDrawing ();
            ClearBackground (RAYWHITE);

            for (int i = 0; i < MAX_TRANSFORMS; i++) {

                DrawRectanglePro (CLITERAL(Rectangle){ transforms[i].world_position.x, transforms[i].world_position.y, 32.0f, 32.0f }, (CLITERAL(Vector2){ 16.0f, 16.0f }), transforms[i].world_rotation, SKYBLUE);
            }
        EndDrawing ();
    }

    CloseWindow ();

    return 0;
}

void UpdateTransform (int index) {
    Transform2D* transform = &transforms[index];

    Vector2 parent_position = Vector2Zero ();
    float parent_rotation = 0.0f;

    if (transform->parent != -1) {
        if (!transforms[transform->parent].calculated) {
            transforms[transform->parent].calculated = 1;
            UpdateTransform (transform->parent);
        }

        parent_position = transforms[transform->parent].world_position;
        parent_rotation = transforms[transform->parent].world_rotation;
    }

    float cos_parent = cosf (parent_rotation * DEG2RAD);
    float sin_parent = sinf (parent_rotation * DEG2RAD);

    // transform->world_position.x = parent_position.x + (transform->position.x * cos_parent - transform->position.y * sin_parent);
    // transform->world_position.y = parent_position.y + (transform->position.x * sin_parent + transform->position.y * cos_parent);

    transform->world_position = Vector2Add (parent_position, Vector2Rotate (transform->position, parent_rotation * DEG2RAD));

    transform->world_rotation = parent_rotation + transform->rotation;
}

Transform2D CreateTransform (Vector2 position, float rotation, int parent) {
    return (Transform2D){
        .position = position,
        .rotation = rotation,

        .parent = parent,

        .world_position = Vector2Zero (),
        .world_rotation = 0.0f
    };
}