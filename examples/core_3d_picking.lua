-- Original: https://github.com/raysan5/raylib/blob/master/examples/core/core_3d_picking.c, by Ramon Santamaria (@raysan5)
-- Translated to Lua, by 域外創音 <https://github.com/Rinkaa>

local raylib = require "raylib"

local screenWidth, screenHeight = 800, 450
raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking")

local camera = raylib.Camera()
camera.position = raylib.Vector3(10, 10, 10)
camera.target = raylib.Vector3(0, 0, 0)
camera.up = raylib.Vector3(0, 1, 0)
camera.fovy = 45
camera.projection = raylib.CAMERA_PERSPECTIVE

local cubePosition = raylib.Vector3(0, 1, 0)
local cubeSize = raylib.Vector3(2, 2, 2)

local ray = raylib.Ray()
local collision = false

raylib.SetCameraMode(camera, raylib.CAMERA_FREE)
raylib.SetTargetFPS(60)

while not raylib.WindowShouldClose() do

    raylib.UpdateCamera(camera)
    if raylib.IsMouseButtonPressed(raylib.MOUSE_LEFT_BUTTON) then
        if not collision then
            ray = raylib.GetMouseRay(raylib.GetMousePosition(), camera)
            collision = raylib.CheckCollisionRayBox(ray, raylib.BoundingBox(
                raylib.Vector3(cubePosition.x - cubeSize.x/2, cubePosition.y - cubeSize.y/2, cubePosition.z - cubeSize.z/2),
                raylib.Vector3(cubePosition.x + cubeSize.x/2, cubePosition.y + cubeSize.y/2, cubePosition.z + cubeSize.z/2)
            ))
        else
            collision = false
        end
    end

    raylib.BeginDrawing()
    raylib.ClearBackground(raylib.RAYWHITE)

    raylib.BeginMode3D(camera)
    if collision then
        raylib.DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, raylib.RED)
        raylib.DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, raylib.MAROON)
        raylib.DrawCubeWires(cubePosition, cubeSize.x + 0.2, cubeSize.y + 0.2, cubeSize.z + 0.2, raylib.GREEN)
    else
        raylib.DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, raylib.GRAY)
        raylib.DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, raylib.DARKGRAY)
    end
    raylib.DrawRay(ray, raylib.MAROON)
    raylib.DrawGrid(10, 1)
    raylib.EndMode3D()

    raylib.DrawText("Try selecting the box with mouse!", 240, 10, 20, raylib.DARKGRAY)
    if collision then
        raylib.DrawText("BOX SELECTED", (screenWidth - raylib.MeasureText("BOX SELECTED", 30)) / 2, math.floor(screenHeight * 0.1), 30, raylib.GREEN)
    end
    raylib.DrawFPS(10, 10)

    raylib.EndDrawing()

end

raylib.CloseWindow()
