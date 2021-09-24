-- Original: https://github.com/raysan5/raylib/blob/master/examples/core/core_basic_window.c, by Ramon Santamaria (@raysan5)
-- Translated to Lua, by 域外創音 <https://github.com/Rinkaa>

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
