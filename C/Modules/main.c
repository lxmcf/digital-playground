// Based off https://stackoverflow.com/questions/384121/creating-a-module-system-dynamic-loading-in-c

#include <dlfcn.h>
#include <stdio.h>

typedef void (*init_f) ();
typedef int (*int_f) ();

int main (int argc, const char* argv[]) {
    if (argc != 2) {
        printf ("ERROR: Please provide the correct amount of arguments eg. $ ./modules test.so\n");

        return 1;
    }

    void* plugin;

    plugin = dlopen (argv[1], RTLD_NOW);

    if (plugin != NULL) {
        // Test init function (Print character array??)
        init_f plugin_init = dlsym (plugin, "init");

        if (plugin_init != NULL) {
            plugin_init ();
        } else {
            printf ("ERROR:\t%s\n", dlerror ());
        }

        // Test value function (Return integer)
        int_f plugin_int = dlsym (plugin, "get_int");

        if (plugin_int != NULL) {
            printf ("INT returned: %d\n", plugin_int ());
        } else {
            printf ("ERROR:\t%s\n", dlerror ());
        }

    } else {
        printf ("ERROR:\t%s\n", dlerror ());
    }

    dlclose (plugin);

    return 0;
}