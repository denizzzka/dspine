module spine.skeleton_attach;

import spine.skeleton;
import std.string: toStringz;
import std.exception: enforce;

package static Skeleton[size_t] attachedSkeletons;
private static size_t skeletonsCount = 0;

alias SkAtt = spSkeletonAttachment_unofficial;

void setAttachment(Skeleton si, string name, spSlot* slot, Skeleton addingSkeleton)
{
    // It is need to remove old skeleton attachment from array?
    if(slot.attachment !is null && slot.attachment.type == spAttachmentType.SKELETON)
    {
        SkAtt* a = cast(SkAtt*) slot.attachment;

        attachedSkeletons.remove(a.attachedSkeletonIdx);
    }

    if(addingSkeleton is null)
    {
        spSlot_setAttachment(slot, null);
    }
    else
    {
        attachedSkeletons[skeletonsCount] = addingSkeleton;

        SkAtt* attachment = createSkeletonAttachment(name, skeletonsCount);

        spSlot_setAttachment(slot, &attachment._super);

        skeletonsCount++;
    }
}

// TODO: it is need to add ability removing of attach
private SkAtt* createSkeletonAttachment(string name, size_t attachedSkeletonIdx)
{
    SkAtt* sa = cast(SkAtt*) spineCalloc(SkAtt.sizeof, 1, __FILE__, __LINE__);

    _spAttachment_init(&sa._super, name.toStringz, spAttachmentType.SKELETON, &disposeSkeletonAttachment);
    sa.attachedSkeletonIdx = attachedSkeletonIdx;

    return sa;
}

private extern (C) void disposeSkeletonAttachment(spAttachment* attachment)
{
	SkAtt* self = cast(SkAtt*) attachment;

	_spAttachment_deinit(attachment);
    _free(self);
}

private void* spineCalloc(size_t num, size_t size, string fileName, int line)
{
    assert(size > 0);

    auto ret = _calloc(num, size, fileName.toStringz, line);

    enforce(ret !is null);

    return ret;
}

package extern (C):

struct spSkeletonAttachment_unofficial
{
    spAttachment _super;
    alias _super this;

    size_t attachedSkeletonIdx;
}

private:

void* _calloc (size_t num, size_t size, const(char)* file, int line);
void _free (void* ptr);

void _spAttachment_init (spAttachment* self, const(char)* name, spAttachmentType type, void function(spAttachment* self) dispose);
void _spAttachment_deinit (spAttachment* self);

void spSlot_setAttachment (spSlot* self, spAttachment* attachment);
