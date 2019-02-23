#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"


// Class: Location
/*
Method: (static)createAllFromEditor
Checks the game world for predefined game objects and markers and creates locations from them.

Author: Sparker 28.07.2018
*/


params [ ["_thisClass", "", [""]] ];

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

		// Hide this marker a bit
		_x setMarkerAlpha 0.3;

		// Check marker side in its name
		if(_x find "_ind" > 0) then	{
			_side = INDEPENDENT;
			_template = tAAF;
		} else {
			if(_x find "_east" > 0) then {
				_side = EAST;
				_template = tCSAT;
			};
		};

		// Create a new location
		private _args = [_mrkPos];
		private _loc = NEW_PUBLIC("Location", _args);

		// Initialize the new location
		CALL_METHOD(_loc, "initFromEditor", [_mrk]);

		// Set debug name
		private _debugName = format ["fromMarker_%1", _mrk];
		CALL_METHOD(_loc, "setDebugName", [_debugName]);

		// Set type
		SET_VAR_PUBLIC(_loc, "type", [_type]);

		// Output the capacity of this garrison
		// Infantry capacity
		private _args = [T_INF, [GROUP_TYPE_IDLE]];
		private _cInf = CALL_METHOD(_loc, "getUnitCapacity", _args);

		// Wheeled and tracked vehicle capacity
		_args = [T_PL_tracked_wheeled, GROUP_TYPE_ALL];
		private _cVehGround = CALL_METHOD(_loc, "getUnitCapacity", _args);

		// Static HMG capacity
		private _args = [T_PL_HMG_GMG_high, GROUP_TYPE_ALL];
		private _cHMGGMG = CALL_METHOD(_loc, "getUnitCapacity", _args);

		// Building sentry capacity
		private _args = [T_INF, [GROUP_TYPE_BUILDING_SENTRY]];
		private _cBuildingSentry = CALL_METHOD(_loc, "getUnitCapacity", _args);

		diag_log format ["[Location::createAllFromEditor] Info: Location: %1, infantry capacity: %2, ground vehicle capacity: %3, HMG and GMG capacity: %4, building sentry capacity: %5",
			_debugName, _cInf, _cVehGround, _cHMGGMG, _cBuildingSentry];

		// Add the main garrison to this location
		private _garMilMain = NEW("Garrison", [_side]);
		CALL_METHOD(_loc, "setGarrisonMilitaryMain", [_garMilMain]);

		// Add default units to the garrison

		// ==== Add infantry ====
		private _addInfGroup = {
			params ["_template", "_gar", "_subcatID", "_capacity", ["_type", GROUP_TYPE_IDLE]];

			// Create an empty group
			private _side = CALL_METHOD(_gar, "getSide", []);
			_args = [_side, _type];
			private _newGroup = NEW("Group", _args);

			// Create units from template
			private _args = [_template, _subcatID];
			private _nAdded = CALL_METHOD(_newGroup, "createUnitsFromTemplate", _args);
			CALL_METHOD(_gar, "addGroup", [_newGroup]);

			// Return remaining capacity
			_capacity = _capacity - _nAdded;
			_capacity
		};

		// Adds a group with single vehicle and crew for it
		private _addVehGroup = {
			params ["_template", "_gar", "_catID", "_subcatID", "_classID"];
			private _side = CALL_METHOD(_gar, "getSide", []);
			private _args = [_side, GROUP_TYPE_VEH_NON_STATIC];
			private _newGroup = NEW("Group", _args);
			private _args = [_template, _catID, _subcatID, -1, _newGroup]; // ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]]
			private _newUnit = NEW("Unit", _args);
			// Create crew for the vehicle
			CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
			// Add the group to the garrison
			CALL_METHOD(_gar, "addGroup", [_newGroup]);
		};

		// Add patrol groups

		private _i = 0;
		while {_cInf > 0 && _i < 3} do {
			_cInf = [_template, _garMilMain, T_GROUP_inf_sentry, _cInf, GROUP_TYPE_PATROL] call _addInfGroup;
			_i = _i + 1;
		};


		// Add default infantry groups

		private _i = 0;
		while {_cInf > 0 && _i < 666} do {
			_cInf = [_template, _garMilMain, T_GROUP_inf_rifle_squad, _cInf, GROUP_TYPE_IDLE] call _addInfGroup;
			_i = _i + 1;
		};


		// Add building sentries
		/*
		if (_cBuildingSentry > 0) then {
			private _args = [_side, GROUP_TYPE_BUILDING_SENTRY];
			private _sentryGroup = NEW("Group", _args);
			while {_cBuildingSentry > 0} do {
				private _variants = [T_INF_marksman, T_INF_marksman, T_INF_LMG, T_INF_LAT, T_INF_LMG];
				private _args = [_template, 0, selectrandom _variants, -1, _sentryGroup];
				private _newUnit = NEW("Unit", _args);
				_cBuildingSentry = _cBuildingSentry - 1;
			};
			CALL_METHOD(_garMilMain, "addGroup", [_sentryGroup]);
		};
		*/


		// Add default vehicles
		// Some trucks
		private _i = 0;
		while {_cVehGround > 0 && _i < 2} do {
			private _args = [_template, T_VEH, T_VEH_truck_inf, -1, ""];
			private _newUnit = NEW("Unit", _args);
			if (CALL_METHOD(_newUnit, "isValid", [])) then {
				CALL_METHOD(_garMilMain, "addUnit", [_newUnit]);
				_cVehGround = _cVehGround - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};

		// Some MRAPs
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_MRAP_HMG, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_MRAP_GMG, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};

		// Some APCs and IFVs
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_APC, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_IFV, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};

		// Some tanks
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_MBT, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};

		// Static weapons
		if (_cHMGGMG > 0) then {
			private _args = [_side, GROUP_TYPE_VEH_STATIC];
			private _staticGroup = NEW("Group", _args);
			while {_cHMGGMG > 0} do {
				private _variants = [T_VEH_stat_HMG_high, T_VEH_stat_GMG_high];
				private _args = [_template, T_VEH, selectrandom _variants, -1, _staticGroup];
				private _newUnit = NEW("Unit", _args);
				CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
				_cHMGGMG = _cHMGGMG - 1;
			};
			CALL_METHOD(_garMilMain, "addGroup", [_staticGroup]);
		};
	};


} forEach allMapMarkers;
