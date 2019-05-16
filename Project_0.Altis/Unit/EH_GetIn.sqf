#define OOP_ERROR
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "Unit.hpp"

/*
Triggers when a unit enters a vehicle.
*/

#define pr private

params ["_vehicle", "_role", "_unit", "_turret"];

// Is this object an instance of Unit class?
private _thisObject = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_vehicle]);
private _unitInf = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_unit]);

diag_log format ["[Unit::EH_GetIn] Info: _this: %1, _thisObject: %2, _unitInf: %3, typeOf _vehicle: %4", _this, _thisObject, _unitInf, typeof _vehicle];

if (_thisObject == "") exitWith {
	diag_log format ["[Unit::EH_GetIn] Error: vehicle doesn't have a Unit object!"];
};

if (_unitInf == "") exitWith {
	diag_log format ["[Unit::EH_GetIn] Error: unit doesn't have a Unit object!"];
};


pr _data = GETV(_thisObject, "data");
pr _garrison = _data select UNIT_DATA_ID_GARRISON;
if (_garrison != "") then {	// Sanity check
	pr _args = [_thisObject, _unitInf];
	CALLM2(_garrison, "postMethodAsync", "handleGetInVehicle", _args);
} else {
	diag_log format ["[Unit::EH_GetIn] Error: vehicle is not attached to a garrison: %1, %2", _thisObject, _data];
};