// 1:1 port from https://www.youtube.com/watch?v=4l5HdmPoynw

package main

import "base:runtime"

import "core:fmt"
import "core:os"
import lua "vendor:lua/5.4"

TEST_STRING :: "Hello World"

Player :: struct {
    title:  string,
    name:   string,
    family: string,
    level:  int,
}

main :: proc() {
    L := lua.L_newstate()
    defer lua.close(L)

    lua.L_openlibs(L)
    lua.register(L, "HostFunction", public_HostFunction)

    if run_lua(L, lua.L_dofile(L, "test.lua")) {
        lua.getglobal(L, "DoAThing")
        if lua.isfunction(L, -1) {
            lua.pushnumber(L, 5)
            lua.pushnumber(L, 6)

            if run_lua(L, lua.pcall(L, 2, 1, 0)) {
                fmt.println("[ODN]: Called DoAThing(5, 6), got", lua.tonumber(L, -1))
            }
        }
    }
}

public_HostFunction :: proc "c" (L: ^lua.State) -> i32 {
    a := lua.tonumber(L, 1)
    b := lua.tonumber(L, 2)
    c := a * b

    lua.pushnumber(L, c)

    return 1
}

run_lua :: proc(L: ^lua.State, res: i32) -> bool {
    if res != 0 {
        message := lua.tostring(L, -1)
        fmt.eprintln("[ERR]:", message)
        return false
    }

    return true
}
