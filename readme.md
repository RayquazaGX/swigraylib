# swigraylib #

[SWIG](http://www.swig.org/) binding for [raylib](https://www.raylib.com/index.html)

This repo generates raylib bindings to other languages (eg. Lua), by providing a `raylib.i` SWIG interface file.

> SWIG is a software development tool that connects programs written in C and C++ with a variety of high-level programming languages (C#, Java, Lua, Python, Ruby, ...)

> raylib is a simple and easy-to-use library to enjoy videogames programming.

## Current Status ##

- SWIG 4.0.2
- raylib 3.7.0
    - `config.h`
    - `raylib.h`
    - `raymath.h`
    - `rlgl.h`
    - `physac.h` (optional, off by default)
    - `easings.h` (optional, off by default)
- Supported languages:
    - [x] Lua

## Build ##

This provided build method requires [`xmake`](https://github.com/xmake-io/xmake#installation) and [`SWIG`](http://www.swig.org/download.html) installed.

```sh
# Config the project using a terminal ui, eg. Windows `cmd`.
# You choose a target language and other options in the menu `Project Configuration`.
xmake config --menu
# Build with saved configs.
xmake
```

## Examples ##

### Lua ###

> Print raylib version in the terminal:
```sh
# Start luajit to test. You should change the path of the output library accordingly.
luajit -i -e "package.cpath=package.cpath..';./build/linux/x86_64/release/swigraylib_lua.so'"
> raylib = require "raylib"
> print(raylib.RAYLIB_VERSION)
3.7
```

> Basic window in Lua:
```lua
-- Original version in C by Ramon Santamaria (@raysan5): https://github.com/raysan5/raylib/blob/master/examples/core/core_basic_window.c
local raylib = require "raylib"
local screenWidth, screenHeight = 800, 450
raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
raylib.SetTargetFPS(60)
while not raylib.WindowShouldClose() do
    raylib.BeginDrawing()
    raylib.ClearBackground(raylib.RAYWHITE);
    raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, raylib.LIGHTGRAY)
    raylib.EndDrawing()
end
raylib.CloseWindow()
```

## Usage Notes ##

- Bindings fit in the common code style of the target language! No need to ever care about C pointers most of the time.
    - Lua:
        ```lua
        -- Out arguments are after the return value
        local compressed, compressedLen = raylib.CompressData(data, dataLen)

        -- Functions returning an array in C now return a Lua table
        local files = raylib.GetDirectoryFiles(".")
        for i = 1, #files do print(files[i]) end
        ```
- In case you really need to manipulate C data, you can use array functions provided by SWIG (see `raylib.i` in the repo for appliable `%array_functions`, [SWIG Doc `%array_functions`](www.swig.org/Doc4.0/Library.html#Library_carrays)):
    - Lua:
        ```lua
        -- Alloc an array `unsigned char [5]`
        local data = raylib.new_UcharArray(5)
        -- Set values, note that index starts from 0
        for i = 0, 4 do raylib.UcharArray_setitem(data, i, 255) end
        -- Get values, note that index starts from 0
        for i = 0, 4 do print(raylib.UcharArray_getitem(data, i) end
        -- Free an array
        raylib.delete_UcharArray(data)
        ```
- A few functions are unsupported for the simplicity of the binding process. See `raylib.i`.

## Performance Notes ##

- Interops are expensive. Here are some tips to save interop counts:
    - If a simple struct instance is to be modified many times (eg. C `Vector2` value calculated inside a loop in a script language):
        - It might not be a good idea to use the struct fields directly in complex calculations, because SWIG wraps the getter and setter functions to contain implicit C <-> script type conversions. Instead, if needed, copy the fields as local types, and after calculations copy back the results to the struct instance.
        - Note that in raylib many API functions accepting `Vector2` as parameters also have sibling versions which accept simple `int x, int y`, and this means in many situations you can just avoid alloc'ing and modifying C `Vector2` instances at all.
    - You can modify the binding file to contain you own C functions to possibly prevent some interops happen, and generate bindings of them for your need.
- `examples/textures_bunnymark.lua` is ready for benchmarking performance.

## Pull Requests are welcomed ##

Would be nicer if this repo can be a collection featuring Ruby/Python/... bindings as well!

## Credits ##

- Huge thanks to [@waruqi](https://github.com/waruqi) for presenting the awesome [xmake](https://github.com/xmake-io/xmake) build system which keeps all the messes away from the building process, also for giving many advices on the build script in this repo.

## LICENSE ##

- `examples/resources/` folder has its own `LICENSE` file inside.
- Other part of the repo: MIT
