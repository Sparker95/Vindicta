/*
Some auxiliary functions needed for operation of landConvoy
*/

AI_fnc_landConvoy_getMaxSeparation =
{
	//Gets the maximum separation between vehicles in convoy
	params ["_allVehicles", "_vehLead"];
	//diag_log format ["All vehicles: %1", _allVehicles];
	//diag_log format ["Lead vehicle: %1", _vehLead];
	private _vehArraySort = [];
	{
		_vehArraySort pushBack [_x distance _vehLead, _x];
	} forEach _allVehicles;
	//diag_log format ["Unsorted array: %1", _vehArraySort];
	_vehArraySort sort true; //Ascending
	//diag_log format ["Sorted array: %1", _vehArraySort];
	//Get the max separation
	private _dMax = 0;
	private _c = count _allVehicles;
	for "_i" from 0 to (_c - 2) do
	{
		_d = (_vehArraySort select _i select 1) distance (_vehArraySort select (_i + 1) select 1);
		if (_d > _dMax) then {_dMax = _d;};
	};
	_dMax
};

AI_fnc_landConvoy_allVehiclesHaveDrivers =
{
	//Checks if all the vehicles have alive drivers assigned
	private _vehArray = _this;
	private _return = true;
	for "_i" from 0 to ((count _vehArray) - 1) do
	{
		private _v = _vehArray select 0;
		private _d = assignedDriver _v;
		if (!(alive _d) || (isNull _d)) exitWith
		{
			_return = false;
		};
	};
	_return
};

AI_fnc_landConvoy_removeVehicles =
{
	params ["_garTransport", "_vehToRemove"];
	private _rid = 0;
	{
		private _unitData = _x call gar_fnc_getUnitData;
		_rid = [_garTransport, gGarbageGarrison, _unitData, -1] call gar_fnc_moveUnit;
	} forEach _vehToRemove;
	waitUntil {[_garTransport, _rid] call gar_fnc_requestDone;};
};

AI_fnc_landConvoy_arrived =
{
	//Checks if the convoy has arrived
	params ["_vehGroupHandle", "_compRadius", "_dest", "_destType"];
	private _arrived = false;
	if (_destType == 1) then
	{ //Destination's type is a location
		if ([_dest, leader _vehGroupHandle] call loc_fnc_insideBorder) then //Check if the convoy is at the territory of the location
		{ _arrived = true; };
	}
	else
	{ //Destination's type is coordinates
		if (((leader _vehGroupHandle) distance2D _dest) < _compRadius) then //Are we there yet??
		{ _arrived = true; };
	};
	_arrived
};