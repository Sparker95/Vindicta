#include "..\OOP_Light\OOP_Light.h"

/*
Method: sendHelp
send help to a position

Parameters: _pos

_pos - position

Returns: nil
*/

params ["_target"];
private _pos = getPos _target;

private _allLocations = GETSV("Location", "all");
private _possibleLocations = [];
private _nearestDistPlace = 0;
private _nearestPlace = "";

countAvailableUnits = {
	params ["_loc"];

	private _garrison = CALLM0(_loc, "getGarrisonMilAA");
	if (_garrison isEqualTo "") then { _garrison = CALLM0(_loc, "getGarrisonMilitaryMain"); };
	if (_garrison isEqualTo "") exitWith { OOP_WARNING_1("No garrison found for location %1", _loc); 0 };

	private _countAllUnits = CALLM0(_garrison, "countAllUnits");
	private _getRequiredUnits = CALLM0(_garrison, "getRequiredCrew");
	private _minimumUnits = 0;
	{ _minimumUnits = _minimumUnits + _x; } forEach _getRequiredUnits;

	_countAllUnits - _minimumUnits
};

// Find locations within 5km with at least 5 available units to send
{
	private _locPos = CALLM0(_x, "getPos");
	private _dist = _pos distance _locPos;

	if (_dist < 5000) then {
		private _availableUnits = [_x] call countAvailableUnits;

		if ( _availableUnits > 5) then {
			_possibleLocations append [_x];
			private _locPos = CALLM0(_x, "getPos");
			private _dist = _pos distance _locPos;
			if (_nearestDistPlace > _dist || _nearestDistPlace == 0) then { _nearestDistPlace = _dist; _nearestPlace = _x; };
		};
	};
} forEach _allLocations;

OOP_DEBUG_1("_nearestPlace: %1", _nearestPlace);
OOP_DEBUG_1("_nearestDistPlace: %1", _nearestDistPlace);
if !(_nearestPlace isEqualTo "") then { OOP_DEBUG_1("_nearestDistPlaceAvailableUnits: %1", [_nearestPlace] call countAvailableUnits); }

// Do something with this Location _nearestPlace rdy to help
