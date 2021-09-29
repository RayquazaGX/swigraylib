add_rules("mode.release", "mode.debug")
set_languages(is_plat("windows") and "c11" or "c99")
add_requires("raylib 3.7.0")

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

    before_build(function(target)
        if not (is_plat("windows") or is_plat("linux") or is_plat("macosx")) then
            os.raise("This xmake script doesn't support this target platform at the moment...")
        end
    end)

    add_rules("swig.c", {moduletype = "lua"})
    add_packages("raylib")
    if is_config("lua_flavor", "luajit.*") then
        add_packages("luajit")
    elseif is_config("lua_flavor", "lua.*") then
        add_packages("lua")
    end

    local raylibDefs = {"-D_DEFAULT_SOURCE", "-DPLATFORM_DESKTOP", "-DGRAPHICS_API_OPENGL_33", "-DPHYSAC_IMPLEMENTATION"}
    if is_plat("windows") then
        raylibDefs[#raylibDefs+1] = "-D_WIN32"
    elseif is_plat("linux") then
        raylibDefs[#raylibDefs+1] = "-D__linux__"
        add_cxflags("-fPIC")
    elseif is_plat("macosx") then
        raylibDefs[#raylibDefs+1] = "-D__APPLE__"
    end

    local swigParams = {"-no-old-metatable-bindings"}
    table.join2(swigParams, raylibDefs)

    add_includedirs(".")
    add_files("raylib.i", {swigflags = swigParams})
    add_cxflags(table.unpack(raylibDefs))

target_end()
