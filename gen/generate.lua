#!/usr/bin/env lua

-- Generate SWIG binding files by calling SWIG via command line,
--   and output the files to `/gen/<corresponding folder>`.
-- You usually don't need to run this file at all, since it is mainly for CI.
--   The xmake.lua build script in the repo already takes the job generating
--   the needed files.
-- Currently: Generate all files for all available languages and all possible platforms
--   in one shot. It might be a better idea to only generate files for specified languages,
--   if we need this feature in the future...

-- Usage: lua ./generate.lua <extra-args-for-swig...>

-- - selectionArgs: [1]=lang, [2]=OS
-- - swigArgs: the arguments gathered for swig
local function getSwigGenCommand(selections, selectionArgs, swigArgs)
    return string.format(
    "swig %s %s -Iraylib/src -o gen/raylib.i/raylib.i.%s.c raylib.i",
        table.concat(selectionArgs, " "),
        table.concat(swigArgs, " "),
        table.concat(selections, ".")
    )
end

local function foreachLang(f, selections, args)
    local languages = {
        lua = "-lua -no-old-metatable-bindings",
    }
    for k, v in pairs(languages) do
        selections[#selections + 1] = k
        args[#args + 1] = v
        f(selections, args)
        selections[#selections] = nil
        args[#args] = nil
    end
end

local function foreachOS(f, selections, args)
    local OSs = {
        windows = "-D_WIN32 -DPLATFORM_DESKTOP",
        mingw = "-D_WIN32 -DPLATFORM_DESKTOP",
        linux = "-D__linux__ -DPLATFORM_DESKTOP -D_DEFAULT_SOURCE",
        wasm = "-D__EMSCRIPTEN__ -DPLATFORM_WEB -D_DEFAULT_SOURCE -D_GLFW_OSMESA",
        macosx = "-D__APPLE__ -DPLATFORM_DESKTOP", -- Untested
        freebsd = "-D__FreeBSD__ -DPLATFORM_DESKTOP -D_DEFAULT_SOURCE", -- Untested
        openbsd = "-D__OpenBSD__ -DPLATFORM_DESKTOP -D_DEFAULT_SOURCE", -- Untested
        netbsd = "-D__NetBSD__ -DPLATFORM_DESKTOP -D_DEFAULT_SOURCE", -- Untested
        dragonfly = "-D__DragonFly__ -DPLATFORM_DESKTOP -D_DEFAULT_SOURCE", -- Untested
        android = "-D__ANDROID__ -DANDROID -DPLATFORM_ANDROID -D_DEFAULT_SOURCE", -- Untested
        iphoneos = "-D__APPLE__ -DPLATFORM_DESKTOP -DTARGET_OS_IOS", -- Untested, not officially supported by raylib
    }
    for k, v in pairs(OSs) do
        selections[#selections + 1] = k
        args[#args + 1] = v
        f(selections, args)
        selections[#selections] = nil
        args[#args] = nil
    end
end

-- Gather and feed batched commands to SWIG
do
    local commands = {}

    local selectionStack = {}
    local selectionArgStack = {}
    local swigArgs = arg
    local function addCommand(_, selections, args)
        commands[#commands + 1] = getSwigGenCommand(selections, args, swigArgs)
    end

    local function pipeForeach(foreachFunc, f2, f3, f4)
        return function(...)
            if foreachFunc then
                foreachFunc(pipeForeach(f2, f3, f4), ...)
            end
        end
    end

    pipeForeach(foreachLang, foreachOS, addCommand)(selectionStack, selectionArgStack)

    print("Generated commands:")
    for i = 1, #commands do
        print(commands[i])
    end
    print("Waiting for these commands to finish...")

    os.execute(table.concat(commands, "\n"))
    print("Commands finished.")
end
