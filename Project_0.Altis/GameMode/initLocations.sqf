#include "..\common.hpp"

// Class: GameModeBase
/*
Method: initLocations
Checks the game world for predefined game objects and markers and creates locations from them.
This use custom Project_0 Module Location.
*/
params [P_THISOBJECT];

private _radius = 0;
private _loc = objNull;
private _locations = entities "Project_0_LocationSector";

// 						S E T U P   M O D E 
// Valid values:
//		random - Randomly alternate between large and small garrisons (1 large per 5 small)
//		default - Fill to spawn capacity
//		bases - Only garrison bases, fully populate them. AI will spread out from here.
//		sparker - Personal testing profile
//		bill - Personal testing profile
// gSetupMode = "bases"; 

#define ADD_TRUCKS
#define ADD_UNARMED_MRAPS
//#define ADD_ARMED_MRAPS
//#define ADD_TANKS
//#define ADD_APCS_IFVS
#define ADD_STATICS


// // ==== Add infantry ====
fnc_addInfGroup = {
	params ["_template", "_gar", "_subcatID", "_capacity", ["_type", GROUP_TYPE_IDLE]];

	// Create an empty group
	private _side = CALL_METHOD(_gar, "getSide", []);
	private _newGroup = NEW("Group", [_side ARG _type]);

	// Create units from template
	private _nAdded = CALL_METHOD(_newGroup, "createUnitsFromTemplate", [_template ARG _subcatID]);
	CALL_METHOD(_gar, "addGroup", [_newGroup]);

	// Return remaining capacity
	_capacity = _capacity - _nAdded;
	_capacity
};

// Adds a group with single vehicle and crew for it
fnc_addVehGroup = {
	params ["_template", "_gar", "_catID", "_subcatID", "_classID"];
	private _side = CALL_METHOD(_gar, "getSide", []);
	private _newGroup = NEW("Group", [_side]+[GROUP_TYPE_VEH_NON_STATIC]);
	private _newUnit = NEW("Unit", [_template]+[_catID]+[_subcatID]+[-1]+[_newGroup]);
	// Create crew for the vehicle
	CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
	// Add the group to the garrison
	CALL_METHOD(_gar, "addGroup", [_newGroup]);
};

