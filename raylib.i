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

%module raylib

// Define bool, to overcome `typedef enum { false, true } bool;` in raylib.h being unrecognized by SWIG
// c99 already supports bool type, so no need to define it as _Bool
#ifndef bool
    #define bool bool
#endif

%{
    #include <raylib.h>
    #include <raymath.h>
    #include <rlgl.h>
    #include <physac.h>
%}

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
%array_functions(PhysicsBodyData, PhysicsBodyDataArray)

//------
// Typemap tags
//------

%include <typemaps.i>

//module: core
extern unsigned char *LoadFileData(const char *fileName, unsigned int *OUTPUT);
extern char **GetDirectoryFiles(const char *dirPath, int *OUTPUT);
extern char **GetDroppedFiles(int *OUTPUT);
extern unsigned char *CompressData(unsigned char *data, int dataLength, int *OUTPUT);
extern unsigned char *DecompressData(unsigned char *compData, int compDataLength, int *OUTPUT);
extern void UpdateCamera(Camera *INOUT);

//module: shapes
%apply (Vector2 *INPUT, int) {(Vector2 *points, int pointsCount)};
extern void DrawLineStrip(Vector2 *points, int pointsCount, Color color);
extern void DrawTriangleFan(Vector2 *points, int pointsCount, Color color);
extern void DrawTriangleStrip(Vector2 *points, int pointsCount, Color color);
extern bool CheckCollisionLines(Vector2 s1, Vector2 e1, Vector2 s2, Vector2 e2, Vector2 *OUTPUT);
%clear (Vector2 *points, int pointsCount);

//module: textures
%apply (Vector2 *INPUT, int) {(Vector2 *points, int pointsCount), (Vector2 *texcoords, int texcoordsCount)};
extern Image LoadImageAnim(const char *fileName, int *OUTPUT);
extern Color *LoadImagePalette(Image image, int maxPaletteSize, int *OUTPUT);
extern void GenTextureMipmaps(Texture2D *INOUT);
extern void _SWIGExtra_DrawTexturePoly_ArgRearrange(Texture2D texture, Vector2 center, Vector2 *points, int pointsCount, Vector2 *texcoords, int texcoordsCount, Color tint);
%clear (Vector2 *points, int pointsCount), (Vector2 *texcoords, int texcoordsCount);

//module: text
%apply (int *INPUT, int) {(int *fontChars, int charsCount), (int *codepoints, int length)};
%apply int* OUTPUT{int *charsCount_out};
%apply SWIGTYPE** OUTPUT{Rectangle **recs};
extern Font LoadFontEx(const char *fileName, int fontSize, int *fontChars, int charsCount);
extern Font LoadFontFromMemory(const char *fileType, const unsigned char *fileData, int dataSize, int fontSize, int *fontChars, int charsCount);
extern CharInfo *_SWIGExtra_LoadFontData_ArgRearrange(const unsigned char *fileData, int dataSize, int fontSize, int *fontChars, int charsCount, int type, int *charsCount_out);
extern Image _SWIGExtra_GenImageFontAtlas_ArgRearrange(const CharInfo *chars, int charsCount, int fontSize, int padding, int packMethod, Rectangle **recs, int *charsCount_out);
extern char *TextToUtf8(int *codepoints, int length);
extern int *GetCodepoints(const char *text, int *OUTPUT);
extern int GetNextCodepoint(const char *text, int *OUTPUT);
extern char *_SWIGExtra_CodepointToUtf8_WithNullTerm(int codepoint);
%clear (int *fontChars, int charsCount), (int *codepoints, int length);
%clear int *charsCount_out;
%clear Rectangle **recs;

//module: models
%apply (Vector3 *INPUT, int) {(Vector3 *points, int pointsCount)};
%apply (Matrix *INPUT, int) {(Matrix *transforms, int instances)};
extern void DrawTriangleStrip3D(Vector3 *points, int pointsCount, Color color);
extern void UploadMesh(Mesh *INOUT, bool dynamic);
extern void DrawMeshInstanced(Mesh mesh, Material material, Matrix *transforms, int instances);
extern Material *LoadMaterials(const char *fileName, int *OUTPUT);
extern ModelAnimation *LoadModelAnimations(const char *fileName, int *OUTPUT);
void MeshTangents(Mesh *INOUT);
void MeshBinormals(Mesh *INOUT);
extern bool CheckCollisionRaySphereEx(Ray ray, Vector3 center, float radius, Vector3 *OUTPUT);
%clear (Vector3 *points, int pointsCount);
%clear (Matrix *transforms, int instances);

