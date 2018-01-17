/*
Makes units of _groups walk around vehicles they are assigned to
*/

params ["_scriptObject", "_groups", ["_isAnybodyWatching", true]];

[_scriptObject, _thisScript, [], ""] call AI_fnc_registerScriptHandle;

if (count _groups == 0) exitWith {};

//sleep 4;

{
	_x setBehaviour "SAFE";
	_x setSpeedMode "LIMITED";
}foreach _groups;

private _units = [];
{
	_units append (units _x);
}foreach _groups;

doStop _units;

if(!_isAnybodyWatching) then //If just spawned, teleport them closer to vehicles
{
	{
		private _veh = assignedVehicle _x;
		if(!(_veh isEqualTO objNull)) then
		{
			_x setPos ((((getPos _veh) select [0, 2]) + [0]) vectorAdd [-8 + random 16, -8 + random 16, 0]);
		};
	} forEach _units;
};

private _unitsWalk = +_units;
{
	if(random 1 < 0.2) then //Some units will instantly board their vehicles
	{
		[_x] orderGetIn true;
		_unitsWalk = _unitsWalk - [_x];
	}
	else //Others will walk around their vehicles
	{
		private _veh = assignedVehicle _x;
		_x doMove ((((getPos _veh) select [0, 2]) + [0]) vectorAdd [-8 + random 16, -8 + random 16, 0]);
	};
} forEach _units;

//Others will walk around their vehicles
while {true} do
{
	private _manMove = selectRandom _unitsWalk;
	//{
		private _veh = assignedVehicle _manMove;
		if(!(_veh isEqualTo objNull)) then
		{
			_manMove doMove ((((getPos _veh) select [0, 2]) + [0]) vectorAdd [-8 + random 16, -8 + random 16, 0]); //Walk around his vehicle
		};
	//} forEach _unitsWalk;
	sleep (5+(random 5));
};
