// SWIG-4.0.2 binding for raylib v3.7

// Notes:
//
//   Unsupported functions:
//   void SetTraceLogCallback(TraceLogCallback callback);
//   void SetLoadFileDataCallback(LoadFileDataCallback callback);
//   void SetSaveFileDataCallback(SaveFileDataCallback callback);
//   void SetLoadFileTextCallback(LoadFileTextCallback callback);
//   void SetSaveFileTextCallback(SaveFileTextCallback callback);
//
//   Ignored functions:
//   `TextXXX` string manipulation functions are ignored, except `TextToUtf8`.
//   Because nearly all the script languages supported by SWIG have their own functions dealing strings, therefore bindings of these functions from C are not that helpful and fail both in performance and in maintainability.
//
//   `va_list` related behaviours:
//    Functions like `void TraceLog(int logLevel, const char* text, ...);` are binded using the default behaviour of SWIG, which is, skipping the `...` entirely.
//    e.g. In Lua, you call `raylib.TraceLog(raylib.LOG_INFO, string.format("%s%d", "This is formatted in Lua instead.", 123))`.
//
//    Lua: All bindings are now in Lua style: featuring multi-val return, LuaTable-CArray conversion, etc.
//    e.g. `local compressed, compressedLen = raylib.CompressData(data, dataLen)`; `local materials_luaTable = raylib.LoadMaterials(fileName)`

//------
// Module declaration
//------

%module raylib

#ifdef SWIGLUA
%luacode {
    local _moduleName = "raylib"
    local _swig = _G[_moduleName]
    _G[_moduleName] = nil
}
#endif

// Overcome `__stdcall`, `__cdecl` etc. .
%include <windows.i>

// Define bool, to overcome `typedef enum { false, true } bool;` in raylib.h being unrecognized by SWIG
// c99 already supports bool type, so no need to define it as _Bool
#ifndef bool
    #define bool bool
#endif

%{
    #include "config.h"
    #include "raylib.h"
    #include "raymath.h"
    #include "rlgl.h"
%}
#ifdef SWIGRAYLIB_USE_PHYSAC
%{
    #include "physac.h"
%}
#endif
#ifdef SWIGRAYLIB_USE_EASINGS
%{
    #include "easings.h"
%}
#endif

//------
// General tags
//------

%ignore TextCopy;
%ignore TextIsEqual;
%ignore TextLength;
%ignore TextFormat;
%ignore TextSubtext;
%ignore TextReplace;
%ignore TextInsert;
%ignore TextJoin;
%ignore TextSplit;
%ignore TextAppend;
%ignore TextFindIndex;
%ignore TextToUpper;
%ignore TextToLower;
%ignore TextToPascal;
%ignore TextToInteger;

%newobject LoadFileText;
%delobject UnloadFileText;
%newobject TextToUtf8;
%newobject LoadMaterials;
%newobject LoadWaveSamples;
%delobject UnloadWaveSamples;
%newobject rlReadTexturePixels;
%newobject rlReadScreenPixels;

%newobject _SWIGExtra_CodepointToUtf8_WithNullTerm;
%newobject _SWIGExtra_MatrixToFloat;
%newobject _SWIGExtra_Vector3ToFloat;

//------
// Array type tags
//------

