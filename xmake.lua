add_rules("mode.release", "mode.debug")
set_languages("c99")
add_requires("raylib 3.7.0")

-- Choose one of the Lua versions:
-- add_requires("lua 5.3", {optional=true})
-- add_requires("lua 5.4, {optional=true}")
add_requires("luajit 2.1.0-beta3", {optional=true})

target("swigraylib_lua")
    set_kind("shared")
    before_build(function(target)
        local raylibDefs = {"-D_DEFAULT_SOURCE -DPLATFORM_DESKTOP -DGRAPHICS_API_OPENGL_33 -DPHYSAC_IMPLEMENTATION"}
        if is_plat("windows") then
            raylibDefs[#raylibDefs+1] = "-D_WIN32"
        elseif is_plat("linux") then
            raylibDefs[#raylibDefs+1] = "-D__linux__"
        elseif is_plat("macosx") then
            raylibDefs[#raylibDefs+1] = "-D__APPLE__"
        else
            os.raise("This xmake script doesn't support this target platform at the moment...")
        end
        local swigParams = {"-lua", "-no-old-metatable-bindings"}
        for i = 1, #raylibDefs do swigParams[#swigParams+1] = raylibDefs[i] end
        swigParams[#swigParams+1] = "raylib.i"
        os.runv("swig", swigParams)
        cprint("${yellow underline}SwigCmd: swig "..table.concat(swigParams, ' ').." ${clear}")
        target:add("cxflags", raylibDefs)
    end)
    if is_plat("linux") then
        add_cxflags("-fPIC")
    end
    add_packages("raylib")
    add_files("raylib_wrap.c")

    -- Choose one of the Lua package:
    -- add_packages("lua")
    add_packages("luajit")