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

if is_config("language", "lua.*") then
    if is_config("lua_flavor", "luajit.*") then
        add_requires("luajit 2.1.0-beta3")
    elseif is_config("lua_flavor", "lua5%.1.*") then
        add_requires("lua 5.1")
    elseif is_config("lua_flavor", "lua5%.2.*") then
        add_requires("lua 5.2")
    elseif is_config("lua_flavor", "lua5%.3.*") then
        add_requires("lua 5.3")
    elseif is_config("lua_flavor", "lua5%.4.*") then
        add_requires("lua 5.4")
    end
end

local extraRaylibDep
local baseRaylibFlags = {"-DPHYSAC_IMPLEMENTATION"}
local extraRaylibFlags
local baseSwigFlags = {"-no-old-metatable-bindings"}
local extraSwigFlags
if is_plat("windows") then
    extraRaylibDep = function()
        add_syslinks("gdi32", "user32", "winmm", "shell32")
    end
    extraRaylibFlags = {"-DPLATFORM_DESKTOP"}
    extraSwigFlags = {"-D_WIN32"}
elseif is_plat("linux") then
    add_requires("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
    extraRaylibDep = function()
        add_syslinks("pthread", "dl", "m")
        add_packages("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
    end
    extraRaylibFlags = {"-DPLATFORM_DESKTOP", "-D_DEFAULT_SOURCE"}
    extraSwigFlags = {"-D__linux__"}
elseif is_plat("bsd") then  -- Untested
    add_requires("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
    extraRaylibDep = function()
        add_syslinks("pthread", "dl", "m")
        add_packages("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
    end
    extraRaylibFlags = {"-DPLATFORM_DESKTOP"}
    extraSwigFlags = {"-D__FreeBSD__"}
elseif is_plat("macosx") then -- Untested
    extraRaylibDep = function()
        add_frameworks("CoreVideo", "CoreGraphics", "AppKit", "IOKit", "CoreFoundation", "Foundation")
    end
    extraRaylibFlags = {"-DPLATFORM_DESKTOP"}
    extraSwigFlags = {"-D__APPLE__"}
elseif is_plat("android") then -- Untested
    extraRaylibDep = nil
    extraRaylibFlags = {"-DPLATFORM_ANDROID"}
    extraSwigFlags = {"-D__ANDROID__"}
elseif is_plat("iphoneos") then -- Untested
    extraRaylibDep = nil
    extraRaylibFlags = {"-DPLATFORM_DESKTOP"}
    extraSwigFlags = {"-D__APPLE__", "-DTARGET_OS_IOS"}
elseif is_plat("wasm") then -- Untested
    extraRaylibDep = nil
    extraRaylibFlags = {"-DPLATFORM_WEB"}
    extraSwigFlags = {"-D__EMSCRIPTEN__"}
else
    extraRaylibDep = nil
    extraRaylibFlags = {}
    extraSwigFlags = {}
end
if has_config("use_physac") then
    table.insert(extraSwigFlags, "-DSWIGRAYLIB_USE_PHYSAC")
end
if has_config("use_easings") then
    table.insert(extraSwigFlags, "-DSWIGRAYLIB_USE_EASINGS")
end

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

    add_rules("swig.c", {moduletype = "lua"})
    if is_config("lua_flavor", "luajit.*") then
        add_packages("luajit")
    elseif is_config("lua_flavor", "lua.*") then
        add_packages("lua")
    end

    if extraRaylibDep then extraRaylibDep() end

    local raylibDefs = {}
    table.join2(raylibDefs, baseRaylibFlags)
    table.join2(raylibDefs, extraRaylibFlags)

    local swigflags = {"-Iraylib/src"}
    table.join2(swigflags, raylibDefs)
    table.join2(swigflags, baseSwigFlags)
    table.join2(swigflags, extraSwigFlags)

    add_includedirs("raylib/src")
    add_includedirs("raylib/src/external/glfw/include")
    add_files("raylib/src/*.c")
    add_files("raylib.i", {swigflags = swigflags})

    add_cxflags(table.unpack(raylibDefs))

target_end()