%include <carrays.i>
%array_functions(int, IntArray)
%array_functions(float, FloatArray)
%array_functions(char, CharArray)
%array_functions(unsigned int, UintArray)
%array_functions(unsigned char, UcharArray)
%array_functions(char*, CharPArray)
%array_functions(Vector2, Vector2Array)
%array_functions(Vector3, Vector3Array)
%array_functions(Vector4, Vector4Array)
%array_functions(Quaternion, QuaternionArray)
%array_functions(Matrix, MatrixArray)
%array_functions(Color, ColorArray)
%array_functions(Rectangle, RectangleArray)
%array_functions(Image, ImageArray)
%array_functions(Texture, TextureArray)
%array_functions(RenderTexture, RenderTextureArray)
%array_functions(NPatchInfo, NPatchInfoArray)
%array_functions(CharInfo, CharInfoArray)
%array_functions(Font, FontArray)
%array_functions(Camera, CameraArray)
%array_functions(Camera2D, Camera2DArray)
%array_functions(Mesh, MeshArray)
%array_functions(Shader, ShaderArray)
%array_functions(MaterialMap, MaterialMapArray)
%array_functions(Material, MaterialArray)
%array_functions(Model, ModelArray)
%array_functions(Transform, TransformArray)
%array_functions(BoneInfo, BoneInfoArray)
%array_functions(ModelAnimation, ModelAnimationArray)
%array_functions(Ray, RayArray)
%array_functions(RayHitInfo, RayHitInfoArray)
%array_functions(BoundingBox, BoundingBoxArray)
%array_functions(Wave, WaveArray)
%array_functions(Sound, SoundArray)
%array_functions(Music, MusicArray)
%array_functions(AudioStream, AudioStreamArray)
%array_functions(VrDeviceInfo, VrDeviceInfoArray)
%array_functions(VrStereoConfig, VrStereoConfigArray)
%array_functions(VertexBuffer, VertexBufferArray)
%array_functions(DrawCall, DrawCallArray)
%array_functions(RenderBatch, RenderBatchArray)
#ifdef SWIGRAYLIB_USE_PHYSAC
%array_functions(PhysicsBodyData, PhysicsBodyDataArray)
#endif

//------
// Typemap tags + Import the headers
//------

%include <typemaps.i>
#ifdef SWIGLUA
%typemap(in) SWIGTYPE *INPUT {
    if (!SWIG_IsOK(SWIG_ConvertPtr(L, $argnum, (void **)&$1, $1_descriptor, 0))){
        SWIG_fail_ptr("$symname", $argnum, $1_descriptor);
    }
}
%typemap(in, numinputs=0) SWIGTYPE *OUTPUT {};
%typemap(argout) SWIGTYPE *OUTPUT{
    SWIG_NewPointerObj(L, $1, $1_descriptor, 1); SWIG_arg++;
}
%typemap(argout) SWIGTYPE *OUTPUT_UNOWN{
    SWIG_NewPointerObj(L, $1, $1_descriptor, 0); SWIG_arg++;
}
%typemap(in) SWIGTYPE *INOUT = SWIGTYPE *INPUT;
%typemap(argout) SWIGTYPE *INOUT = SWIGTYPE *OUTPUT_UNOWN;
#endif

//config.h
%include "config.h"

//raylib.h
%apply unsigned int *OUTPUT {unsigned int *bytesRead};
%apply int *OUTPUT {int *compDataLength, int *dataLength, int *frames, int *bytesProcessed};
%apply int *OUTPUT {int *count, int *colorsCount, int *charsCount_out, int *materialCount, int *animsCount};
%apply SWIGTYPE *OUTPUT {Vector2 *collisionPoint};
%apply SWIGTYPE *OUTPUT {Vector3 *collisionPoint};
%apply SWIGTYPE **OUTPUT {Rectangle **recs};
%apply SWIGTYPE *INOUT {Camera *camera};
%apply SWIGTYPE *INOUT {Texture2D *texture};
%apply SWIGTYPE *INOUT {Mesh *mesh};
%apply (Vector2 *INPUT, int) {(Vector2 *points, int pointsCount), (Vector2 *texcoords, int texcoordsCount), (int *fontChars, int charsCount), (int *codepoints, int length)};
%apply (Vector3 *INPUT, int) {(Vector3 *points, int pointsCount)};
%apply (Matrix *INPUT, int) {(Matrix *transforms, int instances)};

%include "raylib.h"
void _SWIGExtra_DrawTexturePoly_ArgRearrange(Texture2D texture, Vector2 center, Vector2 *points, int pointsCount, Vector2 *texcoords, int texcoordsCount, Color tint);
CharInfo *_SWIGExtra_LoadFontData_ArgRearrange(const unsigned char *fileData, int dataSize, int fontSize, int *fontChars, int charsCount, int type, int *charsCount_out);
Image _SWIGExtra_GenImageFontAtlas_ArgRearrange(const CharInfo *chars, int charsCount, int fontSize, int padding, int packMethod, Rectangle **recs, int *charsCount_out);
char *_SWIGExtra_CodepointToUtf8_WithNullTerm(int codepoint);

