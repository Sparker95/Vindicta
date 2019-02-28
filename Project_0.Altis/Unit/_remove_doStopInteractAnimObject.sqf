#include "..\OOP_Light\OOP_Light.h"
#include "..\Unit\Unit.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

params [["_thisObject", "", [""]], ["_animationOut", "", [""]], ["_walkDir", 0, [0]], ["_walkDistance", 0, [0]]];
private _data = GETV(_thisObject, "data");
private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
_objectHandle enableAI "ALL";
_objectHandle switchMove _animationOut;
if (_walkDistance > 0) then {
	_objectHandle doMove ((getPos _objectHandle) getPos [_walkDistance, (direction _objectHandle) + _walkDir]);
};
