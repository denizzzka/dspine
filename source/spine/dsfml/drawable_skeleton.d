module spine.dsfml.drawable_skeleton;

import spine.atlas;
import spine.dsfml.textures_storage;
import spine.skeleton;
import spine.skeleton_attach;
import spine.animation;
import dsfml.graphics;
import dsfml.graphics.drawable;
import std.conv: to;
debug import std.math: isNaN;
debug import std.stdio;

enum SPINE_MESH_VERTEX_COUNT_MAX = 1000;

class SkeletonDrawable : Skeleton, Drawable
{
    private VertexArray vertexArray;
    private float[SPINE_MESH_VERTEX_COUNT_MAX] worldVertices;

    this(SkeletonData sd)
    {
        super(sd);

        vertexArray = new VertexArray(PrimitiveType.Triangles, sp_skeleton_protected.bonesCount * 4);
    }

    void draw(RenderTarget target, RenderStates states = RenderStates.Default)
    {
        debug(spine_dsfml) writeln("spine.dsfml.SkeletonDrawable.draw()");
        vertexArray.clear();

        Vertex[4] vertices;
        Vertex vertex;

        foreach(i; 0 .. sp_skeleton_protected.slotsCount)
        {
            debug(spine_dsfml) writeln("slot num=", i);

            const spSlot* slot = sp_skeleton_protected.drawOrder[i];
            debug(spine_dsfml) writeln("slot=", *slot);
            debug(spine_dsfml) writeln("slot.bone=", *slot.bone);
            assert(!slot.bone.a.isNaN);
            assert(!slot.bone.b.isNaN);
            assert(!slot.bone.c.isNaN);
            assert(!slot.bone.d.isNaN);
            assert(!slot.bone.worldX.isNaN);
            assert(!slot.bone.worldY.isNaN);

            const spAttachment* attachment = slot.attachment;

            if(attachment is null) continue;

            BlendMode blend;

            switch(slot.data.blendMode)
            {
                case spBlendMode.ADDITIVE:
                    blend = BlendMode.Add;
                    break;

                case spBlendMode.MULTIPLY:
                    blend = BlendMode.Multiply;
                    break;

                case spBlendMode.SCREEN: // Unsupported, fall through.
                default:
                    blend = BlendMode.Alpha;
            }

            if(states.blendMode != blend)
            {
                target.draw(vertexArray, states);
                vertexArray.clear();
                states.blendMode = blend;
            }

            Texture texture;

            switch(attachment.type)
            {
                case spAttachmentType.REGION:
                    debug(spine_dsfml) writeln("draw region");

                    spRegionAttachment* regionAttachment = cast(spRegionAttachment*) attachment;

                    size_t textureNum = cast(size_t)(cast(spAtlasRegion*)regionAttachment.rendererObject).page.rendererObject;
                    texture = loadedTextures[textureNum];
                    assert(texture);

                    debug(spine_dsfml) writeln("call computeWorldVertices, args:");
                    debug(spine_dsfml) writeln("regionAttachment=", *regionAttachment);
                    debug(spine_dsfml) writeln("and slot.bone=", *slot.bone);
                    spRegionAttachment_computeWorldVertices(regionAttachment, slot.bone, worldVertices.ptr);

                    debug(spine_dsfml) writeln("call colorize");
                    Color _c = colorize(sp_skeleton_protected, slot);

                    debug(spine_dsfml) writeln("call texture.getSize()");
                    Vector2u size = texture.getSize();
                    debug(spine_dsfml) writeln("size=", size);

                    debug(spine_dsfml) writeln("fill vertices");

                    with(spVertexIndex)
                    {
                        with(vertices[0])
                        {
                            color = _c;
                            position.x = worldVertices[X1];
                            position.y = worldVertices[Y1];
                            debug(spine_dsfml) writeln("worldVertices[X1]=", worldVertices[X1]);
                            assert(!worldVertices[X1].isNaN);
                            texCoords.x = regionAttachment.uvs[X1] * size.x;
                            texCoords.y = regionAttachment.uvs[Y1] * size.y;
                            assert(worldVertices[X1] != float.nan);
                            assert(position.x != float.nan);
                        }

                        with(vertices[1])
                        {
                            color = _c;
                            position.x = worldVertices[X2];
                            position.y = worldVertices[Y2];
                            texCoords.x = regionAttachment.uvs[X2] * size.x;
                            texCoords.y = regionAttachment.uvs[Y2] * size.y;
                        }

                        with(vertices[2])
                        {
                            color = _c;
                            position.x = worldVertices[X3];
                            position.y = worldVertices[Y3];
                            texCoords.x = regionAttachment.uvs[X3] * size.x;
                            texCoords.y = regionAttachment.uvs[Y3] * size.y;
                        }

                        with(vertices[3]) {
                            color = _c;
                            position.x = worldVertices[X4];
                            position.y = worldVertices[Y4];
                            texCoords.x = regionAttachment.uvs[X4] * size.x;
                            texCoords.y = regionAttachment.uvs[Y4] * size.y;
                        }
                    }

                    with(vertexArray)
                    {
                        append(vertices[0]);
                        append(vertices[1]);
                        append(vertices[2]);
                        append(vertices[0]);
                        append(vertices[2]);
                        append(vertices[3]);
                    }
                    break;

                //~ case spAttachmentType.MESH:
                    //~ debug(spine_dsfml) writeln("draw mesh");

                    //~ spMeshAttachment* mesh = cast(spMeshAttachment*) attachment;

                    //~ if (mesh._super.worldVerticesLength > SPINE_MESH_VERTEX_COUNT_MAX) continue;
                    //~ texture = cast(size_t)(cast(spAtlasRegion*)mesh.rendererObject).page.rendererObject;
                    //~ spMeshAttachment_computeWorldVertices(mesh, slot, worldVertices.ptr);

                    //~ vertex.color = colorize(sp_skeleton_protected, slot);
                    //~ Vector2u size = texture.getSize();

                    //~ foreach(_i; 0 .. mesh.trianglesCount)
                    //~ {
                        //~ int index = mesh.triangles[_i] << 1;
                        //~ vertex.position.x = worldVertices[index];
                        //~ vertex.position.y = worldVertices[index + 1];
                        //~ vertex.texCoords.x = mesh.uvs[index] * size.x;
                        //~ vertex.texCoords.y = mesh.uvs[index + 1] * size.y;
                        //~ vertexArray.append(vertex);
                    //~ }
                    //~ break;

                case spAttachmentType.BOUNDING_BOX:
                    break;

                case spAttachmentType.SKELETON:
                    target.draw(vertexArray, states);
                    vertexArray.clear();

                    spSkeletonAttachment_unofficial* att = cast(spSkeletonAttachment_unofficial*) attachment;
                    debug(spine_dsfml_skeleton) writeln("Skeleton ", att._super.name.to!string, " draw: attachedSkeletonIdx=", att.attachedSkeletonIdx);

                    SkeletonDrawable si = cast(SkeletonDrawable) attachedSkeletons[att.attachedSkeletonIdx];

                    auto boneStates = states;
                    boneStates.transform.translate(slot.bone.worldX, slot.bone.worldY);
                    boneStates.transform.rotate(slot.bone.rotation);

                    debug(spine_dsfml_skeleton) writeln("spBone=", *slot.bone);

                    si.draw(target, boneStates);
                    break;

                default:
                        assert(0, "Attachment type "~attachment.type.to!string~" isn't implementded");
            }

            debug(spine_dsfml) writeln("vertexArray.getVertexCount=", vertexArray.getVertexCount);

            if(texture !is null)
            {
                // SMFL doesn't handle batching for us, so we'll just force a single texture per skeleton.
                states.texture = texture;
                debug(spine_dsfml) writeln("Used texture at ", &texture);
            }
        }

        debug(spine_dsfml)
        {
            writeln("vertexArray:");

            foreach(j; 0 .. vertexArray.getVertexCount)
            {
                writeln(vertexArray[j]);
                assert(!vertexArray[j].position.x.isNaN);
                assert(!vertexArray[j].position.y.isNaN);
            }

            writeln("call SFML draw");
        }

        target.draw(vertexArray, states);
    }
}