%clear unsigned int *bytesRead, int *compDataLength, int *dataLength, int *frames, int *bytesProcessed;
%clear int *count, int *colorsCount, int *charsCount_out, int *materialCount, int *animsCount;
%clear Vector2 *collisionPoint, Vector3 *collisionPoint;
%clear Rectangle **recs;
%clear Camera *camera, Texture2D *texture, Mesh *mesh;
%clear (Vector2 *points, int pointsCount), (Vector2 *texcoords, int texcoordsCount), (int *fontChars, int charsCount), (int *codepoints, int length), (Vector3 *points, int pointsCount), (Matrix *transforms, int instances);

//raymath.h
extern void Vector3OrthoNormalize(Vector3 *INOUT, Vector3 *INOUT);
extern void QuaternionToAxisAngle(Quaternion q, Vector3 *OUTPUT, float *OUTPUT);
%include "raymath.h"

//other headers
%include "rlgl.h" //Don't do typemaps to save C++ <-> script type conversions; use array functions in case you really need rlgl functions
#ifdef SWIGRAYLIB_USE_PHYSAC
%include "physac.h"
#endif
#ifdef SWIGRAYLIB_USE_EASINGS
%include "easings.h"
#endif


//------
// Helper functions
//------

%inline %{
    //raylib.h
    void *_SWIGExtra_RL_MALLOC(size_t size){
        return RL_MALLOC(size);
    };
    void *_SWIGExtra_RL_CALLOC(size_t n, size_t size){
        return RL_CALLOC(n, size);
    };
    void *_SWIGExtra_RL_REALLOC(void *mem, size_t size){
        return RL_REALLOC(mem, size);
    };
    void _SWIGExtra_RL_FREE(void *mem){
        RL_FREE(mem);
    };
    void _SWIGExtra_DrawTexturePoly_ArgRearrange(Texture2D texture, Vector2 center, Vector2 *points, int pointsCount, Vector2 *texcoords, int texcoordsCount, Color tint){
        (void)texcoordsCount;
        DrawTexturePoly(texture, center, points, texcoords, pointsCount, tint);
    };
    CharInfo *_SWIGExtra_LoadFontData_ArgRearrange(const unsigned char *fileData, int dataSize, int fontSize, int *fontChars, int charsCount, int type, int *charsCount_out){
        *charsCount_out = charsCount;
        return LoadFontData(fileData, dataSize, fontSize, fontChars, charsCount, type);
    };
    Image _SWIGExtra_GenImageFontAtlas_ArgRearrange(const CharInfo *chars, int charsCount, int fontSize, int padding, int packMethod, Rectangle **recs, int *charsCount_out){
        *charsCount_out = charsCount;
        return GenImageFontAtlas(chars, recs, charsCount, fontSize, padding, packMethod);
    };
    char *_SWIGExtra_CodepointToUtf8_WithNullTerm(int codepoint){
        int len;
        const char *utf8 = CodepointToUtf8(codepoint, &len);
        char *utf8NullTerm = (char *)malloc((len+1)*sizeof(char));
        memcpy(utf8NullTerm, utf8, len*sizeof(char));
        utf8NullTerm[len] = '\0';
        return utf8NullTerm;
    };
    //raymath.h
    float *_SWIGExtra_MatrixToFloat(Matrix mat){
        float* copy = (float*)malloc(16*sizeof(float));
        memcpy(copy, MatrixToFloat(mat), 16*sizeof(float));
        return copy;
    };
    float *_SWIGExtra_Vector3ToFloat(Vector3 vec){
        float* copy = (float*)malloc(3*sizeof(float));
        memcpy(copy, Vector3ToFloat(vec), 3*sizeof(float));
        return copy;
    };
%}

//------
// Macros and aliases
//------

