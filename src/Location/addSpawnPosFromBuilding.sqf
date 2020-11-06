#include "Location.hpp"
#include "..\common.h"
#include "..\Group\Group.hpp"

// Class: Location
/*
Method: addSpawnPosFromBuilding
Adds spawn positions of this building to the location.

Parameters: _building

_building - the object handle of the building

Author: Sparker 03.08.2018
*/

params [P_THISOBJECT, P_OBJECT("_building")];

private _class = typeOf _building;

private _type = T_GETV("type");
//if (_type == LOCATION_TYPE_CITY) exitWith {}; // We must be truly insane if we want to process all buildings in a city

_calculateOffsetAndDir = {
	params ["_bpArray", "_building"];
	_bpArray params ["_dist", "_angle", "_height", "_objectDirOffset"];
	private _bDir = direction _building;
	private _dirOut = _bDir + _objectDirOffset;
	private _buildingPosATL = getPosATL _building;
	private _offset = [_dist*(sin (_angle + _bDir)), _dist*(cos (_angle + _bDir)), _height];
	private _posATL = _buildingPosATL vectorAdd _offset;
	private _zCorrection = (getTerrainHeightASL _buildingPosATL) - (getTerrainHeightASL _posATL);
	_posATL set [2, (_posATL#2) + _zCorrection];

	#ifndef RELEASE_BUILD
	private _arrow = "Sign_Arrow_Direction_Cyan_F" createVehicle _posATL;
	_arrow setPosATL _posATL;
	_arrow setDir _dirOut;
	#endif

	[_posATL, _dirOut];
};

//Pre-defined positions for static HMG and GMG in buildings. Check initBuildingTypes.sqf.
private _bps = location_bp_HGM_GMG_high getVariable _class;
if(!isNil "_bps") then {
	//Add every position from the array to the spawn positions array
	{
		_bp = _x;
		_bdir = direction _building;
		if(count _bp >= 3) then { //This position is defined by offset in cylindrical coordinates
			([_bp, _building] call _calculateOffsetAndDir) params ["_posATL", "_dir"];
			private _args = [T_PL_HMG_GMG_high, [GROUP_TYPE_INF, GROUP_TYPE_STATIC], _posATL, _dir, _building]; // [["_unitTypes", [], [[]]], ["_groupTypes", [], [[]]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_building", objNull, [objNull]] ];
			T_CALLM("addSpawnPos", _args);
			//diag_log format ["Addes HMG position: %1", _bp];
		};
	} forEach _bps;
};

//Pre-defined positions for boats near piers. Check initBuildingTypes.sqf.
private _bps = location_bp_Boats getVariable _class;
if(!isNil "_bps") then {
	//Add every position from the array to the spawn positions array
	{
		_bp = _x;
		_bdir = direction _building;
		if(count _bp >= 3) then { //This position is defined by offset in cylindrical coordinates
			([_bp, _building] call _calculateOffsetAndDir) params ["_posATL", "_dir"];
			if (surfaceIsWater _posATL) then {
				private _args = [[[T_VEH, T_VEH_boat_unarmed]], [GROUP_TYPE_ALL], _posATL, _dir, _building]; // [["_unitTypes", [], [[]]], ["_groupTypes", [], [[]]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_building", objNull, [objNull]] ];
				T_CALLM("addSpawnPos", _args);
				OOP_INFO_1("Added BOAT position: %1", _bp);
			} else {
				OOP_INFO_1("Cant add BOAT Pos - position on land: %1", _bp);
			};
		};
	} forEach _bps;
};

// Pre-defined positions for cargo boxes
_bps = location_bp_cargo_medium getVariable _class;

// We want to do this only for police stations.
// It's very annoying when cargo boxes spawn in some random house at outpost instead of pre-defined position.
if (!(isNil "_bps") && _type == LOCATION_TYPE_POLICE_STATION) then {
	{
		_bp = _x;
		_bdir = direction _building;
		if(count _bp >= 3) then { //This position is defined by offset in cylindrical coordinates
			([_bp, _building] call _calculateOffsetAndDir) params ["_posATL", "_dir"];
			private _args = [T_PL_cargo_small_medium, [GROUP_TYPE_INF], _posATL, _dir, _building]; // [["_unitTypes", [], [[]]], ["_groupTypes", [], [[]]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_building", objNull, [objNull]] ];
			T_CALLM("addSpawnPos", _args);

			//diag_log format ["Addes cargo box position: %1", _bp];
		};

	} forEach _bps;
};