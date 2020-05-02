#include "..\common.h"
#include "..\Unit\Unit.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

/*
This is meant for stopping an AnimObject animation. It also lets a unit walk away from its current position.
*/

params [P_THISOBJECT, P_STRING("_animationOut"), P_NUMBER("_walkDir"), P_NUMBER("_walkDistance")];
private _data = T_GETV("data");
private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
_objectHandle enableAI "ALL";
_objectHandle switchMove _animationOut;
if (_walkDistance > 0) then {
	_objectHandle doMove ((getPos _objectHandle) getPos [_walkDistance, (direction _objectHandle) + _walkDir]);
};