#ifdef SWIGLUA
%define REG_COLOR(colorName)
    %inline %{ const Color _SWIGExtra_##colorName = colorName; %}
    %luacode %{ _swig[#colorName] = _swig._SWIGExtra_##colorName %}
%enddef
%define REG_ALIAS(dest, source)
    %luacode %{ _swig[#dest] = _swig[#source] %}
%enddef
#endif

//colors
REG_COLOR(LIGHTGRAY)
REG_COLOR(GRAY)
REG_COLOR(DARKGRAY)
REG_COLOR(YELLOW)
REG_COLOR(GOLD)
REG_COLOR(ORANGE)
REG_COLOR(PINK)
REG_COLOR(RED)
REG_COLOR(MAROON)
REG_COLOR(GREEN)
REG_COLOR(LIME)
REG_COLOR(DARKGREEN)
REG_COLOR(SKYBLUE)
REG_COLOR(BLUE)
REG_COLOR(DARKBLUE)
REG_COLOR(PURPLE)
REG_COLOR(VIOLET)
REG_COLOR(DARKPURPLE)
REG_COLOR(BEIGE)
REG_COLOR(BROWN)
REG_COLOR(DARKBROWN)
REG_COLOR(WHITE)
REG_COLOR(BLACK)
REG_COLOR(BLANK)
REG_COLOR(MAGENTA)
REG_COLOR(RAYWHITE)
//macro and typedef aliases
REG_ALIAS(FormatText, TextFormat)
REG_ALIAS(LoadText, LoadFileText)
REG_ALIAS(GetExtension, GetFileExtension)
REG_ALIAS(GetImageData, LoadImageColors)
REG_ALIAS(FILTER_POINT, TEXTURE_FILTER_POINT)
REG_ALIAS(FILTER_BILINEAR, TEXTURE_FILTER_BILINEAR)
REG_ALIAS(MAP_DIFFUSE, MATERIAL_MAP_DIFFUSE)
REG_ALIAS(PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, PIXELFORMAT_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
REG_ALIAS(Quaternion, Vector4)
REG_ALIAS(Texture2D, Texture)
REG_ALIAS(TextureCubemap, Texture)
REG_ALIAS(RenderTexture2D, RenderTexture)
REG_ALIAS(SpriteFont, Font)
REG_ALIAS(Camera, Camera3D)
REG_ALIAS(MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_ALBEDO)
REG_ALIAS(MATERIAL_MAP_SPECULAR, MATERIAL_MAP_METALNESS)
REG_ALIAS(SHADER_LOC_MAP_DIFFUSE, SHADER_LOC_MAP_ALBEDO)
REG_ALIAS(SHADER_LOC_MAP_SPECULAR, SHADER_LOC_MAP_METALNESS)
//swig extras
REG_ALIAS(RL_MALLOC, _SWIGExtra_RL_MALLOC)
REG_ALIAS(RL_CALLOC, _SWIGExtra_RL_CALLOC)
REG_ALIAS(RL_REALLOC, _SWIGExtra_RL_REALLOC)
REG_ALIAS(RL_FREE, _SWIGExtra_RL_FREE)
REG_ALIAS(CodepointToUtf8, _SWIGExtra_CodepointToUtf8_WithNullTerm)
REG_ALIAS(MatrixToFloat, _SWIGExtra_MatrixToFloat)
REG_ALIAS(Vector3ToFloat, _SWIGExtra_Vector3ToFloat)

//------
// Lua wrapper functions
//------

#ifdef SWIGLUA
%luacode %{
    local _wrapper = {}
    local _metatable = getmetatable(_swig)
    for k, v in pairs(_swig) do
        rawset(_swig, k, nil)
        rawset(_wrapper, k, v)
    end
    _wrapper, _swig = _swig, _wrapper
    setmetatable(_wrapper, {
        __index = function(t,k)
            local v = _swig[k]
            rawset(t,k,v)
            return v
        end})
    setmetatable(_swig, _metatable)
    _wrapper.swig = _swig
    package.loaded[_moduleName] = _wrapper

    local _arrayGetterMapping = {
        ["int"] = _swig.IntArray_getitem,
        ["float"] = _swig.FloatArray_getitem,
        ["charP"] = _swig.CharPArray_getitem,
        ["Color"] = _swig.ColorArray_getitem,
        ["CharInfo"] = _swig.CharInfoArray_getitem,
        ["Rectangle"] = _swig.RectangleArray_getitem,
        ["Material"] = _swig.MaterialArray_getitem,
        ["ModelAnimation"] = _swig.ModelAnimationArray_getitem,
    }
    local function _CArrayToLuaTab(arrayType, cArray, len)
        local tab = {}
        local getter = _arrayGetterMapping[arrayType]
        for i = 1, len do
            tab[i] = getter(cArray, i-1)
        end
        return tab
    end

    function _wrapper.Vector2(x, y)
        local vec = _swig.Vector2()
        if x then vec.x, vec.y = x, y end
        return vec
    end
    function _wrapper.Vector3(x, y, z)
        local vec = _swig.Vector3()
        if x then vec.x, vec.y, vec.z = x, y, z end
        return vec
    end
    function _wrapper.Vector4(x, y, z, w)
        local vec = _swig.Vector4()
        if x then vec.x, vec.y, vec.z, vec.w = x, y, z, w end
        return vec
    end
    _wrapper.Quaternion = _wrapper.Vector4
    function _wrapper.Color(r, g, b, a)
        local col = _swig.Color()
        if r then col.r, col.g, col.b = r, g, b end
        if a then col.a = a end
        return col
    end
    function _wrapper.Rectangle(x, y, w, h)
        local rect = _swig.Rectangle()
        if x then rect.x, rect.y = x, y end
        if w then rect.width, rect.height = w, h end
        return rect
    end
    function _wrapper.BoundingBox(min, max)
        local box = _swig.BoundingBox()
        if min then box.min, box.max = min, max end
        return box
    end

    function _wrapper.GetDirectoryFiles(dirPath)
        return _CArrayToLuaTab("charP", _swig.GetDirectoryFiles(dirPath))
    end
    function _wrapper.GetDroppedFiles()
        return _CArrayToLuaTab("charP", _swig.GetDroppedFiles())
    end

    function _wrapper.LoadImageColors(image)
        return _CArrayToLuaTab("Color", _swig.LoadImageColors(), image.width*image.height)
    end
    function _wrapper.LoadImagePalette(image, maxPaletteSize)
        return _CArrayToLuaTab("Color", _swig.LoadImagePalette(image, maxPaletteSize))
    end
    function _wrapper.UnloadImageColors(colors)
        return _swig.UnloadImageColors(colors[1])
    end
    function _wrapper.UnloadImagePalette(colors)
        return _swig.UnloadImagePalette(colors[1])
    end

    function _wrapper.DrawTexturePoly(texture, center, points, texcoords, tint)
        return _swig._SWIGExtra_DrawTexturePoly_ArgRearrange(texture, center, points, texcoords, tint)
    end

    function _wrapper.LoadFontData(fileData, dataSize, fontSize, fontChars, type)
        return _CArrayToLuaTab("CharInfo", _swig._SWIGExtra_LoadFontData_ArgRearrange(fileData, dataSize, fontSize, fontChars, type))
    end
    function _wrapper.UnloadFontData(charInfos)
        return _swig.UnloadFontData(charInfos[1], #charInfos)
    end
    function _wrapper.GenImageFontAtlas(chars, fontSize, padding, packMethod)
        local image, recs, charsCount = _swig._SWIGExtra_GenImageFontAtlas_ArgRearrange(chars, fontSize, padding, packMethod)
        return image, _CArrayToLuaTab("Rectangle", recs, charsCount)
    end
    function _wrapper.GetCodepoints(text)
        return _CArrayToLuaTab("int", _swig.GetCodepoints(text))
    end

    function _wrapper.LoadMaterials(fileName)
        return _CArrayToLuaTab("Material", _swig.LoadMaterials(fileName))
    end
    function _wrapper.LoadModelAnimations(fileName)
        return _CArrayToLuaTab("ModelAnimation", _swig.LoadModelAnimations(fileName))
    end
    function _wrapper.UnloadModelAnimations(animations)
        return _swig.UnloadModelAnimations(animations[1], #animations)
    end
    function _wrapper.MatrixToFloat(matrix)
        return _CArrayToLuaTab("float", _swig.MatrixToFloat(matrix), 16)
    end
    function _wrapper.Vector3ToFloat(vector3)
        return _CArrayToLuaTab("float", _swig.Vector3ToFloat(vector3), 3)
    end
%}
#endif
