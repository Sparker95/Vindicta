#define OOP_DEBUG
#define OOP_WARNING
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
private _nearestPlacePos = "";
private _nearestPlace = "";
private _clusters = [];

call compile preprocessFileLineNumbers "Cluster\common.sqf";

// Find locations within 5km with at least 5 available units to send
{
	private _locPos = CALLM0(_x, "getPos");
	private _dist = _pos distance _locPos;
	OOP_DEBUG_1("_locPos: %1", _locPos);

	if (_dist < 5000) then {
		private _availableUnits = CALLM0(_x, "countAvailableUnits");

		if ( _availableUnits > 5) then {
			_possibleLocations append [_x];
			private _dist = _pos distance _locPos;
			if (_nearestDistPlace > _dist || _nearestDistPlace == 0) then { _nearestDistPlace = _dist; _nearestPlace = _x; _nearestPlacePos = _locPos; };
		};
	};
} forEach _allLocations;

OOP_DEBUG_1("_nearestPlace: %1", _nearestPlace);
OOP_DEBUG_1("_nearestPlacePos: %1", _nearestPlacePos);
OOP_DEBUG_1("_nearestDistPlace: %1", _nearestDistPlace);

// TODO: if no _nearestPlace check further ?
if (_nearestPlace == "") exitWith { OOP_WARNING_1("No Location found for sendHelpToPos %1", _pos); };


// Send help
