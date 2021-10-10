add_rules("mode.release", "mode.debug")
set_languages(is_plat("windows") and "c11" or "c99")
add_requires("raylib 3.7.0")

option("language")
    set_showmenu(true)
    set_category("swig_options/target_binding_language")
    set_default("lua")
    set_values("lua")
option_end()

option("lua_flavor")
    set_showmenu(true)
    set_category("lua_options/lua_flavor")
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

local function getPlatformSymbols()
    if is_plat("windows") then
        return {raylib={"-DPLATFORM=PLATFORM_DESKTOP"}, swig={"-D_WIN32"}}
    elseif is_plat("linux") then
        return {raylib={"-DPLATFORM=PLATFORM_DESKTOP", "-D_DEFAULT_SOURCE"}, swig={"-D__linux__"}}
    elseif is_plat("bsd") then  -- Untested
        return {raylib={"-DPLATFORM=PLATFORM_DESKTOP"}, swig={"-D__FreeBSD__"}}
    elseif is_plat("macosx") then -- Untested
        return {raylib={"-DPLATFORM=PLATFORM_DESKTOP"}, swig={"-D__APPLE__"}}
    elseif is_plat("android") then -- Untested
        return {raylib={"-DPLATFORM=PLATFORM_ANDROID"}, swig={"-D__ANDROID__"}}
    elseif is_plat("iphoneos") then -- Untested
        return {raylib={"-DPLATFORM=PLATFORM_DESKTOP"}, swig={"-D__APPLE__", "-DTARGET_OS_IOS"}}
    elseif is_plat("wasm") then -- Untested
        return {raylib={"-DPLATFORM=PLATFORM_WEB"}, swig={"-D__EMSCRIPTEN__"}}
    else
        return {raylib={}, swig={}}
    end
end

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
    add_packages("raylib")
    if is_config("lua_flavor", "luajit.*") then
        add_packages("luajit")
    elseif is_config("lua_flavor", "lua.*") then
        add_packages("lua")
    end

    local platformSymbols = getPlatformSymbols()
    local raylibDefs = {"-DPHYSAC_IMPLEMENTATION"}
    table.join2(raylibDefs, platformSymbols.raylib)
    local swigflags = {"-no-old-metatable-bindings", "-Iraylib/src"}
    table.join2(swigflags, raylibDefs)
    table.join2(swigflags, platformSymbols.swig)
    if has_config("use_physac") then
        table.join2(swigflags, {"-DSWIGRAYLIB_USE_PHYSAC"})
    end
    if has_config("use_easings") then
        table.join2(swigflags, {"-DSWIGRAYLIB_USE_EASINGS"})
    end

    add_includedirs("raylib/src")
    add_files("raylib.i", {swigflags = swigflags})

    add_cxflags(table.unpack(raylibDefs))

target_end()