//raymath.h
extern void Vector3OrthoNormalize(Vector3 *INOUT, Vector3 *INOUT);
extern void QuaternionToAxisAngle(Quaternion q, Vector3 *OUTPUT, float *OUTPUT);

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
        return RL_FREE(mem);
    };
    void _SWIGExtra_DrawTexturePoly_ArgRearrange(Texture2D texture, Vector2 center, Vector2 *points, int pointsCount, Vector2 *texcoords, int texcoordsCount, Color tint){
        (void)texcoordsCount;
        return DrawTexturePoly(texture, center, points, texcoords, pointsCount, tint);
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
    %inline{const Color _SWIGExtra_##colorName = colorName;}
    %luacode{raylib.colorName = raylib._SWIGExtra_##colorName}
%enddef
%define REG_ALIAS(name, value)
    %luacode{raylib.name = raylib.value}
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

%luacode {
    local _metatable = getmetatable(raylib)
    local _module = {}
    for k, v in pairs(raylib) do rawset(raylib, k, nil); rawset(_module, k, v) end
    local _wrapper = setmetatable(raylib, {
        __index = function(t,k)
            local v = _module[k]
            rawset(t,k,v)
            return v
        end})
    _wrapper.swig = setmetatable(_module, _metatable)

    local _arrayGetterMapping = {
        ["int"] = _module.IntArray_getitem,
        ["float"] = _module.FloatArray_getitem,
        ["charP"] = _module.CharPArray_getitem,
        ["Color"] = _module.ColorArray_getitem,
        ["CharInfo"] = _module.CharInfoArray_getitem,
        ["Rectangle"] = _module.RectangleArray_getitem,
        ["Material"] = _module.MaterialArray_getitem,
        ["ModelAnimation"] = _module.ModelAnimationArray_getitem,
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
        local vec = _module.Vector2()
        if x then vec.x, vec.y = x, y end
        return vec
    end
    function _wrapper.Vector3(x, y, z)
        local vec = _module.Vector3()
        if x then vec.x, vec.y, vec.z = x, y, z end
        return vec
    end
    function _wrapper.Vector4(x, y, z, w)
        local vec = _module.Vector4()
        if x then vec.x, vec.y, vec.z, vec.w = x, y, z, w end
        return vec
    end
    _wrapper.Quaternion = _wrapper.Vector4
    function _wrapper.Color(r, g, b, a)
        local col = _module.Color()
        if r then col.r, col.g, col.b = r, g, b end
        if a then col.a = a end
        return col
    end
    function _wrapper.Rectangle(x, y, w, h)
        local rect = _module.Rectangle()
        if x then rect.x, rect.y = x, y end
        if w then rect.width, rect.height = w, h end
        return rect
    end
    function _wrapper.BoundingBox(min, max)
        local box = _module.BoundingBox()
        if min then box.min, box.max = min, max end
        return box
    end

    function _wrapper.GetDirectoryFiles(dirPath)
        return _CArrayToLuaTab("charP", _module.GetDirectoryFiles(dirPath))
    end
    function _wrapper.GetDroppedFiles()
        return _CArrayToLuaTab("charP", _module.GetDroppedFiles())
    end

    function _wrapper.LoadImageColors(image)
        return _CArrayToLuaTab("Color", _module.LoadImageColors(), image.width*image.height)
    end
    function _wrapper.LoadImagePalette(image, maxPaletteSize)
        return _CArrayToLuaTab("Color", _module.LoadImagePalette(image, maxPaletteSize))
    end
    function _wrapper.UnloadImageColors(colors)
        return _module.UnloadImageColors(colors[1])
    end
    function _wrapper.UnloadImagePalette(colors)
        return _module.UnloadImagePalette(colors[1])
    end

    function _wrapper.DrawTexturePoly(texture, center, points, texcoords, tint)
        return _module._SWIGExtra_DrawTexturePoly_ArgRearrange(texture, center, points, texcoords, tint)
    end

    function _wrapper.LoadFontData(fileData, dataSize, fontSize, fontChars, type)
        return _CArrayToLuaTab("CharInfo", _module._SWIGExtra_LoadFontData_ArgRearrange(fileData, dataSize, fontSize, fontChars, type))
    end
    function _wrapper.UnloadFontData(charInfos)
        return _module.UnloadFontData(charInfos[1], #charInfos)
    end
    function _wrapper.GenImageFontAtlas(chars, fontSize, padding, packMethod)
        local image, recs, charsCount = _module._SWIGExtra_GenImageFontAtlas_ArgRearrange(chars, fontSize, padding, packMethod)
        return image, _CArrayToLuaTab("Rectangle", recs, charsCount)
    end
    function _wrapper.GetCodepoints(text)
        return _CArrayToLuaTab("int", _module.GetCodepoints(text))
    end

    function _wrapper.LoadMaterials(fileName)
        return _CArrayToLuaTab("Material", _module.LoadMaterials(fileName))
    end
    function _wrapper.LoadModelAnimations(fileName)
        return _CArrayToLuaTab("ModelAnimation", _module.LoadModelAnimations(fileName))
    end
    function _wrapper.UnloadModelAnimations(animations)
        return _module.UnloadModelAnimations(animations[1], #animations)
    end
    function _wrapper.MatrixToFloat(matrix)
        return _CArrayToLuaTab("float", _module.MatrixToFloat(matrix), 16)
    end
    function _wrapper.Vector3ToFloat(vector3)
        return _CArrayToLuaTab("float", _module.Vector3ToFloat(vector3), 3)
    end
}

%include "raylib/raylib.h"
%include "raylib/raymath.h"
%include "raylib/rlgl.h"
%include "raylib/physac.h"
