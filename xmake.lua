includes("xmake/swig.lua")

add_rules("mode.release", "mode.debug")
set_languages(is_plat("wasm") and "gnu11" or "c11")

option("language")
    set_showmenu(true)
    set_category("target_binding_language")
    set_default("lua")
    set_values("lua")
option_end()

option("lua_flavor")
    set_showmenu(true)
    set_category("lua_options/lua_flavor")
    set_default("luajit")
    set_values("luajit", "lua5.1", "lua5.2", "lua5.3", "lua5.4")
option_end()

option("expose_raymath")
    set_showmenu(true)
    set_category("expose_raymath")
    set_default(true)
option_end()

option("expose_rlgl")
    set_showmenu(true)
    set_category("expose_rlgl")
    set_default(true)
option_end()

option("use_and_expose_physac")
    set_showmenu(true)
    set_category("use_and_expose_physac")
    set_default(false)
option_end()

local luadep
if is_config("language", "lua") then
    if is_config("lua_flavor", "luajit.*") then
        add_requires("luajit 2.1.0-beta3", {system = is_plat("wasm") or nil})
        luadep = function() add_packages("luajit") end
    elseif is_config("lua_flavor", "lua5%.1.*") then
        add_requires("lua 5.1", {system = is_plat("wasm") or nil})
        luadep = function() add_packages("lua") end
    elseif is_config("lua_flavor", "lua5%.2.*") then
        add_requires("lua 5.2", {system = is_plat("wasm") or nil})
        luadep = function() add_packages("lua") end
    elseif is_config("lua_flavor", "lua5%.3.*") then
        add_requires("lua 5.3", {system = is_plat("wasm") or nil})
        luadep = function() add_packages("lua") end
    elseif is_config("lua_flavor", "lua5%.4.*") then
        add_requires("lua 5.4", {system = is_plat("wasm") or nil})
        luadep = function() add_packages("lua") end
    end
end

local raylibdep
local raylibflags
if is_plat("windows") or is_plat("mingw") then
    raylibdep = function()
        add_syslinks("gdi32", "user32", "winmm", "shell32")
    end
    raylibflags = {"-DPLATFORM_DESKTOP"}
elseif is_plat("linux") then
    add_requires("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
    raylibdep = function()
        add_syslinks("pthread", "dl", "m")
        add_packages("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
    end
    raylibflags = {"-DPLATFORM_DESKTOP", "-D_DEFAULT_SOURCE"}
elseif is_plat("bsd") then  -- Untested
    add_requires("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
    raylibdep = function()
        add_syslinks("pthread", "dl", "m")
        add_packages("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
    end
    raylibflags = {"-DPLATFORM_DESKTOP"}
elseif is_plat("macosx") then -- Untested
    raylibdep = function()
        add_frameworks("CoreVideo", "CoreGraphics", "AppKit", "IOKit", "CoreFoundation", "Foundation")
    end
    raylibflags = {"-DPLATFORM_DESKTOP"}
elseif is_plat("android") then -- Untested
    raylibdep = nil
    raylibflags = {"-DPLATFORM_ANDROID", "-DGRAPHICS_API_OPENGL_ES2"}
elseif is_plat("iphoneos") then -- Untested
    raylibdep = nil
    raylibflags = {"-DPLATFORM_DESKTOP", "-DGRAPHICS_API_OPENGL_ES2"}
elseif is_plat("wasm") then
    raylibdep = nil
    raylibflags = {"-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2", "-D_GLFW_OSMESA"}
else
    raylibdep = nil
    raylibflags = {}
end

local swigflags = {"-Iraylib/src"}
if has_config("expose_raymath") then
    table.insert(swigflags, "-DSWIGRAYLIB_EXPOSE_RAYMATH")
end
if has_config("expose_rlgl") then
    table.insert(swigflags, "-DSWIGRAYLIB_EXPOSE_RLGL")
end
if has_config("use_and_expose_physac") then
    table.insert(raylibflags, "-DPHYSAC_IMPLEMENTATION")
end
table.join2(swigflags, raylibflags)

local function core(useExternalGlfw, swigTargetLang)

    if swigTargetLang == "lua" then
        if luadep then luadep() end
        table.insert(swigflags, "-no-old-metatable-bindings")
    end

    if raylibdep then raylibdep() end

    add_includedirs("raylib/src")
    add_files(
        "raylib/src/rcore.c",
        "raylib/src/rshapes.c",
        "raylib/src/rtextures.c",
        "raylib/src/rtext.c",
        "raylib/src/rmodels.c",
        "raylib/src/raudio.c",
        "raylib/src/utils.c"
    )

    if useExternalGlfw then
        add_ldflags("-lglfw")
    else
        add_includedirs("raylib/src/external/glfw/include")
        add_files("raylib/src/rglfw.c")
    end

    add_rules("swig")
    add_files("raylib.i", {
        targetLang = swigTargetLang,
        cppMode = false,
        outDir = "gen/raylib.i/",
        outName = "raylib.i."..tostring(swigTargetLang)..".$(plat).c",
        extra = swigflags
    })

    add_cxflags(table.unpack(raylibflags))
end

target("swigraylib")
    set_kind("shared")
    set_default(true)

    local langNameMapping =
    {
        -- [is_config("language", "lang")] = "lang",
        [is_config("language", "lua")] = "lua",
    }
    local swigTargetLang = langNameMapping[true]

    before_build(function(target)
        if not swigTargetLang then
            cprint("${yellow underline}Bindings to the target language are not implemented! Will do nothing. Please point to a implemented target with `xmake f --language=xxx`. ${clear}")
        end
    end)

    local useExternalGlfw = false
    if is_plat("mingw") then
        add_ldflags("-static-libstdc++", "-static-libgcc")
    elseif is_plat("wasm") then
        useExternalGlfw = true
        add_cxflags("-Os")
        add_ldflags("-s USE_GLFW=3")
    end
    core(useExternalGlfw, swigTargetLang)

    if swigTargetLang == "lua" then
        set_prefixname("")
        set_basename("raylib")
        set_suffixname("")
    end

target_end()
