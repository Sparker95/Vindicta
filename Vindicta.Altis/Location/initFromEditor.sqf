#define OOP_INFO
#define OOP_DEBUG
#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

// Class: Location
/*
Method: initFromEditor
Initializes the location parameters from editor-placed objects.

Parameters: _locationSector

_locationSector - Object -> Location Module

Returns: nil

Author: Sparker 28.07.2018
*/

params [P_THISOBJECT, "_locationSector"];

// Setup location's border from location module properties
private _locSize = _locationSector getVariable ["objectArea", ""];

private _border = if (_locSize select 0 == _locSize select 1) then { // if width==height, make it a circle
	private _radius = _locSize select 0;
	["circle", _radius]
} else { // If width!=height, make border a rectangle
	private _dir = direction _locationSector;
	["rectangle", [_locSize select 0, _locSize select 1, _dir] ]
};
T_CALLM("setBorder", _border);

T_CALLM0("findAllObjects");