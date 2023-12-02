#include <raylib.h>
#include <raymath.h>

typedef struct Transform2D {
    Vector2 position;
    Vector2 scale;

    float rotation;

    Vector2 world_position;
    Vector2 world_scale;

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
    transforms[3] = CreateTransform ((Vector2){ 48.0f, 48.0f }, 0.0f, 2);

    while (!WindowShouldClose ()) {
        for (int i = 0; i < MAX_TRANSFORMS; i++) {
            UpdateTransform (i);
        }

        for (int i = 0; i < MAX_TRANSFORMS; i++) {
            transforms[i].calculated = 0;

            transforms[i].rotation += (GetFrameTime () / 2) * RAD2DEG;

            float sine = sinf ((float)GetTime ());

            transforms[i].scale = CLITERAL(Vector2){ sine, sine};
        }

        BeginDrawing ();
            ClearBackground (RAYWHITE);

            for (int i = 0; i < MAX_TRANSFORMS; i++) {
                Rectangle rect = CLITERAL(Rectangle){
                    transforms[i].world_position.x,
                    transforms[i].world_position.y,
                    32.0f * transforms[i].world_scale.x,
                    32.0f * transforms[i].world_scale.y
                };

                DrawRectanglePro (rect, (CLITERAL(Vector2){ 16.0f * transforms[i].world_scale.x, 16.0f * transforms[i].world_scale.y }), transforms[i].world_rotation, SKYBLUE);
            }

            for (int i = 0; i < MAX_TRANSFORMS; i++) {
                if (transforms[i].parent != -1) {
                    DrawLineV (transforms[i].world_position, transforms[transforms[i].parent].world_position, RED);
                }
            }

            DrawFPS (8, 8);
        EndDrawing ();
    }

    CloseWindow ();

    return 0;
}

void UpdateTransform (int index) {
    Transform2D* transform = &transforms[index];

    Vector2 parent_position = Vector2Zero ();
    Vector2 parent_scale = Vector2One ();
    float parent_rotation = 0.0f;

    if (transform->parent != -1) {
        if (!transforms[transform->parent].calculated) {
            transforms[transform->parent].calculated = 1;
            UpdateTransform (transform->parent);
        }

        parent_position = transforms[transform->parent].world_position;
        parent_rotation = transforms[transform->parent].world_rotation;
        parent_scale = transforms[transform->parent].world_scale;
    }

    transform->world_position = Vector2Add (parent_position, Vector2Rotate (transform->position, parent_rotation * DEG2RAD));
    transform->world_scale = Vector2Multiply (transform->scale, parent_scale);

    transform->world_rotation = parent_rotation + transform->rotation;
}

Transform2D CreateTransform (Vector2 position, float rotation, int parent) {
    return (Transform2D){
        .position = position,
        .scale = Vector2One (),
        .rotation = rotation,

        .parent = parent,

        .world_position = Vector2Zero (),
        .world_scale = Vector2Zero (),
        .world_rotation = 0.0f
    };
}