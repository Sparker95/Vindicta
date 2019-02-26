#include "..\OOP_Light\OOP_Light.h"
#include "..\Unit\Unit.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

params [["_thisObject", "", [""]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_animation", "", [""]], ["_animationOut", "", [""]] ];

private _data = GETV(_thisObject, "data");
private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
_objectHandle switchMove _animation;
_objectHandle disableAI "MOVE";
_objectHandle disableAI "ANIM";
_objectHandle setPos _pos;
_objectHandle setDir _dir;
true // Animation successfull
