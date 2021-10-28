-- Original: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_bunnymark.c, by Ramon Santamaria (@raysan5)
-- Translated to Lua, by 域外創音 <https://github.com/Rinkaa>

local raylib = require "raylib"

local MAX_BUNNIES = 50000
local MAX_BATCH_ELEMENTS = 8192

local screenWidth, screenHeight = 800, 450
raylib.InitWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark")

local texBunny = raylib.LoadTexture("../raylib/examples/textures/resources/wabbit_alpha.png")
local bunnies = {}

raylib.SetTargetFPS(60)
while not raylib.WindowShouldClose() do
    local bunny
    if raylib.IsMouseButtonDown(raylib.MOUSE_LEFT_BUTTON) then
        local mousePos = raylib.GetMousePosition()
        local rand = raylib.GetRandomValue
        local col = raylib.Color
        for _ = 1, 100 do
            if #bunnies < MAX_BUNNIES then
                bunny = {
                    position = {x = mousePos.x, y = mousePos.y},
                    speed = {x = rand(-250, 250)/60, y = rand(-250, 250)/60},
                    color = col(rand(50, 240), rand(80, 240), rand(100, 240), 255),
                }
                bunnies[#bunnies+1] = bunny
            end
        end
    end
    do
        for i = 1, #bunnies do
            bunny = bunnies[i]
            bunny.position.x, bunny.position.y = bunny.position.x + bunny.speed.x, bunny.position.y + bunny.speed.y
            if (bunny.position.x + texBunny.width/2 > screenWidth) or (bunny.position.x + texBunny.width/2 < 0) then
                bunny.speed.x = -bunny.speed.x
            end
            if (bunny.position.y + texBunny.height/2 > screenHeight) or (bunny.position.y + texBunny.height/2 - 40 < 0) then
                bunny.speed.y = -bunny.speed.y
            end
        end
    end

    raylib.BeginDrawing()
    raylib.ClearBackground(raylib.RAYWHITE)
    local tex = raylib.DrawTexture
    for i = 1, #bunnies do
        bunny = bunnies[i]
        tex(texBunny, bunny.position.x, bunny.position.y, bunny.color)
    end
    raylib.DrawRectangle(0, 0, screenWidth, 40, raylib.BLACK)
    raylib.DrawText(string.format("bunnies: %d", #bunnies), 120, 10, 20, raylib.GREEN)
    raylib.DrawText(string.format("batched draw calls: %d", 1 + #bunnies/MAX_BATCH_ELEMENTS), 320, 10, 20, raylib.MAROON)
    raylib.DrawFPS(10, 10)

    raylib.EndDrawing()
end

bunnies = nil
collectgarbage()
raylib.UnloadTexture(texBunny)
raylib.CloseWindow()
