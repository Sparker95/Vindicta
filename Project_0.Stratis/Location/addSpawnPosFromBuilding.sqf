#include "Location.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

// Class: Location
/*
Method: addSpawnPosFromBuilding
Adds spawn positions of this building to the location.

Parameters: _building

_building - the object handle of the building

Author: Sparker 03.08.2018
*/

params [["_thisObject", "", [""]], ["_building", objNull, [objNull]]];

private _class = typeOf _building;

//Pre-defined positions for static HMG and GMG in buildings. Check initBuildingTypes.sqf.
_bps = location_bp_HGM_GMG_high select { _class in (_x select 0)};
if(count _bps > 0) then {
	//Add every position from the array to the spawn positions array
	{
		_bp = _x;
		_bdir = direction _object;
		if(count _bp == 2) then { //This position is defined by building position ID and direction
			_position = _building buildingPos (_bp select 0);
			private _args = [T_PL_HMG_GMG_high, [GROUP_TYPE_IDLE, GROUP_TYPE_VEH_STATIC], _position, _bdir + (_bp select 1), _building]; // [["_unitTypes", [], [[]]], ["_groupTypes", [], [[]]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_building", objNull, [objNull]] ];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
			//diag_log format ["Addes HMG position: ID: %1", _bp select 0];
		} else { //This position is defined by offset in cylindrical coordinates
			_position = (getPosATL _building) vectorAdd [(_bp select 0)*(sin (_bdir + (_bp select 1))), (_bp select 0)*(cos (_bdir + (_bp select 1))), _bp select 2];
			private _args = [T_PL_HMG_GMG_high, [GROUP_TYPE_IDLE, GROUP_TYPE_VEH_STATIC], _position, _bdir + (_bp select 3), _building]; // [["_unitTypes", [], [[]]], ["_groupTypes", [], [[]]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_building", objNull, [objNull]] ];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
			//diag_log format ["Addes HMG position: %1", _bp];
		};
	} forEach ((_bps select 0) select 1);
};

//Pre-defined positions for sentries inside buildings
_bps = location_bp_sentry select { _class in (_x select 0)};
if(count _bps > 0) then {
	//Add every position from the array to the spawn positions array
	{
		_bp = _x;
		_bdir = direction _object;
		if(count _bp == 2) then {//This position is defined by building position ID and direction
			_position = _building buildingPos (_bp select 0);
			private _args = [T_PL_inf_main, [GROUP_TYPE_BUILDING_SENTRY], _position, _bdir + (_bp select 1), _building]; // [["_unitTypes", [], [[]]], ["_groupTypes", [], [[]]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_building", objNull, [objNull]] ];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
		} else { //This position is defined by offset in cylindrical coordinates
			_position = (getPosATL _building) vectorAdd [(_bp select 0)*(sin (_bdir + (_bp select 1))), (_bp select 0)*(cos (_bdir + (_bp select 1))), _bp select 2];
			private _args = [T_PL_inf_main, [GROUP_TYPE_BUILDING_SENTRY], _position, _bdir + (_bp select 3), _building]; // [["_unitTypes", [], [[]]], ["_groupTypes", [], [[]]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_building", objNull, [objNull]] ];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
		};
	} forEach ((_bps select 0) select 1);
};