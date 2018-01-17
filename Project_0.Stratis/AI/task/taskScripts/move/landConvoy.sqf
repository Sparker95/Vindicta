/*
Some auxiliary functions needed for operation of landConvoy
*/

AI_fnc_landConvoy_getMaxSeparation =
{
	//Gets the maximum separation between vehicles in convoy
	params ["_vehGroupHandle"];
	//Get vehicles in formation order
	private _allVehicles = [];
	{
		_allVehicles pushBackUnique (vehicle _x);
	} forEach (formationMembers (leader _vehGroupHandle));
	//Get the max separation
	private _dMax = 0;
	private _c = count _allVehicles;
	for "_i" from 0 to (_c - 2) do
	{
		_d = (_allVehicles select _i) distance (_allVehicles select (_i + 1));
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