{
	private _locSector = _x;
	private _locSectorPos = getPos _locSector;
	private _locName = _locSector getVariable ["Name", ""];
	private _locType = _locSector getVariable ["Type", ""];
	private _locSide = _locSector getVariable ["Side", ""];
	private _locCapacityInf = _locSector getVariable ["CapacityInfantry", ""];
	private _locCivPresUnitCount = _locSector getVariable ["CivPresUnitCount", ""];
	private _template = "";
	private _side = "";

	if (_locType == "city") exitWith{};

	OOP_DEBUG_1("_locName %1", _locName);
	OOP_DEBUG_1("_locCapacityInf %1", _locCapacityInf);
	OOP_DEBUG_1("_locCivPresUnitCount %1", _locCivPresUnitCount);
	

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
	private _loc = NEW_PUBLIC("Location", [_locSectorPos]);
	CALL_METHOD(_loc, "initFromEditor", [_locSector]);
	CALL_METHOD(_loc, "setDebugName", [_locName]);
	CALL_METHOD(_loc, "setSide", [_side]);
	CALL_METHOD(_loc, "setType", [_locType]);
	CALL_METHOD(_loc, "setCapacityInf", [_locCapacityInf]);

	// Output the capacity of this garrison
	// Infantry capacity
	private _cInf = 0;
	// Wheeled and tracked vehicle capacity
	private _cVehGround = 0;
	// Static HMG capacity
	private _cHMGGMG = 0;
	// Building sentry capacity
	private _cBuildingSentry = 0;

	T_CALLM("getLocationInitialForces", [_loc]) params ["_cInf", "_cVehGround", "_cHMGGMG", "_cBuildingSentry"];

	// switch(gSetupMode) do {
	// 	case "bill": { 
	// 		_cInf = if(_locName == "Altis Airfield") then {60} else {2};
	// 		_cVehGround = if(_locName == "Altis Airfield") then {10} else {0};
	// 	};
	// 	case "sparker": {
	// 		_cInf = 12;
	// 		_cVehGround = 4;
	// 	};
	// 	case "random": {
	// 		if(random 5 <= 1) then {
	// 			_cInf = 60;
	// 			_cVehGround = 20;
	// 		} else {
	// 			_cInf = 10;
	// 			_cVehGround = 2;
	// 		}
	// 	};
	// 	case "bases": {
	// 		if(_locType == "base") then {
	// 			_cInf = CALL_METHOD(_loc, "getUnitCapacity", [T_INF]+[[GROUP_TYPE_IDLE]]);
	// 			_cVehGround = CALL_METHOD(_loc, "getUnitCapacity", [T_PL_tracked_wheeled]+[GROUP_TYPE_ALL]);
	// 			_cHMGGMG = CALL_METHOD(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high]+[GROUP_TYPE_ALL]);
	// 			_cBuildingSentry = CALL_METHOD(_loc, "getUnitCapacity", [T_INF]+[[GROUP_TYPE_BUILDING_SENTRY]]);
	// 			[_loc, _side, _cInf, _template] spawn {
	// 				params ["_loc", "_side", "_targetCInf", "_template"];
	// 				while{true} do {
	// 					sleep 120;
	// 					private _unitCount = CALLM(_loc, "countAvailableUnits", [_side]);
	// 					if(_unitCount >= 6 and _unitCount < _targetCInf) then {
	// 						private _garrisons = CALLM(_loc, "getGarrisons", [_side]);
	// 						private _garrison = _garrisons#0;
	// 						private _remaining = _targetCInf - _unitCount;
	// 						systemChat format["Spawning %1 units at %2", _remaining, _loc];
	// 						while {_remaining > 0} do {
	// 							private _args = [_template, _garrison, T_GROUP_inf_sentry, _remaining, GROUP_TYPE_PATROL];
	// 							_remaining = CALLM2(_garrison, "postMethodSync", fnc_addInfGroup, _args);
	// 							//[_template, _garrison, T_GROUP_inf_sentry, _remaining, GROUP_TYPE_PATROL] call fnc_addInfGroup;
	// 						};
	// 					};
	// 				};
	// 		 	};
	// 		};
	// 		private _cmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
	// 		if(!IS_NULL_OBJECT(_cmdr)) then {
	// 			CALLM(_cmdr, "registerLocation", [_loc]);
	// 		};
	// 	};
	// 	default {
	// 		_cInf = CALL_METHOD(_loc, "getUnitCapacity", [T_INF]+[[GROUP_TYPE_IDLE]]);
	// 		_cVehGround = CALL_METHOD(_loc, "getUnitCapacity", [T_PL_tracked_wheeled]+[GROUP_TYPE_ALL]);
	// 		_cHMGGMG = CALL_METHOD(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high]+[GROUP_TYPE_ALL]);
	// 		_cBuildingSentry = CALL_METHOD(_loc, "getUnitCapacity", [T_INF]+[[GROUP_TYPE_BUILDING_SENTRY]]);
	// 	};
	// };

	if(_cInf > 0) then {
		// Add the main garrison to this location
		private _garMilMain = NEW("Garrison", [_side]);
		CALLM1(_garMilMain, "setLocation", _loc);
		CALLM1(_loc, "registerGarrison", _garMilMain);

		// Add default units to the garrison

		// Add patrol groups
		private _i = 0;
		while {/*_cInf > 0 &&*/ _i < 3} do {
			_cInf = [_template, _garMilMain, T_GROUP_inf_sentry, _cInf, GROUP_TYPE_PATROL] call fnc_addInfGroup;
			_i = _i + 1;
		};

		// Add default infantry groups
		private _i = 0;
		
		//while {_cInf > 0 && _i < 1} do {
		while {_cInf > 0} do {
			_cInf = [_template, _garMilMain, T_GROUP_inf_rifle_squad, _cInf, GROUP_TYPE_IDLE] call fnc_addInfGroup;
			_i = _i + 1;
		};

		// Add building sentries
		#ifdef ADD_SENTRY
		if (_cBuildingSentry > 0) then {
			private _sentryGroup = NEW("Group", [_side]+[GROUP_TYPE_BUILDING_SENTRY]);
			while {_cBuildingSentry > 0} do {
				private _variants = [T_INF_marksman, T_INF_marksman, T_INF_LMG, T_INF_LAT, T_INF_LMG];
				private _newUnit = NEW("Unit", [_template]+[0]+[selectrandom _variants]+[-1]+[_sentryGroup]);
				_cBuildingSentry = _cBuildingSentry - 1;
			};
			CALL_METHOD(_garMilMain, "addGroup", [_sentryGroup]);
		};
		#endif


		// Add default vehicles
		// Some trucks
		private _i = 0;
		#ifdef ADD_TRUCKS
		while {_cVehGround > 0 && _i < 3} do {
			private _newUnit = NEW("Unit", [_template]+[T_VEH]+[T_VEH_truck_inf]+[-1]+[""]);
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
		while {(_cVehGround > 0) && _i < 1} do  {
			private _newUnit = NEW("Unit", [_template]+[T_VEH]+[T_VEH_MRAP_unarmed]+[-1]+[""]);
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
				[_template, _garMilMain, T_VEH, T_VEH_MRAP_HMG, -1] call fnc_addVehGroup;
				_cVehGround = _cVehGround - 1;
			};
			if (_cVehGround > 0) then {
				[_template, _garMilMain, T_VEH, T_VEH_MRAP_GMG, -1] call fnc_addVehGroup;
				_cVehGround = _cVehGround - 1;
			};
		};
		#endif

		#ifdef ADD_APCS_IFVS
		// Some APCs and IFVs
		if (random 10 <= 3) then {
			if (_cVehGround > 0) then {
				[_template, _garMilMain, T_VEH, T_VEH_APC, -1] call fnc_addVehGroup;
				_cVehGround = _cVehGround - 1;
			};
			if (_cVehGround > 0) then {
				[_template, _garMilMain, T_VEH, T_VEH_IFV, -1] call fnc_addVehGroup;
				_cVehGround = _cVehGround - 1;
			};
		};
		#endif

		#ifdef ADD_TANKS
		// Some tanks
		if (_cVehGround > 0) then {
			[_template, _garMilMain, T_VEH, T_VEH_MBT, -1] call fnc_addVehGroup;
			_cVehGround = _cVehGround - 1;
		};
		#endif

		#ifdef ADD_STATICS
		// Static weapons
		if (_cHMGGMG > 0) then {
			// temp cap of amount of static guns
			_cHMGGMG = (4 + random 5) min _cHMGGMG;
			
			private _staticGroup = NEW("Group", [_side]+[GROUP_TYPE_VEH_STATIC]);
			while {_cHMGGMG > 0} do {
				private _variants = [T_VEH_stat_HMG_high, T_VEH_stat_GMG_high];
				private _newUnit = NEW("Unit", [_template]+[T_VEH]+[selectrandom _variants]+[-1]+[_staticGroup]);
				CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
				_cHMGGMG = _cHMGGMG - 1;
			};
			CALL_METHOD(_garMilMain, "addGroup", [_staticGroup]);
		};
		#endif
	};
} forEach _locations;
