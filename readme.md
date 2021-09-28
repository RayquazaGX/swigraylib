# swigraylib #

[SWIG](http://www.swig.org/) binding for [raylib](https://www.raylib.com/index.html)

This repo generates raylib bindings to other languages (eg. Lua), by providing a `raylib.i` SWIG interface file.

> SWIG is a software development tool that connects programs written in C and C++ with a variety of high-level programming languages (C#, Java, Lua, Python, Ruby, ...)

> raylib is a simple and easy-to-use library to enjoy videogames programming.

## Current Status ##

- SWIG 4.0.2
- raylib 3.7.0
    - `raylib.h`
    - `raymath.h`
    - `rlgl.h`
    - `physac.h`
    - `easings.h`
- Supported languages:
    - [x] Lua

## Example ##

### Lua ###

> Example build:
```sh
# This example build script requires `xmake` and `swig` installed.
# `xmake.lua` in this repo is used to build the Lua `.so` module. Should work on Windows as well to build a `.dll`.
# You can use Lua 5.1~5.4 too, but you need to make changes in the `xmake.lua` accordingly.
xrepo install "luajit 2.1.0-beta3" && xmake build "swigraylib_lua"
```

> Print raylib version in the terminal:
```sh
# Start luajit to test. You should change the path of the output library accordingly.
luajit -i -e "package.cpath=package.cpath..';./build/linux/x86_64/release/swig?_lua.so'"
> raylib = require "raylib"
> print(raylib.RAYLIB_VERSION)
3.7
```

> Basic window in Lua:
```lua
-- Original version in C: https://github.com/raysan5/raylib/blob/master/examples/core/core_basic_window.c, by Ramon Santamaria (@raysan5)
local raylib = require "raylib"
local screenWidth, screenHeight = 800, 450
raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
raylib.SetTargetFPS(60)
while not raylib.WindowShouldClose() do
    raylib.BeginDrawing()
    raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, raylib.LIGHTGRAY)
    raylib.EndDrawing()
end
raylib.CloseWindow()
```

## Performance Notes ##

- Because the module contains a large number(hundreds) of symbols binded, for some languages(Lua) a wrapper on top of the generated SWIG module has been added, providing only a small set of symbols when the module imported, and only automatically adding needed symbols on demand, thus saving searching time. See file `raylib.i`.
    - The original unwrapped module is still accessible in these languages. eg. `raylib.swig` in Lua.
- Interops are expensive. Here are some tips to save interop counts:
    - If a simple struct instance is to be modified many times (eg. C `Vector2` value calculated inside a loop):
        - It might not be a good idea to use the struct fields directly in complex calculations, because SWIG wraps the getter and setter functions to contain implicit C <-> script type conversions. Instead, if needed, copy the fields as local types, and after calculations copy back the results to the struct instance.
        - Note that in raylib many API functions accepting `Vector2` as parameters also have a sibling version which accepts simple `int x, int y`, and this means in many situations you can just avoid alloc'ing and modifying C `Vector2` instances at all.
    - You can modify the binding file to contain you own C functions to possibly prevent some interops happen, and generate bindings of them for your need.
- `examples/textures_bunnymark.lua` is ready for benchmarking performance.

## Pull Requests are welcomed ##

Would be nicer if this repo can be a collection featuring Ruby/Python/... bindings as well!

## Credits ##

- Huge thanks to [@waruqi](https://github.com/waruqi) leading the awesome [xmake](https://github.com/xmake-io/xmake) build system which keeps all the messes away from the building process, also gave many advices on the build script in this repo himself.

## LICENSE ##

- Embedded `raylib/*.h` are copied from [raylib](https://github.com/raysan5/raylib), see the beginning of each file and the original [LICENSE](https://github.com/raysan5/raylib/blob/master/LICENSE) from raylib repo.
- `examples/resources/` folder has its own `LICENSE` file inside.
- Other part of the repo: MIT
