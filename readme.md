# swigraylib #

[SWIG](http://www.swig.org/) binding for [raylib](https://www.raylib.com/index.html)

This repo generates bindings for raylib to other languages (eg. Lua), by providing a `raylib.i` SWIG interface file.

> SWIG is a software development tool that connects programs written in C and C++ with a variety of high-level programming languages (C#, Java, Lua, Python, Ruby, ...)

> raylib is a simple and easy-to-use library to enjoy videogames programming.

## Why yet another binding? What's the difference? ##

- Pros:
    - In SWIG interface files we don't need to list all the functions and structures the lib provides. This is a small difference but crucial. With the SWIG typemaps, the bindings are generated more against the *style* of the API than the API itself. There is a great chance the interface file doesn't need to change at all when a new version of the lib arrives.
    - It's possible to generate bindings to multiple target languages with the same interface file. (Though there is only Lua support by now.) It's easy to add binding support for another target language, as long as that language is supported by SWIG.
    - SWIG offers neat type checks and useful error messages when type mismatch happens.
    - I want to make it more natural using a C/C++ library in a script language. Users won't need to care about C/C++ memory management and other low-level stuffs. See *Usage Notes* below.
- Cons:
    - Comparing with straight-forward FFI bindings, this binding is relatively slow. A layer provided by SWIG takes care of interops, and it does cost some performance. But overall the binding is still fast enough for common uses. For tips on saving interop counts and benchmarking, see *Performance Notes* below.

## Current Status ##

- SWIG 4.0.2
- raylib 4.0.0
    - `config.h`
    - `raylib.h`
    - `raymath.h`
    - `rlgl.h`
    - `physac.h` (optional, off by default)
- Supported languages:
    - [x] Lua (5.1 ~ 5.4, or LuaJIT)

## Build ##

You can use `make` or `xmake` to build this project.

### Using make ###
```sh
# This method requires `make` already installed,
# and uses the binding files that come along inside the folder `gen/raylib.i/`.

# Set the options first.
# You may want to read the `Makefile` for more options. (not very well documented though...)
EXPORT BUILD_MODE=[DEBUG|RELEASE]
EXPORT SWIGRAYLIB_LIBTYPE=[SHARED|STATIC]
# If the binding targets to lua, you also need to set the path of the lua library. Change the following paths accordingly.
EXPORT LUA_LIB_NAME=[luajit|lua5.1|...]
EXPORT LUA_LIB_PATH=/usr/lib/x86_64-linux-gnu
EXPORT LUA_INCLUDE_PATH=/usr/include/lua5.1
# Build.
make

## Clean the project without removing the binding files that come along.
make cleanbuild

## Clean the project with removing the binding files that come along.
# (in order to renew the binding files using [`SWIG`](http://www.swig.org/download.html)).
# If you had done this by mistake you could found the binding files back using git.
make clean
```

### Using xmake ###

```sh
# This method requires [`xmake`](https://github.com/xmake-io/xmake#installation) and [`SWIG`](http://www.swig.org/download.html) already installed.
# The binding file is generated every time a build is triggered.

# Config the project using a terminal ui, eg. Windows `cmd`.
# You choose a target language and other options in the menu `Project Configuration`.
xmake config --menu

# Build with saved configs.
xmake

# Clean the project.
xmake clean
```

## Examples ##

### Lua ###

> Print raylib version in the terminal:
```sh
# Start luajit to test. You should change the path of the output library accordingly.
luajit -i -e "package.cpath=package.cpath..';./libswigraylib.so'"
> raylib = require "raylib"
> print(raylib.RAYLIB_VERSION)
4.0
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
- In some rare cases you really need to manipulate C data, you can use the array functions provided by SWIG (see `raylib.i` in the repo for applicable `%array_functions`, [SWIG Doc `%array_functions`](www.swig.org/Doc4.0/Library.html#Library_carrays)):
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

MIT
