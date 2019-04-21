#define OOP_DEBUG
#define OOP_WARNING
#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

// Class: Location
/*
Method: (static)createAllFromEditor
Checks the game world for predefined game objects and markers and creates locations from them.
This use custom Project_0 Module Location.
*/
params [ ["_thisClass", "", [""]] ];

private _radius = 0;
private _loc = objNull;
private _locations = entities "Project_0_LocationSector";

//#define ADD_TRUCKS
#define ADD_UNARMED_MRAPS
//#define ADD_ARMED_MRAPS
//#define ADD_TANKS
//#define ADD_APCS_IFVS

{
	private _locSector = _x;
	private _locSectorPos = getPos _locSector;
	private _locName = _locSector getVariable ["Name", ""];
	private _locType = _locSector getVariable ["Type", ""];
	private _locSide = _locSector getVariable ["Side", ""];
	private _locCapacityInf = _locSector getVariable ["CapacityInfantry", ""];
	private _locCivPresUnitCount = _locSector getVariable ["CivilianPresence_UnitCount", ""];
	private _template = "";
	private _side = "";

	if (_locType == "city") exitWith{};
	
	// TODO: use synced waypoints to help AIs
	// _waypoints = synchronizedObjects _locationSector;

	if (_locSide == "east") then { 
		_side = INDEPENDENT; //EAST; 
		_template = tAAF; //tCSAT; 
	};
	if (_locSide == "west") then { 
		_side = WEST; 
		_template = tGUERILLA; 
	};
	if (_locSide == "independant") then { 
		_side = INDEPENDENT; 
		_template = tAAF; 
	};

	if (_locSide == "none") exitWith { OOP_WARNING_1("No side for Location Sector %1", _locationSector); };
	
	// Create a new location
	private _args = [_locSectorPos];
	private _loc = NEW_PUBLIC("Location", _args);
	CALL_METHOD(_loc, "initFromEditor", [_locSector]);
	CALL_METHOD(_loc, "setDebugName", [_locName]);
	CALL_METHOD(_loc, "setSide", [_side]);
	CALL_METHOD(_loc, "setType", [_locType]);
	CALL_METHOD(_loc, "setCapacityInf", [_locCapacityInf]);

	// Output the capacity of this garrison
	// Infantry capacity
	private _args = [T_INF, [GROUP_TYPE_IDLE]];
	private _cInf = CALL_METHOD(_loc, "getUnitCapacity", _args);
	//if (_cInf < 5) then {_cInf = 5};
	_cInf = if(_locName == "Altis Airfield") then {60} else {2}; // _locCapacityInf*2;
	//_cInf = 5 + random 5;

	// // Wheeled and tracked vehicle capacity
	_args = [T_PL_tracked_wheeled, GROUP_TYPE_ALL];
	private _cVehGround = CALL_METHOD(_loc, "getUnitCapacity", _args);
	_cVehGround = if(_locName == "Altis Airfield") then {10} else {0};

	// Static HMG capacity
	private _args = [T_PL_HMG_GMG_high, GROUP_TYPE_ALL];
	private _cHMGGMG = CALL_METHOD(_loc, "getUnitCapacity", _args);

	// Building sentry capacity
	private _args = [T_INF, [GROUP_TYPE_BUILDING_SENTRY]];
	private _cBuildingSentry = CALL_METHOD(_loc, "getUnitCapacity", _args);

	// Add the main garrison to this location
	private _garMilMain = NEW("Garrison", [_side]);
	CALLM1(_garMilMain, "setLocation", _loc);
	CALLM1(_loc, "registerGarrison", _garMilMain);

	// Add default units to the garrison

	// // ==== Add infantry ====
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
	#ifdef ADD_SENTRY
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
	#endif


	// Add default vehicles
	// Some trucks
	private _i = 0;
	#ifdef ADD_TRUCKS
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
	#endif

	#ifdef ADD_UNARMED_MRAPS
	_i = 0;
	while {(_cVehGround > 0) && _i < 5} do  {
		private _args = [_template, T_VEH, T_VEH_MRAP_unarmed, -1, ""];
		private _newUnit = NEW("Unit", _args);
		if (CALL_METHOD(_newUnit, "isValid", [])) then {
			CALL_METHOD(_garMilMain, "addUnit", [_newUnit]);
			_cVehGround = _cVehGround - 1;
		} else {
			DELETE(_newUnit);
		};
		_i = _i + 1;
	};
	#endif
	
	#ifdef ADD_ARMED_MRAPS
	// Some MRAPs
	if (random 10 <= 5) then {
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_MRAP_HMG, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_MRAP_GMG, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};
	};
	#endif

	#ifdef ADD_APCS_IFVS
	// Some APCs and IFVs
	if (random 10 <= 3) then {
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_APC, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_IFV, -1] call _addVehGroup;
			_cVehGround = _cVehGround - 1;
		};
	};
	#endif

	#ifdef ADD_TANKS
	// Some tanks
	if (_cVehGround > 0) then {
		[_template, _garMilMain, T_VEH, T_VEH_MBT, -1] call _addVehGroup;
		_cVehGround = _cVehGround - 1;
	};
	#endif

	#ifdef ADD_STATICS
	// Static weapons
	if (_cHMGGMG > 0) then {
		// temp cap of amount of static guns
		_cHMGGMG = (4 + random 5) min _cHMGGMG;
		
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
	#endif

} forEach _locations;
