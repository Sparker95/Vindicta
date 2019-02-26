/*
This function splits unified vehicle groups into separate groups.
*/

#define DEBUG

params ["_gar"];

//Find vehicle groups
private _allVehGroupIDs = [_gar, G_GT_veh_non_static] call gar_fnc_findGroups;
#ifdef DEBUG
diag_log format ["fn_splitVehicleGroups: found vehicle groups: %1", _allVehGroupIDs];
#endif
//Find groups with more than one vehicle
for "_i" from 0 to ((count _allVehGroupIDs) - 1) do {
	private _gID = _allVehGroupIDs select _i;
	#ifdef DEBUG
	diag_log format ["fn_splitVehicleGroups: checking vehicle group: %1", _allVehGroupIDs];
	#endif
	//Count vehicles in group
	private _groupUnits = [_gar, _gID] call gar_fnc_getGroupAliveUnits;
	private _groupVehicles = _groupUnits select {_x select 0 == T_VEH};
	#ifdef DEBUG
	diag_log format ["fn_splitVehicleGroups: vehicle units in group: %1", _groupVehicles];
	#endif
	if ((count _groupVehicles) > 1) then {
		//Move all vehicles except the first one into a separate group
		for "_i" from 1 to ((count _groupVehicles) - 1) do {
			private _vehUnitData = _groupVehicles select _i;
			private _vehicleCrew = [_gar, _vehUnitData] call gar_fnc_getVehicleCrew;
			#ifdef DEBUG
			diag_log format ["fn_splitVehicleGroups: moving vehicle %1 to a new group, crew: %2", _vehUnitData, _vehicleCrew];
			#endif
			
			//Create a new group for the vehicle and its crew
			private _rarray = [];
			private _rid = [_gar, G_GT_veh_non_static, _rarray] call gar_fnc_addNewEmptyGroup;
			waitUntil {[_gar, _rid] call gar_fnc_requestDone};
			private _newGroupID = _rarray select 0;
			
			//Move vehicle and its crew to the new group
			_rid = [_gar, [_vehUnitData] + _vehicleCrew, _newGroupID, false] call gar_fnc_joinGroup;
			waitUntil {[_gar, _rid] call gar_fnc_requestDone};
		};
	};
};