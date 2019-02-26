/*
Takes all infantry units from _garCargo and assigns them as cargo of all vehicles in _garTransport
*/

#include "..\..\Garrison\garrison.hpp"

params ["_garTransport", "_garsCargo"];

if (_garsCargo isEqualType objNull) then
{
	_garsCargo = [_garsCargo];
};

//Some general variables
private _rarray = [];
private _rid = 0;

private _allVehicles = [_garTransport, T_VEH, -1] call gar_fnc_findUnits;
//diag_log format ["All transport vehicles: %1", _allVehicles];
private _allVehicleHandles = [];
{
	_allVehicleHandles pushBack ([_garTransport, _x] call gar_fnc_getUnitHandle);
} forEach _allVehicles;

//Get array of infantry units from the cargo garrison
private _allInfantryHandles = [];
{
	private _garCargo = _x;
	{
		_allInfantryHandles pushBack ([_garCargo, _x] call gar_fnc_getUnitHandle);
	} forEach (_garCargo call gar_fnc_getAllUnits);
} forEach _garsCargo;

//Get array of infantry units from transport garrison
{
	//If it's not a vehicle crew group
	if([_garTransport, _x] call gar_fnc_getGroupType != G_GT_veh_non_static) then
	{
		{
			_allInfantryHandles pushBack ([_garTransport, _x] call gar_fnc_getUnitHandle);
		} forEach ([_garTransport, _x] call gar_fnc_getGroupAliveUnits);
	};
} forEach ([_garTransport] call gar_fnc_getAllGroups);

//diag_log format ["======= All infantry cargo: %1", _allInfantryHandles];
private _nCargoInfantry = count _allInfantryHandles;

private _nextInfID = 0;
for "_i" from ((count _allVehicles) - 1) to 0 step -1 do
{
	private _vehHandle = _allVehicleHandles select _i;
	//Check how many cargo seats this vehicle has
	private _fullCrew = _vehHandle call misc_fnc_getFullCrew;
	private _cargoTurrets = _fullCrew select 3;	
	private _nCargoSeats = _fullCrew select 4;
	private _nCargoTotal = (count _cargoTurrets) + _nCargoSeats;
	//Can this vehicle carry any cargo?
	if (_nCargoTotal > 0 && _nextInfID != _nCargoInfantry) then
	{
		//Create a new group of infantry for this vehicle
		//private _rid = [_garCargo, G_GT_idle, _rarray] call gar_fnc_addNewEmptyGroup;
		//waitUntil {[_gar, _rid] call gar_fnc_requestDone};
		//private _newGroupID = _rarray select 0;
		//Move infantry units inside the new group
		private _nCargoThisVehicle = 0; //how many inf has been assigned to this veh already
		//While we haven't assigned all the infantry and while there is still some place left in this vehicle
		while {_nextInfID != _nCargoInfantry && _nCargoThisVehicle < _nCargoTotal} do
		{
			//_rid = [_garCargo, _allCargoInfantry select _nextInfID, _newGroupID, false] call gar_fnc_joinGroup;
			//diag_log format ["Vehicle: %1   Vehicle handle: %2", _allVehicles select _i, _vehHandle];
			private _infHandle = _allInfantryHandles select _nextInfID;
			//diag_log format ["Assigning unit: %1 unit handle: %2", _unit, _infHandle];
			//First assign FFV turrets, then cargo seats
			unassignVehicle _infHandle;
			if (_nCargoThisVehicle < (count _cargoTurrets)) then
			{ _infHandle assignAsTurret [_vehHandle, _cargoTurrets select _nCargoThisVehicle]; } else
			{ _infHandle assignAsCargo _vehHandle; };
			//Increment counters
			_nextInfID = _nextInfID + 1;
			_nCargoThisVehicle = _nCargoThisVehicle + 1;
		};
	};
};

//Order all infantry units to get in?
