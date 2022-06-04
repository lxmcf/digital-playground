#include "stdio.h"
#include "stdlib.h"

typedef struct custom_struct custom_struct;

typedef void (*custom_callback)(custom_struct* cs, char* title);

typedef struct _custom_struct {
    char* testing_string;

    custom_callback cc;
} _custom_struct;

custom_struct* create_struct ();
void call_struct (custom_struct* structure);

void test_callback (custom_struct* cs, char* title);

int main (int argc, char** argv) {
    custom_struct* cs = create_struct ();

    call_struct(cs);

    free (cs);

    return 0;
}

custom_struct* create_struct () {
    _custom_struct* structure = malloc (sizeof (_custom_struct));

    structure->testing_string = "Point 1";
    structure->cc = test_callback;

    return (custom_struct*)structure;
}

void call_struct (custom_struct* structure) {
    _custom_struct* handle = (_custom_struct*)structure;

    printf ("Pre call: %s\n", handle->testing_string);

    handle->cc (structure, "Point 2");

    printf ("Post call: %s\n", handle->testing_string);
}

void test_callback (custom_struct* cs, char* title) {
    _custom_struct* handle = (_custom_struct*)cs;

    handle->testing_string = title;
}