includes("xmake/swig.lua")

add_rules("mode.release", "mode.debug")
set_languages("c11")

option("language")
    set_showmenu(true)
    set_category("swig_options/target_binding_language")
    set_default("lua")
    set_values("lua")
option_end()

option("lua_flavor")
    set_showmenu(true)
    set_category("swig_options/lua_options/lua_flavor")
    set_default("luajit")
    set_values("luajit", "lua5.1", "lua5.2", "lua5.3", "lua5.4")
option_end()

option("use_physac")
    set_showmenu(true)
    set_category("raylib_options/use_physac")
    set_default(false)
option_end()

option("use_easings")
    set_showmenu(true)
    set_category("raylib_options/use_easings")
    set_default(false)
option_end()

local luadep
if is_config("language", "lua.*") then
    if is_config("lua_flavor", "luajit.*") then
        add_requires("luajit 2.1.0-beta3")
        luadep = function() add_packages("luajit") end
    elseif is_config("lua_flavor", "lua5%.1.*") then
        add_requires("lua 5.1")
        luadep = function() add_packages("lua") end
    elseif is_config("lua_flavor", "lua5%.2.*") then
        add_requires("lua 5.2")
        luadep = function() add_packages("lua") end
    elseif is_config("lua_flavor", "lua5%.3.*") then
        add_requires("lua 5.3")
        luadep = function() add_packages("lua") end
    elseif is_config("lua_flavor", "lua5%.4.*") then
        add_requires("lua 5.4")
        luadep = function() add_packages("lua") end
    end
end

local raylibdep
local raylibflags
if is_plat("windows") then
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
    raylibflags = {"-DPLATFORM_ANDROID"}
elseif is_plat("iphoneos") then -- Untested
    raylibdep = nil
    raylibflags = {"-DPLATFORM_DESKTOP"}
elseif is_plat("wasm") then -- Untested
    raylibdep = nil
    raylibflags = {"-DPLATFORM_WEB"}
else
    raylibdep = nil
    raylibflags = {}
end

local swigflags = {"-Iraylib/src"}
if has_config("use_physac") then
    table.insert(raylibflags, "-DPHYSAC_IMPLEMENTATION")
    table.insert(swigflags, "-DSWIGRAYLIB_USE_PHYSAC")
end
if has_config("use_easings") then
    table.insert(swigflags, "-DSWIGRAYLIB_USE_EASINGS")
end
table.join2(swigflags, raylibflags)

target("swigraylib")
    set_kind("phony")
    set_default(true)

    before_build(function(target)
        if not is_config("language", "lua.*") then
            cprint("${yellow underline}Bindings to the target language are not implemented! Doing nothing. Please point to a implemented target with `xmake f --language=xxx`. ${clear}")
        end
    end)

    if is_config("language", "lua.*") then
        add_deps("swigraylib_lua")
    end

target_end()

target("swigraylib_lua")
    set_kind("shared")
    set_default(false)

    if luadep then luadep() end
    if raylibdep then raylibdep() end

    add_includedirs("raylib/src")
    add_includedirs("raylib/src/external/glfw/include")
    add_files("raylib/src/*.c")

    add_rules("swig")
    table.insert(swigflags, "-no-old-metatable-bindings")
    add_files("raylib.i", {
        targetLang = "lua",
        cppMode = false,
        outDir = "gen/raylib.i/",
        outName = "raylib.i.lua.$(os).c",
        extra = swigflags
    })

    add_cxflags(table.unpack(raylibflags))

target_end()
