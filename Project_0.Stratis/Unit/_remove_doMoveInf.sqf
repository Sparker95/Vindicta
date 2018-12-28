#include "..\OOP_Light\OOP_Light.h"
#include "Unit.hpp"

params [["_thisObject", "", [""]], ["_destPos", [], [[]]]];
private _data = GETV(_thisObject, "data");
private _object = _data select UNIT_DATA_ID_OBJECT_HANDLE;
_object doMove _destPos;