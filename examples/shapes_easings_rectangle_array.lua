-- Original: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_easings_rectangle_array.c, by Ramon Santamaria (@raysan5)
-- Translated to Lua, by 域外創音 <https://github.com/Rinkaa>
-- This example uses `extra/easings.h`, make sure the header is including when compiling the bindings.

local raylib = require "raylib"

local RECS_WIDTH, RECS_HEIGHT = 50, 50
local MAX_RECS_X, MAX_RECS_Y = 800/RECS_WIDTH, 450/RECS_HEIGHT
local PLAY_TIME_IN_FRAMES = 240

local screenWidth, screenHeight = 800, 450
raylib.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings rectangle array")

local recs = {}
for y = 0, MAX_RECS_Y-1 do
    for x = 0, MAX_RECS_X-1 do
        local rec = raylib.Rectangle()
        rec.x = RECS_WIDTH/2 + RECS_WIDTH*x
        rec.y = RECS_HEIGHT/2 + RECS_HEIGHT*y
        rec.width = RECS_WIDTH
        rec.height = RECS_HEIGHT
        recs[#recs+1] = rec
    end
end

local rotation = 0
local framesCounter = 0
local state = "Playing" -- "Playing"/"Finished"

raylib.SetTargetFPS(60)
while not raylib.WindowShouldClose() do
    if state == "Playing" then
        framesCounter = framesCounter + 1
        local rec
        for i = 1, MAX_RECS_X*MAX_RECS_Y do
            rec = recs[i]
            rec.height = raylib.EaseCircOut(framesCounter, RECS_HEIGHT, -RECS_HEIGHT, PLAY_TIME_IN_FRAMES)
            rec.width = raylib.EaseCircOut(framesCounter, RECS_WIDTH, -RECS_WIDTH, PLAY_TIME_IN_FRAMES)
            if rec.height < 0 then rec.height = 0 end
            if rec.width < 0 then rec.width = 0 end
            if rec.height == 0 and rec.width == 0 then state = "Finished" end
            rotation = raylib.EaseLinearIn(framesCounter, 0, 360, PLAY_TIME_IN_FRAMES)
        end
    elseif state == "Finished" and raylib.IsKeyPressed(raylib.KEY_SPACE) then
        framesCounter = 0
        local rec
        for i = 1, MAX_RECS_X*MAX_RECS_Y do
            rec = recs[i]
            rec.height = RECS_HEIGHT
            rec.width = RECS_WIDTH
        end
        state = "Playing"
    end

    raylib.BeginDrawing()
    raylib.ClearBackground(raylib.RAYWHITE)

    if state == "Playing" then
        local rec
        for i = 1, MAX_RECS_X*MAX_RECS_Y do
            rec = recs[i]
            raylib.DrawRectanglePro(rec, raylib.Vector2(rec.width/2, rec.height/2), rotation, raylib.RED)
        end
    elseif state == "Finished" then
        raylib.DrawText("PRESS [SPACE] TO PLAY AGAIN!", 240, 200, 20, raylib.GRAY)
    end

    raylib.EndDrawing()
end

raylib.CloseWindow()
