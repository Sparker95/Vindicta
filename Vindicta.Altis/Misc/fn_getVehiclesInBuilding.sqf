/*
Function: misc_fnc_getVehiclesInBuilding

Returns vehicles inside a building. Can be quite computation heavy (100us for a few vehicles). Don't run too often.

Return value: array of objects
*/

params [ ["_b", objNull, [objNull]] ];

// Estimate radius of the building based on its bounding box
_bb = boundingBoxReal _b;
_sx = _bb#0#0; // Size x
_sy = _bb#0#1; // Size y
_r = sqrt (_sx*_sx + _sy*_sy);

// Get potential vehicles within radius
_no = nearestObjects [getPosASL _b, ["AllVehicles"], _r, true];

// Process potential vehicles within the radius
_no select {
	// Filter out class names we don't care about
	if (! (_x isKindOf "Man")) then {
		// Cast vertical rays to check if the vehicle is inside this building
		_posASL = getPosASL _x;
		_posASLStart = _posASL vectorAdd [0, 0, 100];
		_posASLEnd = _posASL vectorAdd [0, 0, -100];
		_objs = (lineIntersectsObjs [_posASLStart, _posASLEnd, objNull, objNull, false, 16 + 32]) select { _x == _b };
		if (count _objs > 0) then {
		diag_log format ["%1 is in the house!", _x];
		true
		} else {
		false
		};
	} else {
		false
	};
};