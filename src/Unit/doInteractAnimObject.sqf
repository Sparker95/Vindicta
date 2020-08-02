#include "..\common.h"
#include "..\Unit\Unit.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

/*
Makes this unit play an animation with an animObject
*/

params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_dir"), P_STRING("_animation"), P_STRING("_animationOut") ];

private _data = T_GETV("data");
private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
_objectHandle switchMove _animation;
_objectHandle disableAI "MOVE";
_objectHandle disableAI "ANIM";
_objectHandle setPos _pos;
_objectHandle setDir _dir;
true // Animation successfull
