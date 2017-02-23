module spine.animation;

import spine.skeleton;
import std.string: toStringz;
import std.conv: to;

class AnimationStateData
{
    private SkeletonData skeletonData;
    package spAnimationStateData* sp_animationStateData;

    this(SkeletonData sd)
    {
        skeletonData = sd;
        sp_animationStateData = spAnimationStateData_create(skeletonData.sp_skeletonData);

        assert(sp_animationStateData);
    }

    ~this()
    {
        spAnimationStateData_dispose(sp_animationStateData);
    }

    void setMixByName(string fromName, string toName, float duration)
    {
        spAnimationStateData_setMixByName(
                sp_animationStateData,
                fromName.toStringz,
                toName.toStringz,
                duration
            );
    }

    void setMix(Animation from, Animation to, float duration)
    {
        spAnimationStateData_setMix(
                sp_animationStateData,
                from.sp_animation,
                to.sp_animation,
                duration
            );
    }
}

class AnimationStateInstance
{
    private AnimationStateData stateData;
    package spAnimationState* sp_animationState;

    this(AnimationStateData asd)
    {
        stateData = asd;
        sp_animationState = spAnimationState_create(stateData.sp_animationStateData);

        assert(sp_animationState);
    }

    ~this()
    {
        spAnimationState_dispose(sp_animationState);
    }

    void update(float deltaTime)
    {
        spAnimationState_update(sp_animationState, deltaTime);
    }

    void apply(Skeleton skeleton)
    {
        spAnimationState_apply(sp_animationState, skeleton.sp_skeleton);
    }

    void setAnimationByName(int trackIndex, string animationName, bool loop)
    {
        spAnimationState_setAnimationByName(sp_animationState, trackIndex, animationName.toStringz, loop);
    }

    void setAnimation(int trackIndex, Animation animation, bool loop)
    {
        spAnimationState_setAnimation(sp_animationState, trackIndex, animation.sp_animation, loop);
    }

    void addAnimationByName(int trackIndex, string animationName, bool loop, float delay)
    {
        spAnimationState_addAnimationByName(sp_animationState, trackIndex, animationName.toStringz, loop, delay);
    }

    void addAnimation(int trackIndex, Animation animation, bool loop, float delay)
    {
        spAnimationState_addAnimation(sp_animationState, trackIndex, animation.sp_animation, loop, delay);
    }

    void timeScale(float t)
    {
        sp_animationState.timeScale = t;
    }

    void addListener(spAnimationStateListener listener)
    {
        sp_animationState.listener = listener;
    }
}

struct Animation
{
    private spAnimation* sp_animation;
}

Animation findAnimation(SkeletonData sd, string animationName)
{
    Animation ret;
    ret.sp_animation = spSkeletonData_findAnimation(sd.sp_skeletonData, animationName.toStringz);

    return ret;
}

extern(C):

enum spEventType
{
    SP_ANIMATION_START,
    SP_ANIMATION_INTERRUPT,
    SP_ANIMATION_END,
    SP_ANIMATION_COMPLETE,
    SP_ANIMATION_DISPOSE,
    SP_ANIMATION_EVENT
}

private:

struct spEventData
{
	const char* name;
	int intValue;
	float floatValue;
	const(char)* stringValue;

    string toString() const
    {
        return
            "name="~name.to!string~
            " intValue="~intValue.to!string~
            " floatValue="~floatValue.to!string~
            " stringValue="~stringValue.to!string;
    }
}

struct spEvent
{
	const(spEventData)* data;
	const float time;
	int intValue;
	float floatValue;
	const(char)* stringValue;

    string toString() const
    {
        return
            "data=(ptr="~data.to!string~
            " "~data.toString~
            ") time="~time.to!string~
            " intValue="~intValue.to!string~
            " floatValue="~floatValue.to!string~
            " stringValue="~stringValue.to!string;
    }
}

void spAnimation_dispose (spAnimation* self);

void spAnimation_apply (const(spAnimation)* self, spSkeleton* skeleton, float lastTime, float time, int loop,
		spEvent** events, int* eventsCount, float alpha, int /*boolean*/ setupPose, int /*boolean*/ mixingOut);

spAnimation* spSkeletonData_findAnimation (const(spSkeletonData)* self, const(char)* animationName);

alias spAnimationStateListener = void function(spAnimationState* state, spEventType type, spTrackEntry* entry, spEvent* event);

struct spAnimationState
{
	const(spAnimationStateData)* data;

	int tracksCount;
	spTrackEntry** tracks;

	spAnimationStateListener listener;

	float timeScale = 0;

	void* rendererObject;
}

struct spAnimationStateData;

spAnimationStateData* spAnimationStateData_create (spSkeletonData* skeletonData);
void spAnimationStateData_dispose (spAnimationStateData* self);

void spAnimationStateData_setMixByName (spAnimationStateData* self, const(char)* fromName, const(char)* toName, float duration);

void spAnimationStateData_setMix (spAnimationStateData* self, spAnimation* from, spAnimation* to, float duration);

/* @param data May be 0 for no mixing. */
spAnimationState* spAnimationState_create (spAnimationStateData* data);
void spAnimationState_dispose (spAnimationState* self);

struct spTrackEntry;

/** Set the current animation. Any queued animations are cleared. */
spTrackEntry* spAnimationState_setAnimationByName (spAnimationState* self, int trackIndex, const(char)* animationName, int/*bool*/loop);

/// ditto
spTrackEntry* spAnimationState_setAnimation (spAnimationState* self, int trackIndex, spAnimation* animation, int/*bool*/loop);

/** Adds an animation to be played delay seconds after the current or last queued animation, taking into account any mix duration. */
spTrackEntry* spAnimationState_addAnimationByName (spAnimationState* self, int trackIndex, const(char)* animationName, int/*bool*/loop, float delay);

/// ditto
spTrackEntry* spAnimationState_addAnimation(spAnimationState* self, int trackIndex, spAnimation* animation, int/*bool*/loop, float delay);

void spAnimationState_update (spAnimationState* self, float delta);

void spAnimationState_apply (spAnimationState* self, spSkeleton* skeleton);
