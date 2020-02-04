#include "..\OOP_Light\OOP_Light.h"

#define pr private

params ["_object"];

pr _unit = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_object]);
pr _side = CALLM0(_unit, "getSide");
systemchat format ["%1", _side];