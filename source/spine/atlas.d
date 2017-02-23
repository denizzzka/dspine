module spine.atlas;

import std.string: toStringz;
import std.exception;
import spine.skeleton: spAttachment;

class Atlas
{
    package spAtlas* atlas;

    this(string filename)
    {
        atlas = spAtlas_createFromFile(filename.toStringz, null);

        enforce(atlas);
    }

    ~this()
    {
        spAtlas_dispose(atlas);
    }

    spAtlasRegion* findRegion (string name) const
    {
	return spAtlas_findRegion (atlas, name.toStringz);
    }
}

extern(C):

enum spAtlasFormat
{
	SP_ATLAS_UNKNOWN_FORMAT,
	SP_ATLAS_ALPHA,
	SP_ATLAS_INTENSITY,
	SP_ATLAS_LUMINANCE_ALPHA,
	SP_ATLAS_RGB565,
	SP_ATLAS_RGBA4444,
	SP_ATLAS_RGB888,
	SP_ATLAS_RGBA8888
};

enum spAtlasFilter
{
	SP_ATLAS_UNKNOWN_FILTER,
	SP_ATLAS_NEAREST,
	SP_ATLAS_LINEAR,
	SP_ATLAS_MIPMAP,
	SP_ATLAS_MIPMAP_NEAREST_NEAREST,
	SP_ATLAS_MIPMAP_LINEAR_NEAREST,
	SP_ATLAS_MIPMAP_NEAREST_LINEAR,
	SP_ATLAS_MIPMAP_LINEAR_LINEAR
};

enum spAtlasWrap
{
	SP_ATLAS_MIRROREDREPEAT,
	SP_ATLAS_CLAMPTOEDGE,
	SP_ATLAS_REPEAT
};

package:

struct spAtlasPage
{
	const(spAtlas)* atlas;
	const(char)* name;
	spAtlasFormat format;
	spAtlasFilter minFilter, magFilter;
	spAtlasWrap uWrap, vWrap;

	void* rendererObject;
	int width, height;

	spAtlasPage* next;
};

struct spAtlas;

public struct spAtlasRegion
{
    const(char)* name;
    int x, y, width, height;
    float u, v, u2, v2;
    int offsetX, offsetY;
    int originalWidth, originalHeight;
    int index;
    int/*bool*/rotate;
    int/*bool*/flip;
    int* splits;
    int* pads;

    spAtlasPage* page;

    spAtlasRegion* next;
};

struct spRegionAttachment
{
	spAttachment _super;
	const char* path;
	float x, y, scaleX, scaleY, rotation, width, height;
	float r, g, b, a;

	void* rendererObject;
	int regionOffsetX, regionOffsetY; /* Pixels stripped from the bottom left, unrotated. */
	int regionWidth, regionHeight; /* Unrotated, stripped pixel size. */
	int regionOriginalWidth, regionOriginalHeight; /* Unrotated, unstripped pixel size. */

	float[8] offset;
	float[8] uvs;
};

enum spVertexIndex
{
	X1 = 0,
    Y1,
    X2,
    Y2,
    X3,
    Y3,
    X4,
    Y4
}

struct spVertexAttachment
{
	spAttachment _super;

	int bonesCount;
	int* bones;

	int verticesCount;
	float* vertices;

	int worldVerticesLength;
};

struct spMeshAttachment
{
	spVertexAttachment _super;

	void* rendererObject;
	int regionOffsetX, regionOffsetY; /* Pixels stripped from the bottom left, unrotated. */
	int regionWidth, regionHeight; /* Unrotated, stripped pixel size. */
	int regionOriginalWidth, regionOriginalHeight; /* Unrotated, unstripped pixel size. */
	float regionU, regionV, regionU2, regionV2;
	int/*bool*/regionRotate;

	const(char)* path;

	float* regionUVs;
	float* uvs;

	int trianglesCount;
	ushort* triangles;

	float r, g, b, a;

	int hullLength;

	const(spMeshAttachment)* parentMesh;
	int/*bool*/inheritDeform;

	/* Nonessential. */
	int edgesCount;
	int* edges;
	float width, height;
}

private:

spAtlas* spAtlas_createFromFile (const(char)* path, void* rendererObject);

void spAtlas_dispose (spAtlas* atlas);

char* _spUtil_readFile(const(char)* path, int* length)
{
    return _readFile(path, length); // TODO: it is need to set up something like errno here
}

char* _readFile (const(char)* path, int* length);

spAtlasRegion* spAtlas_findRegion (const(spAtlas)* self, const(char)* name);