unittest
{
    import spine.atlas;
    import spine.skeleton;
    import spine.skeleton_bounds;
    import spine.skeleton_attach: setAttachment;

    auto a = new Atlas("resources/textures/GAME.atlas");
    auto sd = new SkeletonData("resources/animations/actor_pretty.json", a);
    sd.defaultSkin = sd.findSkin("default");

    auto si1 = new Skeleton(sd);
    auto si2 = new SkeletonDrawable(sd);

    auto bounds = new SkeletonBounds;
    bounds.update(si2, true);

    int boneIdx = sd.findBoneIndex("root-hands");
    auto bone = si1.getBoneByIndex(boneIdx);

    // attaching check
    {
        int slotIdx = sd.findSlotIndex("slot-primary");
        Slot slot = si2.getSlotByIndex(slotIdx);
        auto att = si2.getAttachmentForSlotIndex(slotIdx, "watergun-skin");

        si2.setAttachment("slot-primary", "watergun-skin");

        {
            // skeleton attached to skeleton test

            auto ak74data = new SkeletonData("resources/animations/weapon-ak74.json", a);
            auto ak74 = new SkeletonDrawable(ak74data);

            auto oldNum = attachedSkeletons.length;

            setAttachment(si2, "ak 74", slot, ak74);

            assert(slot.attachment !is null);

            setAttachment(si2, "ak 74", slot, null); // remove attach

            assert(slot.attachment is null);
            assert(oldNum == attachedSkeletons.length);
        }
    }

    destroy(a);
    destroy(sd);
    destroy(si1);
    destroy(si2);
}

bool enforceSmooth = false;

private:

Color colorize(in spSkeleton* skeleton,  in spSlot* slot)
{
    import std.conv: to;

    Color ret;

    with(ret)
    {
        r = (skeleton.r * slot.r * 255.0f).to!ubyte;
        g = (skeleton.g * slot.g * 255.0f).to!ubyte;
        b = (skeleton.b * slot.b * 255.0f).to!ubyte;
        a = (skeleton.a * slot.a * 255.0f).to!ubyte;
    }

    return ret;
}

extern(C):

void spRegionAttachment_computeWorldVertices (spRegionAttachment* self, const(spBone)* bone, float* vertices);

void spMeshAttachment_computeWorldVertices (spMeshAttachment* self, const(spSlot)* slot, float* worldVertices);
