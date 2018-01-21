/*
This is the move task script.

Parameters:
	_to - the task object
	
Task parameters:
[_dest]
_dest - the destination. It may be one of several types:
	ARRAY - destination position [x, y, z]
	OBJECT - destination location

Success conditions:
	Depending on the type of _dest, conditions are different.
	ARRAY - leader must be inside the radius
	Location OBJECT - leader must be inside the location territory
*/

params ["_to"]; //Task object

private _gar = _to getVariable "AI_garrison";
private _taskParams = _to getVariable "AI_taskParams";
_taskParams params ["_dest"];


/*
Decide which transport behaviour script to use:
	- pure infantry script			- if there is only infantry and no vehicles
	- land convoy script			- if there are only land vehicles
	- helicopter transport script	- if there are >0 helicopters
	- airplane transport script		- if there are >0 airplanes
	- boat convoy script			- if there are >0 boats
*/

private _allUnits = _gar call gar_fnc_getAllUnits;
private _allUnitHandles = [];
private _transportType = 0;
private _countMen = 0;
for "_i" from 0 to ((count _allUnits) - 1) do
{
	private _unitData = _allUnits select _i;
	private _unitHandle = [_gar, _unitData] call gar_fnc_getUnitHandle;
	if(_unitHandle isKindOf "Man") then {_countMen = _countMen + 1;};
	if(_unitHandle isKindOf "LandVehicle") exitWith {_transportType = 1;};
	if(_unitHandle isKindOf "Helicopter") exitWith {_transportType = 2;};
	if(_unitHandle isKindOf "Plane") exitWith {_transportType = 3;};
	if(_unitHandle isKindOf "Ship") exitWith {_transportType = 4;};
};
if (_countMen > 0 && _transportType == 0) then //Only infantry
{
	diag_log format ["fn_move: task: %1, detected move behaviour: INFANTRY", _to getVariable "AI_name"];
	
}
else
{
	switch (_transportType) do
	{
		case 1: //A land convoy
		{
			//private _state = "MOUNT";
			private _hScript = _to call AI_fnc_task_move_landConvoy;
			_to setVariable ["AI_hScript", _hScript, false];
		};
	};
};

//Read the array of cargo garrisons this garrison has to transport
private _cargoGarrisons = _gar call gar_fnc_getCargoGarrisons;
private _cargoGroupIDs = [];
for "_i" from 0 to ((count _cargoGarrisons) - 1) do
{
	private _groupIDs = [];
	private _gar0 = _cargoGarrisons select _i;
	
};
