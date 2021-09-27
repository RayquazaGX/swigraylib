add_rules("mode.release", "mode.debug")
set_languages("c99")
add_requires("raylib 3.7.0")

-- Choose one of the Lua versions:
-- add_requires("lua 5.3", {optional=true})
-- add_requires("lua 5.4, {optional=true}")
add_requires("luajit 2.1.0-beta3", {optional=true})

target("swigraylib_lua")

    before_build(function(target)
        if not (is_plat("windows") or is_plat("linux") or is_plat("macosx")) then
            os.raise("This xmake script doesn't support this target platform at the moment...")
        end
    end)

    set_kind("shared")
    add_rules("swig.c", {moduletype = "lua"})
    add_packages("raylib")

    -- Choose one of the Lua package:
    -- add_packages("lua")
    add_packages("luajit")

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
