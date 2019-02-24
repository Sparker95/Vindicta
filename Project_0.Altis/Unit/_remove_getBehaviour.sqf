#include "..\OOP_Light\OOP_Light.h"
#include "Unit.hpp"

params [["_thisObject", "", [""]]];
private _data = GETV(_thisObject, "data");
private _object = _data select UNIT_DATA_ID_OBJECT_HANDLE;
behaviour _object