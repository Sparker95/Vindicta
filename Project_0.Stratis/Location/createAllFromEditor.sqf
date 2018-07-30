/*
Checks the game world for predefined game objects and markers and creates locations from them.

Author: Sparker 28.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

private _radius = 0;
private _loc = objNull;
{
	private _mrk = _x;
	private _mrkPos = getMarkerPos _mrk;
	private _type = "";
	
	// Check marker name for location type
	call {
		if(_x find "base" == 0) exitWith {
			_type = "base";
		};
		if(_x find "outpost" == 0) exitWith {
			_type = "outpost";
		};
	};
	
	// Did we find a location marker?
	if(!(_type isEqualTo "")) then {
		private _side = WEST;
		private _template = tNATO;
		
		// Check marker side in its name
		if(_x find "_ind" > 0) then	{
			_side = INDEPENDENT;
			_template = tIND;
		} else	{
			if(_x find "_east" > 0) then {
				_side = EAST;
				_template = tCSAT;
			};
		};
		
		// Create a new location
		private _args = [_mrkPos];
		private _loc = NEW("Location", _args);
		
		// Initialize the new location
		CALL_METHOD(_loc, "initFromEditor", [_mrk]);
		
		// Set debug name
		private _debugName = format ["fromMarker_%1", _mrk];
		CALL_METHOD(_loc, "setDebugName", [_debugName]);
		
		// Output the capacity of this garrison
		// Infantry capacity
		private _args = [T_INF, [GROUP_TYPE_IDLE]];
		private _cInf = CALL_METHOD(_loc, "getunitCapacity", _args);
		
		// Wheeled and tracked vehicle capacity
		_args = [T_PL_tracked_wheeled, GROUP_TYPE_ALL];
		private _cVehGround = CALL_METHOD(_loc, "getUnitCapacity", _args);
		
		// Static HMG capacity
		private _args = [T_PL_HMG_GMG_high, GROUP_TYPE_ALL];
		private _cHMGGMG = CALL_METHOD(_loc, "getUnitCapacity", _args);
		diag_log format ["--- Location: %1, infantry capacity: %2, ground vehicle capacity: %3, HMG and GMG capacity: %4",
			_debugName, _cInf, _cVehGround, _cHMGGMG];
		
		// Add the main garrison to this location
		private _garMilMain = NEW("Garrison", [_side]);
		
		// Add default units to the garrison
		
		// ==== Add infantry ====
		private _addInfGroup = {
			params ["_gar", "_subcatID", "_capacity"];
			private _args = [_template, _subcatID];
			private _newGroup = NEW("Group", [_side]);
			private _nAdded = CALL_METHOD(_newGroup, "createUnitsFromTemplate", _args);
			CALL_METHOD(_gar, "addGroup", [_newGroup]);
			_capacity = _capacity - _nAdded;
			_capacity
		};
		
		// Add sentry infantry groups
		private _i = 0;
		while {_cInf > 0 && _i < 3} do {
			_cInf = [_garMilMain, T_GROUP_inf_sentry, _cInf] call _addInfGroup;			
			_i = _i + 1;
		};
		
		// Add default infantry groups
		private _i = 0;
		while {_cInf > 0 && _i < 2} do {
			_cInf = [_garMilMain, T_GROUP_inf_rifle_squad, _cInf] call _addInfGroup;			
			_i = _i + 1;
		};
		
	};
} forEach allMapMarkers;