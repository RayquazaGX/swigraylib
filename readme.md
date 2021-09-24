# swigraylib #

[SWIG](http://www.swig.org/) binding for [raylib](https://www.raylib.com/index.html)

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

```lua
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

- Because the SWIG module contains a large number(hundreds) of symbols binded, for some languages(Lua) a wrapper on this has been added in the binding interface file, providing only a small set of symbols when the module imported, and only automatically adding needed symbols on demand, thus saving searching time. See file `raylib.i`.
    - The original unwrapped module is still accessible in these languages. eg. `raylib.swig` in Lua.
- Interops are expensive. Here are some tips to save interop counts:
    - If a simple struct instance is to be modified many times (eg. C `Vector2` value calculated inside a loop)
        - It might not be a good idea to use the struct fields directly in complex calculations, because SWIG wraps the getter and setter functions to contain implicit C <-> script type conversions. Instead, if needed, copy the fields as local types, and after calculations copy back the results to the struct instance.
        - Note that in raylib many API functions accepting `Vector2` as parameters also have a sibling version accept simple `int x, int y`, and this means in many situations you can just avoid alloc'ing and modifying C `Vector2` instances at all.
    - You can modify the binding file to contain you own C functions to possibly prevent some interops happen, and generate bindings of them for your need.
- `examples/textures_bunnymark.lua` is ready for benchmarking performance.

## Pull Requests are welcomed ##

Would be nicer if this repo can be a collection featuring Ruby/Python/... bindings as well!

## LICENSE ##

- `raylib/*.h` are copied from [raylib](https://www.raylib.com/index.html), see the beginning of each file.
- `examples/resources/` folder has its own `LICENSE` file inside.
- Other part of the repo: MIT
