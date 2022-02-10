rule("swig")
    set_extensions(".i")
    on_buildcmd_file(function (target, batchcmds, src, opt)

        import("lib.detect.find_tool")
        local swig = assert(find_tool("swig"), "SWIG is not found!")

        -- Configs
        local conf = target:fileconfig(src) or {}
        conf.targetLang = conf.targetLang or "lua"
        conf.cppMode    = conf.cppMode or false
        conf.outDir     = conf.outDir or (path.join(target:autogendir(), "rules", "swig"))
        conf.outName    = conf.outName or (path.basename(src) .. (conf.cppMode and ".cpp" or ".c"))
        conf.extra      = conf.extra or {}

        local gen = path.join(conf.outDir, conf.outName)
        local obj = target:objectfile(gen)
        table.insert(target:objectfiles(), obj)

        local swigArgs = {"-"..conf.targetLang, "-o", gen}
        if conf.cppMode then
            table.insert(swigArgs, "-c++")
        end
        table.join2(swigArgs, (
            is_plat("windows") and {"-D_WIN32"}
            or is_plat("linux") and {"-D__linux__"}
            or is_plat("bsd") and {"-D__FreeBSD__"}
            or is_plat("macosx") and {"-D__APPLE__"}
            or is_plat("android") and {"-D__ANDROID__"}
            or is_plat("iphoneos") and {"-D__APPLE__", "-DTARGET_OS_IOS"}
            or is_plat("wasm") and {"-D__EMSCRIPTEN__"}
            or {}
        ))
        table.join2(swigArgs, conf.extra)

        table.insert(swigArgs, src)

        -- Call swig to generate binding file from interface source file
        batchcmds:mkdir(path.directory(gen))
        batchcmds:show_progress(opt.progress, "${color.build.object}swig %s{clear}", src)
        batchcmds:vrunv(swig.program, swigArgs)
        batchcmds:compile(gen, obj)

        -- Only rebuild the file if its changed since last run
        batchcmds:add_depfiles(src)
        batchcmds:set_depmtime(os.mtime(obj))
        batchcmds:set_depcache(target:dependfile(obj))
    end)

rule_end()
