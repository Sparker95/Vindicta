#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "Main.rpt"
#include "Unit.hpp"
#include "..\common.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\Group\Group.hpp"
#include "..\Garrison\Garrison.hpp"

/*
Class: Unit
A virtualized Unit is a man, vehicle or a drone (or a cargo box!) which can be spawned or not spawned.

Author: Sparker
10.06.2018
*/

#define SHOW_DELAY 10

#define pr private

Unit_fnc_EH_Killed = COMPILE_COMMON("Unit\EH_Killed.sqf");
Unit_fnc_EH_Respawn = COMPILE_COMMON("Unit\EH_Respawn.sqf");
Unit_fnc_EH_handleDamageInfantryACE = COMPILE_COMMON("Unit\EH_handleDamageInfantryACE.sqf");
Unit_fnc_EH_handleDamageInfantryStd = COMPILE_COMMON("Unit\EH_handleDamageInfantryStd.sqf");
Unit_fnc_EH_handleDamageVehicle = COMPILE_COMMON("Unit\EH_handleDamageVehicle.sqf");
Unit_fnc_EH_GetIn = COMPILE_COMMON("Unit\EH_GetIn.sqf");
Unit_fnc_EH_GetOut = COMPILE_COMMON("Unit\EH_GetOut.sqf");
Unit_fnc_EH_aceCargoLoaded = COMPILE_COMMON("Unit\EH_aceCargoLoaded.sqf");
Unit_fnc_EH_aceCargoUnloaded = COMPILE_COMMON("Unit\EH_aceCargoUnloaded.sqf");

// Check that ACE damage event handler is present and was not changed
// We need this to both have ACE damage handler and prevent bots from murdering themselves because they can not drive
if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {
	if (isNil "ace_medical_engine_fnc_handleDamage") then {
		diag_log "  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ";
		diag_log " ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !";
		diag_log "! ! ! Error: ACE function ace_medical_engine_fnc_handleDamage is not found. Did it change?  ! !";
		diag_log " ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !";
		diag_log "  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ";
	};
};

// Add CBA ACE event handlers
#ifndef _SQF_VM

// Cargo loading/unloading
if (isNil "Unit_aceCargoLoaded_EH" && isServer) then { // Only server needs this event
	Unit_aceCargoLoaded_EH = ["ace_cargoLoaded", 
	{
		_this call Unit_fnc_EH_aceCargoLoaded;
	}] call CBA_fnc_addEventHandler;
};
if (isNil "Unit_aceCargoUnloaded_EH" && isServer) then { // Only server needs this event
	Unit_aceCargoUnloaded_EH = ["ace_cargoUnloaded", 
	{
		_this call Unit_fnc_EH_aceCargoUnloaded;
	}] call CBA_fnc_addEventHandler;
};

// SetVehicleLock from ace
if (isNil "Unit_aceSetVehicleLock_EH") then {

	private _code = {
		// We want to run this after ACE event handler, so we wait for a frame
		[
		{
			params ["_veh", "_isLocked"];
			//diag_log format ["=== SetVehicleLock: %1 %2", _veh, _isLocked];
			private _lockNumber = [0, 3] select _isLocked;
			_veh lock _lockNumber;
		},
		_this, 0] call CBA_fnc_waitAndExecute;
	};

	Unit_aceSetVehicleLock_EH = ["ace_vehicleLock_setVehicleLock", _code] call CBA_fnc_addEventHandler;
};

if (isServer) then {
	// We use this instead of EH added to unit because this one works for non-local units too
	addMissionEventHandler ["EntityKilled", {call Unit_fnc_EH_Killed}];
};

#endif
FIX_LINE_NUMBERS()

#define OOP_CLASS_NAME Unit
CLASS("Unit", ["Storable" ARG "GOAP_Agent"])
	VARIABLE_ATTR("data", [ATTR_PRIVATE ARG ATTR_SAVE]);
	STATIC_VARIABLE("all");

	//                              N E W
	/*
	Method: new

	Parameters: _template, _catID, _subcatID, _classID, _group, _hO

	_template - the template array. Ignored if _hO is not null.
	_catID, _subcatID - category and subcategory of the unit
	_classID - ID of the class in the template array, or -1 to pick a random class name. Ignored if _hO is not null.
	_group - the group object the unit will be added to. Vehicles can be added without a group.
	_hO - object handle. If null, new unit wwill be created in despawned state. Otherwise new <Unit> object will be attached to this object handle.
	_gear - array with weapons to give to this unit, for format check Unit.hpp. Can be an empty array, then unit will have standard weapons from the config or loadout.
	*/

	METHOD(new)
		params [P_THISOBJECT, P_ARRAY("_template"), P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_NUMBER("_classID"), P_OOP_OBJECT("_group"), ["_hO", objNull], ["_gear", []]];

		OOP_INFO_0("NEW UNIT");

		// Check argument validity
		private _valid = false;
		if (isNull _ho) then {
			// Check template
			if(_classID == -1) then	{
				if(([_template, _catID, _subcatID, 0] call t_fnc_isValid)) then	{
					_valid = true;
				};
			}
			else {
				if(([_template, _catID, _subcatID, _classID] call t_fnc_isValid)) then {
					_valid = true;
				};
			};
		} else {
			_valid = true;
		};

		if (!_valid) exitWith { T_SETV("data", []);
			diag_log format ["[Unit::new] Error: created invalid unit: %1", _this];
			DUMP_CALLSTACK
		};

		// Check group
		if(_group == "" && _catID == T_INF && isNull _hO) exitWith { diag_log "[Unit] Error: men must be added with a group!";};

		// If a random class was requested to be added
		private _class = if (isNull _hO) then {
			[_template, _catID, _subcatID, _classID] call t_fnc_select
		} else {
			typeOf _hO
		};

		OOP_INFO_MSG("class = %1, _this = %2", [_class ARG _this]);

		// Check if the class is actually a custom loadout
		pr _loadout = "";
		if ([_class] call t_fnc_isLoadout) then {
			_loadout = _class;
			_class = _template # _catID # 0 # 0; // Default class name from the template
		};

		// Create the data array
		private _data = UNIT_DATA_DEFAULT;
		_data set [UNIT_DATA_ID_CAT, _catID];
		_data set [UNIT_DATA_ID_SUBCAT, _subcatID];
		_data set [UNIT_DATA_ID_CLASS_NAME, _class];
		_data set [UNIT_DATA_ID_MUTEX, MUTEX_NEW()];
		_data set [UNIT_DATA_ID_GROUP, ""];
		_data set [UNIT_DATA_ID_LOADOUT, _loadout];
		_data set [UNIT_DATA_ID_GEAR, _gear];
		_data set [UNIT_DATA_ID_INVENTORY, []];
		if (!isNull _hO) then {
			_data set [UNIT_DATA_ID_OBJECT_HANDLE, _hO];
		};
		T_SETV("data", _data);

		// Push the new object into the array with all units
		private _allArray = GETSV(UNIT_CLASS_NAME, "all");
		_allArray pushBack _thisObject;

		// Add this unit to a group
		if(_group != "") then {
			CALLM1(_group, "addUnit", _thisObject);
		};

		// Initialize variables, event handlers and other things
		if (!isNull _hO) then {
			// Don't uncomment this until weapon disassembly is supported
			// I am looking at you Marvis, don't
			// Just do not
			_hO enableWeaponDisassembly false; // Disable weapon disassmbly
			T_CALLM0("initObjectVariables");
			T_CALLM0("initObjectEventHandlers");
			T_CALLM0("initObjectDynamicSimulation");
			T_CALLM0("applyInfantryGear");

			if (_catID == T_VEH) then {
				T_CALLM0("updateVehicleLock");
			};
		};

	ENDMETHOD;


	//                             D E L E T E
	/*
	Method: delete
	Deletes this object, despawns the physical unit if neccessary.
	*/

	METHOD(delete)
		params[P_THISOBJECT];

		OOP_INFO_0("DELETE UNIT");

		private _data = T_GETV("data");

		//Despawn this unit if it was spawned
		if (T_CALLM0("isSpawned")) then {
			T_CALLM0("despawn");
		};

		// Remove the unit from its group
		private _group = _data select UNIT_DATA_ID_GROUP;
		if(_group != "") then {
			CALLM1(_group, "removeUnit", _thisObject);
		};

		// Remove this unit from its garrison
		private _gar = _data select UNIT_DATA_ID_GARRISON;
		if (_gar != "") then {
			CALLM1(_gar, "removeUnit", _thisObject);
		};

		//Remove this unit from array with all units
		private _allArray = GETSV(UNIT_CLASS_NAME, "all");
		_allArray deleteAt (_allArray find _thisObject);

		private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (!isNull _objectHandle) then {
			T_CALLM0("deinitObjectVariables");
		};
		T_SETV("data", nil);
	ENDMETHOD;

	public METHOD(release)
		params [P_THISOBJECT];
		// detach the Arma unit handle from this object if it is spawned
		// Despawn this unit if it was spawned
		if (T_CALLM0("isSpawned")) then {
			T_CALLM1("despawn", true);
		};
	ENDMETHOD;

	//                              I S   V A L I D
	/*
	Method: isValid
	Checks if the created unit is valid(check the constructor code)
	After creating a new unit, make sure it's valid before adding it to other objects.

	Returns: bool
	*/
	public METHOD(isValid)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		pr _return = if (isNil "_data") then {
			false
		} else {
			//Return true if the data array is of the correct size
			( (count _data) == UNIT_DATA_SIZE)
		};

		if (!_return) then {OOP_ERROR_1("INVALID UNIT, _data: %1", _data);};

		_return
	ENDMETHOD;

	//                            C R E A T E   A I
	/*
	Method: createAI
	Creates an AI object for this unit after it has been spawned or changed owner.

	Parameters: _AIClassName

	_AIClassName - class name of <AI> object to create

	Access: meant for internal use!

	Returns: Created <AI> object
	*/
	METHOD(createAI)
		pr _AI = NULL_OBJECT;
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_AIClassName")];

			// Create an AI object of the unit
			// Don't start the brain, because its process method will be called by
			// its group's AI brain
			pr _data = T_GETV("data");

			if(_data # UNIT_DATA_ID_AI != NULL_OBJECT) exitWith {
				OOP_ERROR_0("Unit AI is already created");
			};

			_AI = NEW(_AIClassName, [_thisObject]);
			_data set [UNIT_DATA_ID_AI, _AI];

			CALLM0(_AI, "start");
		};

		// Return
		_AI
	ENDMETHOD;

	// Deletes AI on this unit
	public METHOD(deleteAI)
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			pr _data = T_GETV("data");
			pr _ai = _data select UNIT_DATA_ID_AI;
			if (!IS_NULL_OBJECT(_ai)) then {
				DELETE(_ai);
				_data set [UNIT_DATA_ID_AI, NULL_OBJECT];
			};
		};
	ENDMETHOD;


	//                              S P A W N
	/*
	Method: spawn
	Spawns given unit at specified coordinates. Will take care if the unit has already been spawned. Creates an AI object attached to this unit.

	Parameters: _pos, _dir

	_pos - position
	_dir - direction

	Returns: nil
	*/
	public METHOD(spawn)
		params [P_THISOBJECT, "_pos", "_dir", ["_spawnAtPrevPos", false]];

		OOP_INFO_1("SPAWN: %1", _this);

		//Unpack data
		private _data = T_GETV("data");

		OOP_INFO_1("  current data: %1", _data);

		//private _mutex = _data select UNIT_DATA_ID_MUTEX;

		//Lock the mutex
		//MUTEX_LOCK(_mutex);

		//Unpack more data...
		private _objectHandle = _data#UNIT_DATA_ID_OBJECT_HANDLE;
		private _buildResources = _data#UNIT_DATA_ID_BUILD_RESOURCE;
		if (isNull _objectHandle) then { //If it's not spawned yet
			private _className = _data#UNIT_DATA_ID_CLASS_NAME;
			private _group = _data#UNIT_DATA_ID_GROUP;
			pr _posATLPrev = _data#UNIT_DATA_ID_POS_ATL;
			pr _dirAndUpPrev = _data#UNIT_DATA_ID_VECTOR_DIR_UP;
			if (_spawnAtPrevPos) then {
				OOP_INFO_2("  Trying to spawn at prev location: %1, %2", _posATLPrev, _dirAndUpPrev);
				// Ensure that position is safe
				pr _prevPosSafe = if !(_posATLPrev isEqualTo NULL_POSITION) then {
					pr _vectorDir = _dirAndUpPrev#0;
					pr _dirToCheck = (_vectorDir#0) atan2 (_vectorDir#1);

					CALLSM3("Location", "isPosSafe", _posATLPrev, _dirToCheck, _className)
				} else {
					false 
				};

				if (_prevPosSafe) then {
					_pos = _posATLPrev;
				} else {
					pr _locPrev = _data#UNIT_DATA_ID_LOCATION;
					private _posAndDir = if(_locPrev != NULL_OBJECT) then {
						// Fall back to getting a valid spawn position from our location if it exists
						OOP_INFO_1("  Looking for spawn at prev location: %1", _locPrev);
						private _unitData = T_CALLM0("getMainData");
						private _args = _unitData + [0];
						CALLM(_locPrev, "getSpawnPos", _args)
					} else {
						// Otherwise just look for a close by safe position
						OOP_INFO_1("  Looking for spawn at near desired position: %1", _pos);
						CALLSM3("Location", "findSafePos", _pos, _className, 400)
					};
					_posAndDir params ["_pos0", "_dir0"];
					_pos = _pos0;
					_dir = _dir0;
					_spawnAtPrevPos = false;
				};
			};

			private _catID = _data select UNIT_DATA_ID_CAT;

			CRITICAL_SECTION {
				//Perform object creation
				switch(_catID) do {
					case T_INF: {
						private _groupHandle = CALLM0(_group, "getGroupHandle");
						if (isNull _groupHandle) exitWith {
							OOP_ERROR_1("Spawn: group handle is null (_data = %1)!", _data);
							// Mark it as dead?
							T_SETV("data", []);
						};
						//diag_log format ["---- Received group of side: %1", side _groupHandle];
						_objectHandle = _groupHandle createUnit [_className, _pos, [], 10, "FORM"];

						if (isNull _objectHandle) then {
							OOP_ERROR_1("Created infantry unit is Null. Unit data: %1", _data);
							_objectHandle = _groupHandle createUnit ["I_Protagonist_VR_F", _pos, [], 10, "FORM"];
						};

						// Disabling this to keep things simpler (vehicle counterpart had to be disabled due to it potentially introducing more exposions on spawning)
						// // Delay showing the object (this will hopefully allow it to get teleported into position etc.)
						// _objectHandle allowDamage false;
						// _objectHandle hideObjectGlobal true;
						// _objectHandle stop true;
						// _objectHandle spawn {
						// 	uisleep SHOW_DELAY;
						// 	_this allowDamage true;
						// 	_this hideObjectGlobal false;
						// 	_this stop false;
						// };

						// Set loadout if requited
						pr _loadout = _data select UNIT_DATA_ID_LOADOUT;
						if (_loadout != NULL_OBJECT) then {
							[_objectHandle, _loadout] call t_fnc_setUnitLoadout;
						};
						[_objectHandle] joinSilent _groupHandle; //To force the unit join this side
						_objectHandle allowFleeing 0;

						_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];

						//_objectHandle disableAI "PATH";
						//_objectHandle setUnitPos "UP"; //Force him to not sit or lay down

						T_CALLM1("createAI", "AIUnitInfantry");

						pr _groupType = CALLM0(_group, "getType");

						// Give weapons to the unit (if he has special weapons)
						T_CALLM0("applyInfantryGear");

						/*
						// Global difficulty will effect AI between 0.2 and 0.8
						private _effectiveDiff = if(side _groupHandle == CALLM0(gGameMode, "getEnemySide")) then {
							vin_diff_global;
						} else {
							1 - vin_diff_global
						};

						// Difficulty on effects AI between 0.2 and 0.8, to make it more responsive.
						// i.e. difficulty above 0.8 will give all AI skill 1, below 0.2 all AI skill 0
						private _diffModifer = MAP_TO_RANGE(_effectiveDiff, 0.2, 0.8, 0, 1);
						*/

						// Set unit skill
						// Aiming and precision

						_objectHandle setSkill ["aimingAccuracy", vin_aiskill_aimingAccuracy];	// Aiming and precision
						_objectHandle setSkill ["aimingShake", vin_aiskill_aimingShake];
						_objectHandle setSkill ["aimingSpeed", vin_aiskill_aimingSpeed];
						_objectHandle setSkill ["commanding", 1];		// Everything else
						_objectHandle setSkill ["courage", 0.5];
						//_objectHandle setSkill ["endurance", 0.8];
						_objectHandle setSkill ["general", 1];
						_objectHandle setSkill ["reloadSpeed", 0.5];
						_objectHandle setSkill ["spotDistance", vin_aiskill_spotDistance];
						_objectHandle setSkill ["spotTime", vin_aiskill_spotTime];

						private _subcatID = _data select UNIT_DATA_ID_SUBCAT;
						switch _subcatID do {
							case T_INF_medic: 		{ _objectHandle setUnitTrait ["medic", true]; };
							case T_INF_engineer: 	{ _objectHandle setUnitTrait ["engineer", true]; };
							case T_INF_exp: 		{ _objectHandle setUnitTrait ["explosiveSpecialist", true]; };
							case T_INF_sniper: 		{ _objectHandle setUnitTrait ["camouflageCoef", 0.5]; };
							case T_INF_spotter: 	{ _objectHandle setUnitTrait ["camouflageCoef", 0.5]; };
						};

						// make it impossible to ace interact with this unit, may need better solution in the future
						if (side _objectHandle != west) then {
							[_objectHandle, _objectHandle] call ace_common_fnc_claim;
						};

						// Set unit insignia
						// todo find a better way to handle this?
						if (side _groupHandle == CALLM0(gGameMode, "getPlayerSide")) then {
							[_objectHandle, "Vindicta"] call BIS_fnc_setUnitInsignia;
						};
					};
					case T_VEH: {

						private _subcatID = _data select UNIT_DATA_ID_SUBCAT;
						
						// Just assuming that if we are over 25m high we are flying, doesn't mean its true...
						pr _special = if(_subcatID in T_VEH_air && _pos#2 > 25) then {
							"FLY"
						} else {
							"CAN_COLLIDE"
						};

						_objectHandle = createVehicle [_className, _pos, [], 0, _special];

						if (isNull _objectHandle) then {
							OOP_ERROR_1("Created vehicle is Null. Unit data: %1", _data);
							_objectHandle = createVehicle ["C_Kart_01_Red_F", _pos, [], 0, _special];
						};

						// Disabling this as it can cause intersections as other vehicles aren't detected during createVehicle
						// _objectHandle allowDamage false;
						// _objectHandle hideObjectGlobal true;
						// _objectHandle spawn {
						// 	uisleep SHOW_DELAY;
						// 	_this allowDamage true;
						// 	_this hideObjectGlobal false;
						// };

						// This is not currently doing anything.
						// private _spawnCheckEv = _objectHandle addEventHandler ["EpeContactStart", {
						// 	params ["_object1", "_object2", "_selection1", "_selection2", "_force"];
						// 	OOP_INFO_MSG("Vehicle %1 failed spawn check, collided with %2 force %3!", [_object1 ARG _object2 ARG _force]);
						// 	// if(_force > 100) then {
						// 	// 	deleteVehicle _object1;
						// 	// };
						// }];

						// [_thisObject, _objectHandle, _group, _spawnCheckEv, _data] spawn {
						// 	params [P_THISOBJECT, "_objectHandle", "_group", "_spawnCheckEv", "_data"];
						// 	uisleep 2;
						// 	// If it survived spawning
						// 	if (alive _objectHandle) then {
						// 		OOP_INFO_MSG("Vehicle %1 passed spawn check, did not explode!", [_objectHandle]);
						// 		_objectHandle removeEventHandler ["EpeContactStart", _spawnCheckEv];
						// 	} else {
								
						// 	};
						// };

						// Don't uncomment this until weapon disassembly is supported
						// I am looking at you Marvis, don't
						// Just do not
						_objectHandle enableWeaponDisassembly false; // Disable weapon disassmbly

						_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];
						T_CALLM1("createAI", "AIUnitVehicle");

						// Initialize vehicle lock
						T_CALLM0("updateVehicleLock");
					};
					case T_DRONE: {
					};

					case T_CARGO: {
						private _subcatID = _data select UNIT_DATA_ID_SUBCAT;

						// Check if it's a static vehicle. If it is, we can create it wherever we want without engine-provided collision check
						pr _special = "CAN_COLLIDE";
						/*
						if ([_catID, _subcatID] in T_static) then {
							_special = "CAN_COLLIDE";
						};
						*/

						_objectHandle = createVehicle [_className, _pos, [], 0, _special];

						if (isNull _objectHandle) then {
							OOP_ERROR_1("Created vehicle is Null. Unit data: %1", _data);
							_objectHandle = createVehicle ["C_Kart_01_Red_F", _pos, [], 0, _special];
						};

						// No damage for crates
						_objectHandle allowDamage false;

						// Disabling this as it can cause intersections as other vehicles aren't detected during createVehicle
						// _objectHandle allowDamage false;
						// _objectHandle hideObjectGlobal true;
						// _objectHandle spawn {
						// 	uisleep SHOW_DELAY;
						// 	_this allowDamage true;
						// 	_this hideObjectGlobal false;
						// };

						// _objectHandle allowDamage false;
						// private _spawnCheckEv = _objectHandle addEventHandler ["EpeContactStart", {
						// 	params ["_object1", "_object2", "_selection1", "_selection2", "_force"];
						// 	OOP_INFO_MSG("Vehicle %1 failed spawn check, collided with %2 force %3!", [_object1 ARG _object2 ARG _force]);
						// 	// if(_force > 100) then {
						// 	// 	deleteVehicle _object1;
						// 	// };
						// }];

						// [_thisObject, _objectHandle, _group, _spawnCheckEv, _data] spawn {
						// 	params [P_THISOBJECT, "_objectHandle", "_group", "_spawnCheckEv", "_data"];
						// 	uisleep 2;
						// 	_objectHandle allowDamage true;
						// 	// If it survived spawning
						// 	if (alive _objectHandle) then {
						// 		OOP_INFO_MSG("Vehicle %1 passed spawn check, did not explode!", [_objectHandle]);
						// 		_objectHandle removeEventHandler ["EpeContactStart", _spawnCheckEv];
						// 	} else {
								
						// 	};
						// };

						_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];

						// Initialize limited arsenal
						if(T_CALLM0("limitedArsenalOnSpawn")) then {
							// If its an arsenal then we disable carry and drag
							[_objectHandle, false] remoteExec ["ace_dragging_fnc_setDraggable", 0, true];
							[_objectHandle, false] remoteExec ["ace_dragging_fnc_setCarryable", 0, true];
						} else {
							// If it isn't an arsenal object then force it to be dragable. Arsenal can be moved using build UI only.
							[_objectHandle, true, [0, 2, 0.1], 0, true] remoteExec ["ace_dragging_fnc_setDraggable", 0, true];
						};

						//T_CALLM1("createAI", "AIUnitVehicle");		// A box probably has no AI?
						// Give intel to this unit
						//CALLSM1("UnitIntel", "initUnit", _thisObject); // We probably don't put intel into boxes yet
					};
				};

				if (_spawnAtPrevPos) then {
					_objectHandle setPosATL _posATLPrev;
					_objectHandle setVectorDirAndUp _dirAndUpPrev;
				} else {
					_objectHandle setDir _dir;
					_objectHandle setPos _pos;
				};

				// Initialize variables
				T_CALLM0("initObjectVariables");

				// Initialize event handlers
				T_CALLM0("initObjectEventHandlers");

				// Initialize dynamic simulation
				T_CALLM0("initObjectDynamicSimulation");
			}; // CRITICAL_SECTION

			// !! Functions below might need to lock the garrison mutex, so we release the critical section

			// Try and restore saved inventory, otherwise generate one
			private _restoredInventory = T_CALLM0("restoreInventory");
			if(!_restoredInventory) then {
				// Initialize cargo if there is no limited arsenal
				T_CALLM0("initObjectInventory");

				// Set build resources
				if (_buildResources > 0 && {T_CALLM0("canHaveBuildResources")}) then {
					T_CALLM1("_setBuildResourcesSpawned", _buildResources);
				};
			};

			// Give intel to this unit
			// Intel tablets are not saved in inventory
			switch (_catID) do {
				case T_INF: {
					// Leaders get intel tablets
					if (CALLM0(_group, "getLeader") == _thisObject) then {
						CALLSM1("UnitIntel", "initUnit", _thisObject);
					} else {
						// todo give intel to some special unit types, like radio specialists, etc...
						// Some random infantry units get tablets too
						if (random 10 < 2) then {
							CALLSM1("UnitIntel", "initUnit", _thisObject);
						};
					};
				};
				case T_VEH: {
					// A very little amount of vehicles gets intel
					if (random 10 < 3) then {
						CALLSM1("UnitIntel", "initUnit", _thisObject);
					};
				};
				case T_DRONE: {
					// Don't put intel into drones?
				};
				case T_CARGO: {
					// Don't put intel into cargo boxes?
				};
			};

		} else {
			OOP_ERROR_0("Already spawned");
			DUMP_CALLSTACK;
		};

		//Unlock the mutex
		//MUTEX_UNLOCK(_mutex);
	ENDMETHOD;

	/*
	Method: initObjectVariables
	Sets variables of unit's object handle.

	Returns: nil
	*/
	METHOD(initObjectVariables)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;

		// Set variables of the object
		if (!isNull _hO) then {
			// Variable with a reference to Unit object
			_hO setVariable [UNIT_VAR_NAME_STR, _thisObject, true]; // Global variable!
			pr _cat = _data select UNIT_DATA_ID_CAT;
			pr _subcat = _data select UNIT_DATA_ID_SUBCAT;
			
			// Variable with the efficiency vector of this unit
			_hO setVariable [UNIT_EFFICIENCY_VAR_NAME_STR, (T_efficiency select _cat select _subcat)];
			// That's all really
		};

	ENDMETHOD;

	/*
	Method: initObjectVariables
	Deletes variables of unit's object handle.

	Returns: nil
	*/
	METHOD(deinitObjectVariables)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;

		// Reset variables of the object
		if (!isNull _hO) then {
			// Variable with a reference to Unit object
			_hO setVariable [UNIT_VAR_NAME_STR, nil];
			
			// Variable with the efficiency vector of this unit
			_hO setVariable [UNIT_EFFICIENCY_VAR_NAME_STR, nil];
		};
	ENDMETHOD;

	/*
	Method: initObjectEventHandlers
	Adds event handlers to unit.

	Returns: nil
	*/
	METHOD(initObjectEventHandlers)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		pr _catID = _data select UNIT_DATA_ID_CAT;

		// Respawned
		if (isNil {_hO getVariable UNIT_EH_RESPAWN_STR}) then {
			pr _ehid = [_hO, "Respawn", {
				params ["_unit"];
				if(!isNil {_unit getVariable UNIT_EH_RESPAWN_STR}) then {
					_unit setVariable [UNIT_EH_RESPAWN_STR, nil];
					// Cannot do this due to https://feedback.bistudio.com/T150628
					//_unit removeEventHandler ["Respawn", _thisID];
					_this call Unit_fnc_EH_Respawn;
				};
			}] call CBA_fnc_addBISEventHandler;
			_hO setVariable [UNIT_EH_RESPAWN_STR, _ehid];
		};

		// Rating (hopefully disabling the renegade system)
		if (isNil {_hO getVariable UNIT_EH_HANDLE_RATING_STR}) then {
			pr _ehid = [_hO, "HandleRating", { 0 }] call CBA_fnc_addBISEventHandler;
			_hO setVariable [UNIT_EH_HANDLE_RATING_STR, _ehid];
		};

		// HandleDamage for infantry
		if ((_data select UNIT_DATA_ID_CAT == T_INF) &&	// Only to infantry
			{owner _hO in [0, clientOwner]} &&			// We only add handleDamage to the units which we own. 0 is owner ID of a just-created unit
			{!(_hO isEqualTo player)}) then { 			// Ignore player

			if (isNil {_hO getVariable UNIT_EH_DAMAGE_STR}) then {
				// If ACE is loaded
				if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {
					pr _aceEH = _hO getVariable ["ace_medical_handledamageehid", -1];
					if (_aceEH != -1) then {
						_hO removeEventHandler ["handleDamage", _aceEH];
					} else {
						OOP_ERROR_0("ACE event handler ace_medical_handledamageehid was not found, did it change?");
					};
					pr _ehid = _hO addEventHandler ["handleDamage", {_this call Unit_fnc_EH_handleDamageInfantryACE}];
					_hO setVariable [UNIT_EH_DAMAGE_STR, _ehid];
				} else {
					// If ACE is not loaded
					pr _ehid = _hO addEventHandler ["handleDamage", {_this call Unit_fnc_EH_handleDamageInfantryStd}];
					_hO setVariable [UNIT_EH_DAMAGE_STR, _ehid];
				};
			};
		};

		// HandleDamage for vehicles
		if ((_data select UNIT_DATA_ID_CAT in [T_VEH, T_CARGO]) &&
			{owner _hO in [0, clientOwner]}) then {			// We only add handleDamage to the units which we own. 0 is owner ID of a just-created unit

			if (isNil {_hO getVariable UNIT_EH_DAMAGE_STR}) then {
				_hO removeAllEventHandlers "handleDamage";
				pr _ehid = _hO addEventHandler ["handleDamage", Unit_fnc_EH_handleDamageVehicle];
				//diag_log format ["Added damage event handler: %1", _thisObject];
				_hO setVariable [UNIT_EH_DAMAGE_STR, _ehid];
			};
		};

		// GetIn, if it's a vehicle
		if (_catID == T_VEH) then {
			_hO addEventHandler ["GetIn", Unit_fnc_EH_GetIn];
			_hO addEventHandler ["GetOut", Unit_fnc_EH_GetOut];
		};
	ENDMETHOD;

	METHOD(initObjectDynamicSimulation)
		params [P_THISOBJECT];
		
		pr _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;

		pr _cat = _data select UNIT_DATA_ID_CAT;
		switch (_cat) do {
			case T_INF: {	
				_hO triggerDynamicSimulation true;
				_hO enableDynamicSimulation false;
			};

			case T_VEH: {
				_hO triggerDynamicSimulation true;
				_hO enableDynamicSimulation true;
			};

			case T_DRONE: {
				_hO triggerDynamicSimulation true;
				_hO enableDynamicSimulation false;
			};

			case T_CARGO: {
				_hO triggerDynamicSimulation false;
				_hO enableDynamicSimulation false;
			};
		};
	ENDMETHOD;

	/*
	Sets vehicle lock according to the current side of the vehicle
	*/
	METHOD(updateVehicleLock)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");

		// Bail if not vehicle
		pr _catID = _data#UNIT_DATA_ID_CAT;
		if ((_catID) != T_VEH) exitWith {};

		// Bail if it's a static weapon
		pr _subcatID = _data#UNIT_DATA_ID_SUBCAT;
		if (_subcatID in T_VEH_static) exitWith {};

		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;

		// Bail if not spawned
		if (isNull _hO) exitWith {};

		pr _garrison = _data select UNIT_DATA_ID_GARRISON;

		// Bail if there is no garrison
		if (IS_NULL_OBJECT(_garrison)) exitWith {};

		pr _side = CALLM0(_garrison, "getSide");
		pr _lock = (_side != CALLM0(gGameMode, "getPlayerSide")) && (_side != CIVILIAN);

		["ACE_vehicleLock_setVehicleLock", [_hO, _lock], [_hO]] call CBA_fnc_targetEvent;
	ENDMETHOD;

	Unit_fnc_hasInventory = {
		//check if object has inventory
		pr _className = typeOf _this;
		pr _tb = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxbackpacks");
		pr _tm = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxmagazines");
		pr _tw = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxweapons");
		(_tb > 0  || _tm > 0 || _tw > 0)
	};

	/* private */ METHOD(setInventory)
		params [P_THISOBJECT, P_ARRAY("_inventory")];

		private _data = T_GETV("data");
		private _hO = _data#UNIT_DATA_ID_OBJECT_HANDLE;
		if(!(isNull _hO)) then {
			CALLSM2("Unit", "_setRealInventory", _hO, _inventory);
		} else {
			if(count _data > UNIT_DATA_ID_INVENTORY) then {
				_data set[UNIT_DATA_ID_INVENTORY, +_inventory];
			};
		};
	ENDMETHOD;

	public METHOD(clearInventory)
		params [P_THISOBJECT];
		private _emptyInventory = [[],[],[],[]];
		T_CALLM1("setInventory", _emptyInventory);
	ENDMETHOD;

	public METHOD(addToInventory)
		params [P_THISOBJECT, P_ARRAY("_inventory")];

		private _data = T_GETV("data");
		pr _hO = _data#UNIT_DATA_ID_OBJECT_HANDLE;
		if(!(isNull _hO)) then {
			CALLSM2("Unit", "_addToRealInventory", _hO, +_inventory);
		} else {
			if(count _data > UNIT_DATA_ID_INVENTORY) then {
				private _savedInventory = _data#UNIT_DATA_ID_INVENTORY;
				if(count _savedInventory == 4) then {
					// Merge inventories
					{
						private _sourceInventorySlot = _inventory#_forEachIndex;
						private _targetInventorySlot = _x;
						{
							_x params ["_item", "_amount"];
							private _idx = _targetInventorySlot findIf { (_x#0) isEqualTo _item };
							if(_idx == NOT_FOUND) then {
								_targetInventorySlot pushBack [_item, _amount];
							} else {
								private _existingCount = _targetInventorySlot#_idx#1;
								(_targetInventorySlot#_idx) set [1, _existingCount + _amount];
							};
						} forEach _sourceInventorySlot;
					} forEach _savedInventory;
				} else {
					// Saved inventory wasn't valid, just replace it
					_data set[UNIT_DATA_ID_INVENTORY, +_inventory];
				};
			};
		};
	ENDMETHOD;

	METHOD(restoreInventory)
		params [P_THISOBJECT];
		private _data = T_GETV("data");

		// Bail if not spawned
		pr _hO = _data#UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith { false };

		pr _savedInventory = if(count _data > UNIT_DATA_ID_INVENTORY) then {
			_data#UNIT_DATA_ID_INVENTORY
		} else {
			[]
		};

		if ((_hO call Unit_fnc_hasInventory) && count _savedInventory == 4) then {
			// diag_log format["RESTORING INV FOR %1: %2", _hO, _savedInventory];
			CALLSM2("Unit", "_setRealInventory", _hO, _savedInventory);
			true
		} else {
			false
		}
	ENDMETHOD;

	METHOD(_setRealInventory)
		params [P_THISOBJECT, P_OBJECT("_hO"), P_ARRAY("_inventory")];

		if(_hO in allPlayers) exitWith {
			DUMP_CALLSTACK;
			OOP_ERROR_MSG("PLAYERINVBUG: _setRealInventory _this:%1, _data:%2, _hO:%3", [_this ARG _data ARG _hO]);
			// Broadcast notification
			pr _msg = format["%1 just avoided the inventory clear bug (_setRealInventory), please send your .rpt to the developers so we can fix it!", name _hO];
			REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createCritical", [_msg], ON_CLIENTS, NO_JIP);
		};

		// Clear cargo
		clearWeaponCargoGlobal _hO;
		clearItemCargoGlobal _hO;
		clearMagazineCargoGlobal _hO;
		clearBackpackCargoGlobal _hO;

		CALLSM2("Unit", "_addToRealInventory", _hO, _inventory);
	ENDMETHOD;
	
	STATIC_METHOD(_addToRealInventory)
		params [P_THISCLASS, P_OBJECT("_hO"), P_ARRAY("_inventory")];
		//weapons
		{
			_hO addWeaponCargoGlobal _x;
		} forEach _inventory#0;
		//items
		{
			_hO addItemCargoGlobal _x;
		} forEach _inventory#1;
		//magazines
		{
			_x params ["_item", "_amount"];
			private _count = getNumber (configfile >> "CfgMagazines" >> _item >> "count");
			if(_count > 0) then {
				private _full = floor (_amount / _count);
				if(_full > 0) then {
					_hO addMagazineAmmoCargo [_item, _full, _count];
				};
				private _remainder = floor(_amount % _count);
				if(_remainder > 0) then {
					_hO addMagazineAmmoCargo [_item, 1, _remainder];
				};
			};
		} forEach _inventory#2;
		//backpack
		{
			_hO addBackpackCargoGlobal _x;
		} forEach _inventory#3;
	ENDMETHOD;

	METHOD(saveInventory)
		params [P_THISOBJECT];
		private _data = T_GETV("data");

		// Bail if not spawned
		pr _hO = _data#UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {};

		pr _catid = _data select UNIT_DATA_ID_CAT;

		private _fn_addToArray = {
			params ["_array", "_item", "_count"];
			private _existing = _array findIf { _x#0 isEqualTo _item };
			if(_existing != NOT_FOUND) then {
				_array#_existing set [1, _array#_existing#1 + _count];
			} else {
				_array pushBack [_item, _count];
			};
		};

		private _fn_loadInv = {
			params ["_hO", "_inventoryArray"];

			private _weapItems = weaponsItemsCargo _hO;
			{
				_x params ["_weapon", "_muzzle", "_flashlight", "_optics", "_primaryMuzzleMagazine", "_secondaryMuzzleMagazine", "_bipod"];
				if(!(_weapon isEqualTo "")) then {
					[_inventoryArray#0, _weapon, 1] call _fn_addToArray;
				};
				{
					[_inventoryArray#1, _x, 1] call _fn_addToArray;
				} forEach ([_muzzle, _flashlight, _optics, _bipod] select {!(_x isEqualTo "")});
				{
					[_inventoryArray#2, _x#0, _x#1] call _fn_addToArray;
				} forEach ([_primaryMuzzleMagazine, _secondaryMuzzleMagazine] select {!(_x isEqualTo [])});
			} foreach _weapItems;

			{
				[_inventoryArray#2, _x#0, _x#1] call _fn_addToArray;
			} forEach (magazinesAmmoCargo _hO);

			{
				[_inventoryArray#1, _x, 1] call _fn_addToArray;
			} forEach (itemCargo _hO);

			{
				[_inventoryArray#3, _x, 1] call _fn_addToArray;
			} forEach (backpackCargo _hO);

			// recurse into items that have their own inventories
			{
				_x params ["_type", "_h"];
				[_h, _inventoryArray] call _fn_loadInv;
			} forEach (everyContainer _hO);
		};

		// Don't save unless we have an inventory
		if (_hO call Unit_fnc_hasInventory) then {
			// addWeaponCargoGlobal, addItemCargoGlobal, addMagazineAmmoCargo, addBackpackCargoGlobal
			// ((everyContainer cursorObject)#0#1)
			private _savedInventory = [[],[],[],[]];
			[_hO, _savedInventory] call _fn_loadInv;
			//diag_log format["SAVED INV FOR %1: %2", _hO, _savedInventory];
			_data set [UNIT_DATA_ID_INVENTORY, _savedInventory];
		};
	ENDMETHOD;

	METHOD(initObjectInventory)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");

		// Bail if not spawned
		pr _hO = _data#UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {};

		pr _catid = _data select UNIT_DATA_ID_CAT;
		if (_catID in [T_VEH, T_DRONE, T_CARGO]) then {
			// = = = NOT INFANTRY = = =

			// Clear cargo
			if(_hO in allPlayers) exitWith {
				DUMP_CALLSTACK;
				OOP_ERROR_MSG("PLAYERINVBUG: initObjectInventory _this:%1, _data:%2, _hO:%3", [_this ARG _data ARG _hO]);
				// Broadcast notification
				pr _msg = format["%1 just avoided the inventory clear bug (initObjectInventory), please send your .rpt to the developers so we can fix it!", name _hO];
				REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createCritical", [_msg], ON_CLIENTS, NO_JIP);
			};
			clearItemCargoGlobal _hO;
			clearWeaponCargoGlobal _hO;
			clearMagazineCargoGlobal _hO;
			clearBackpackCargoGlobal _hO;

			// Bail if there is a limited arsenal
			pr _arsenalDataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
			if ((count _arsenalDataList) != 0) exitWith {

			};

			// Otherwise fill the ammo box with stuff from the template
			pr _gar = _data select UNIT_DATA_ID_GARRISON;
			if (_gar == NULL_OBJECT) exitWith {
			};
			pr _t = CALLM0(_gar, "getTemplate");
			// Add stuff to cargo from the template
			pr _tInv = _t#T_INV;

			pr _side = CALLM0(_data#UNIT_DATA_ID_GARRISON, "getSide");
			if(_side == CIVILIAN) then {

				// = = = NOT INFANTRY CIVILIAN = = =

				// Small chance for weapons and magazines
				private _inv = [];
				if(random 5 < 1) then {
					private _inv = [];
					if(count (_tInv#T_INV_primary) > 0) then {
						_inv append [T_INV_primary, 0.2];
					};
					if(count (_tInv#T_INV_secondary) > 0) then {
						_inv append [T_INV_secondary, 0.1];
					};
					if(count (_tInv#T_INV_handgun) > 0) then {
						_inv append [T_INV_handgun, 1];
					};
					
					private _subCatId = selectRandomWeighted _inv;
					pr _weaponsAndMags = _tInv#_subcatID;
					pr _weaponAndMag = selectRandom _weaponsAndMags;
					_weaponAndMag params ["_weaponClassName", "_magazines"];
					_hO addItemCargoGlobal [_weaponClassName, round (1 + random 1) ];
					if (count _magazines > 0) then {
						_hO addMagazineCargoGlobal [selectRandom _magazines, ceil random[2, 4, 6]];
					};
				};
				// Some items
				// Each item has a fixed chance of appearing
				{
					if ((random 10) < 7) then {
						_hO addItemCargoGlobal [_x, 1 + random 2];
					};
				} foreach (_tInv#T_INV_items);
				// Add backpack
				if(count (_tInv#T_INV_backpacks) > 0 && random 3 < 1) then {
					_hO addBackpackCargoGlobal [selectRandom (_tInv#T_INV_backpacks), 2];
				};
				if (random 20 < 1) then {
					_hO addItemCargoGlobal ["vin_pills", 20];
				};

				
				// = = = END NOT INFANTRY CIVILIAN = = =
				

			} else {

				// = = = = MILITARY CARGO AND VEHICLES = = = =
				private _lootScaling = vin_diff_lootAmount;

				pr _nInf = CALLM0(_gar, "countInfantryUnits");
				pr _nVeh = CALLM0(_gar, "countVehicleUnits");
				pr _nCargo = CALLM0(_gar, "countCargoUnits");

				// Some number which scales the amount of items in this box
				pr _nGuns = 1.3 * _nInf * _lootScaling / ((_nVeh + _nCargo) max 1);

				// Modifier for cargo boxes
				if (_catID == T_CARGO) then {
					_nGuns = _nGuns * 3;
				};

				// Add weapons and magazines
				pr _arr = [[T_INV_primary, _nGuns, 10], [T_INV_secondary, 0.4*_nGuns, 5], [T_INV_handgun, 0.1*_nGuns, 3]]; // [_subcatID, num. attempts]
				{
					_x params ["_subcatID", "_n", "_nMagsPerGun"];
					if (count (_tInv#_subcatID) > 0) then { // If there are any weapons in this subcategory

						// Randomize _n
						_n = round (random [0.2*_n, _n, 1.8*_n]);

						for "_i" from 0 to (_n-1) do {
							pr _weaponsAndMags = _tInv#_subcatID;
							pr _weaponAndMag = selectRandom _weaponsAndMags;
							_weaponAndMag params ["_weaponClassName", "_magazines"];
							_hO addItemCargoGlobal [_weaponClassName, round (1 + random 1) ];
							if (count _magazines > 0) then {
								_hO addMagazineCargoGlobal [selectRandom _magazines, _nMagsPerGun];
							};
						};
					};
				} forEach _arr;

				// Add items of weapons, misc items, NVGs
				pr _arr = [	[T_INV_primary_items, 0.6*_nGuns], [T_INV_secondary_items, 0.6*_nGuns],	// [_subcatID, num. attempts]
							[T_INV_handgun_items, 0.1*_nGuns], [T_INV_items, 0.7*_nGuns],
							[T_INV_NVGs, 1.5*_nGuns]]; // We want more NVGs
				{
					_x params ["_subcatID", "_n"];

					if (count (_tInv#_subcatID) > 0) then { // If there are any items in this subcategory

						// Randomize _n
						_n = (round (random [0.2*_n, _n, 1.8*_n]));
						pr _items = _tInv#_subcatID;
						for "_i" from 0 to (_n-1) do {
							_hO addItemCargoGlobal [selectRandom _items, round (1 + random 1)];
						};
					};
				} forEach _arr;

				// Add ACRE Radios
				// We probably want them in all vehicles, not only in boxes
				if (isClass (configfile >> "CfgPatches" >> "acre_main")) then {
					// Array with item class name, count
					pr _ACREclassNames = t_ACRERadios;
					{
						_x params ["_itemName", "_itemCount"];
						_hO addItemCargoGlobal [_itemName, round (_lootScaling * _itemCount * random [0.5, 1, 1.5])];
					} forEach _ACREclassNames;
				};

				// Add TFAR Radios (0.9.12)
				if (isClass (configfile >> "CfgPatches" >> "task_force_radio")) then {
					// Array with item class name, count
					pr _TFARclassNames = t_TFARRadios_0912;
					{
						_x params ["_itemName", "_itemCount"];
						_hO addItemCargoGlobal [_itemName, round (_lootScaling * _itemCount * random [0.5, 1, 1.5])];
					} forEach _TFARclassNames;
				};

				// Add TFAR Radios (BETA)
				if (isClass (configfile >> "CfgPatches" >> "tfar_core")) then {
					// Array with item class name, count
					pr _TFARBetaclassNames = t_TFARRadios_0100;
					{
						_x params ["_itemName", "_itemCount"];
						_hO addItemCargoGlobal [_itemName, round (_lootScaling * _itemCount * random [0.5, 1, 1.5])];
					} forEach _TFARBetaclassNames;
				};

				// Add headgear
				pr _nHeadgears = ceil (_nGuns * random [0.5, 1, 1.5]);
				pr _headgear = _tInv#T_INV_headgear;
				for "_i" from 0 to _nHeadgears do {
					_hO addItemCargoGlobal [selectRandom _headgear, 1];
				};

				// Add vests
				pr _nVests = ceil (_nGuns * random [0.5, 1, 1.5]);
				pr _vests = _tInv#T_INV_vests;
				for "_i" from 0 to _nVests do {
					_hO addItemCargoGlobal [selectRandom _vests, 1];
				};
	
				// Add backpacks
				pr _nBackpacks = ceil (_nGuns * random [0.5, 1, 1.5]);
				pr _backpacks = _tInv#T_INV_backpacks;
				for "_i" from 0 to _nBackpacks do {
					_hO addBackpackCargoGlobal [selectRandom _backpacks, 1];
				};

				// Add TFAR (0.9.12) backpacks, excluding the ones that uses the BWMOD camos. Commented out some due to different factions. Do with it as you please :)
				if (isClass (configfile >> "CfgPatches" >> "task_force_radio")) then {
					// Array with backpack class name
					for "_i" from 0 to _nBackpacks do {
						_hO addBackpackCargoGlobal [selectRandom t_TFARBackpacks_0912, 1];
					};
				};

				// Add TFAR (BETA) backpacks, excluding the ones that uses the BWMOD camos. Commented out some due to different factions. Do with it as you please :)
				if (isClass (configfile >> "CfgPatches" >> "tfar_core")) then {
					// Array with backpack class name
					pr _TFARBETAbackpack = t_TFARBackpacks_0100;
					for "_i" from 0 to _nVests do {
						_hO addBackpackCargoGlobal [selectRandom _TFARBETAbackpack, 1];
					};
				};

				// = = = = = END BOTH CARGO AND VEHICLES MILITARY = = = = = =



				// Add special items to cargo containers
				if (_catID == T_CARGO) then {

					// = = = = MILITARY CARGO BOXES = = = =

					// Add ACE medical items
					// NOTE that for cargo boxes and vehicles the arrays are different!
					if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {
						{
							_x params ["_className", "_itemCount"];
							_intemCount = vin_diff_lootAmount * _itemCount;
							_hO addItemCargoGlobal [_className, round (_lootScaling * _itemCount * random [0.8, 1.4, 2])];
						} forEach t_ACEMedicalItems_cargo;
					} else {
						// Add standard medkits
						_hO addItemCargoGlobal ["FirstAidKit", vin_diff_lootAmount * 80];
					};

					// Add ACE misc items
					if (isClass (configfile >> "CfgPatches" >> "ace_common")) then {
						// Array with item class name, count
						// Exported from the ACE_Box_Misc
						// Then modified a bit
						pr _classNames = t_ACEMiscItems;
						{
							_x params ["_itemName", "_itemCount"];
							_itemCount = _itemCount * vin_diff_lootAmount;
							if(random 10 < 7) then {
								_hO addItemCargoGlobal [_itemName, round (_lootScaling * _itemCount * random [0.8, 1.4, 2])];
							};
						} forEach _classNames;
					};

					// Add grenades and explosives
					pr _grenades = _tInv#T_INV_grenades;
					{
						if (random 10 < 7) then {
							_hO addItemCargoGlobal [_x, _nGuns];
						};
					} forEach _grenades;

					// Add explosives
					pr _explosives = _tInv#T_INV_explosives;
					pr _nExplosives = ceil (_nGuns*0.2);
					{
						if (random 10 < 3) then {
							_hO addItemCargoGlobal [_x, _nExplosives];
						};
					} forEach _explosives;

					// = = = = = END MILITARY BOXES = = = = =
				} else {

					// = = = = = MILITARY VEHICLES = = = = =

					// Add ACE medical items
					if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {
						{
							_x params ["_className", "_itemCount"];
							_hO addItemCargoGlobal [_className, round (_lootScaling * _itemCount * random [0.5, 1, 1.5])];
						} forEach t_ACEMedicalItems_vehicles;
					} else {
						// Add standard medkits
						_hO addItemCargoGlobal ["FirstAidKit", 20];
					};
					// = = = =
				};

				// = = = = END NOT INFANTRY MILITARY = = = =

			};
		} else {

			// = = I N F A N T R Y = =
			if (random 100 <= 5) then {
				_hO addItemToUniform "vin_pills";
				_hO addItemToUniform "vin_pills";
				_hO addItemToUniform "vin_pills";
			};
		};
	ENDMETHOD;

	//                            D E S P A W N
	/*
	Method: despawn
	Despawns given unit. Deletes the AI object attached to this unit.

	Parameters: _pos, _dir

	_pos - position
	_dir - direction

	Returns: nil
	*/
	public METHOD(despawn)
		params [P_THISOBJECT, P_BOOL("_releaseHandle")];

		OOP_INFO_0("DESPAWN");

		//Unpack data
		private _data = T_GETV("data");
		private _mutex = _data select UNIT_DATA_ID_MUTEX;

		//Lock the mutex
		//MUTEX_LOCK(_mutex);

		//Unpack more data...
		private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (!isNull _objectHandle) then { //If it's been spawned before
			// Stop AI, sensors, etc
			pr _AI = _data select UNIT_DATA_ID_AI;
			// Some units are brainless. Check if the unit had a brain.
			if (_AI != NULL_OBJECT) then {
				CALLM2(gMessageLoopGroupManager, "postMethodSync", "deleteObject", [_AI]);
				_data set [UNIT_DATA_ID_AI, NULL_OBJECT];
			};

			// Get the amount of actual build resources in inventory
			// And store them into the array before we delete the vehicle
			pr _buildResources = 0;
			pr _catID = _data select UNIT_DATA_ID_CAT;
			if (T_CALLM0("canHaveBuildResources")) then {
				_buildResources = T_CALLM0("_getBuildResourcesSpawned");
				_data set [UNIT_DATA_ID_BUILD_RESOURCE, _buildResources];
			};

			// Save the inventory (for cargo and vics)
			T_CALLM0("saveInventory");

			// Deinitialize the limited arsenal
			T_CALLM0("limitedArsenalOnDespawn");

			// Set the pos, vector dir and up
			pr _posATL = getPosATL _objectHandle;
			_data set [UNIT_DATA_ID_POS_ATL, _posATL];
			pr _dirAndUp = [vectorDir _objectHandle, vectorUp _objectHandle];
			_data set [UNIT_DATA_ID_VECTOR_DIR_UP, _dirAndUp];

			// Set the location
			pr _gar = _data#UNIT_DATA_ID_GARRISON;
			pr _loc = if (_gar != NULL_OBJECT) then { CALLM0(_gar, "getLocation") } else { NULL_OBJECT };
			_data set [UNIT_DATA_ID_LOCATION, _loc];

			// If we are releasing the handle then we don't actually delete the unit!
			if(!_releaseHandle) then {
				// Delete the vehicle
				deleteVehicle _objectHandle;
			};

			//private _group = _data select UNIT_DATA_ID_GROUP;
			//if (_group != NULL_OBJECT) then { CALLM(_group, "handleUnitDespawned", [_thisObject]) };
			_data set [UNIT_DATA_ID_OBJECT_HANDLE, objNull];
		} else {
			OOP_ERROR_0("Already despawned");
			DUMP_CALLSTACK;
		};
		//Unlock the mutex
		//MUTEX_UNLOCK(_mutex);
	ENDMETHOD;



	//                     S E T   V E H I C L E   R O L E
	/*
	Method: assignVehicleRole
	NYI

	Assigns the unit to a vehicle with specified vehicle role
	*/
	public METHOD(setVehicleRole)
		params [P_THISOBJECT, "_vehicle", "_vehicleRole"];
	ENDMETHOD;


	//                         S E T   G A R R I S O N
	/*
	Method: setGarrison
	Sets the garrison this unit is attached to.

	Access: internal use! You must use Garrison::addUnit to add a unit to a garrison properly.

	Parameters: _garrison

	_garrison - the garrison object

	Returns: nil
	*/
	public METHOD(setGarrison)
		params [P_THISOBJECT, P_OOP_OBJECT("_garrison") ];

		OOP_INFO_1("SET GARRISON: %1", _garrison);

		private _data = T_GETV("data");
		_data set [UNIT_DATA_ID_GARRISON, _garrison];

		// Update lock state
		T_CALLM0("updateVehicleLock");
	ENDMETHOD;

	//                         S E T   G R O U P
	/*
	Method: setGroup
	Sets the group this unit is attached to.

	Access: internal use!

	Parameters: _garrison

	_garrison - the garrison object

	Returns: nil
	*/
	public METHOD(setGroup)
		params [P_THISOBJECT, P_OOP_OBJECT("_group") ];
		private _data = T_GETV("data");
		_data set [UNIT_DATA_ID_GROUP, _group];
	ENDMETHOD;

	/*
	Method: applyWeapons
	Gives weapons to the unit from the weapons array of this unit
	*/
	METHOD(applyInfantryGear)
		params [P_THISOBJECT];
		pr _data = T_GETV("data");

		// Bail if unit does not have special weapons
		pr _gear = _data select UNIT_DATA_ID_GEAR;
		if (count _gear == 0) exitWith {};

		// Bail if unit is not spawned
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {};

		// Can't call this on player units
		if(_hO in allPlayers) exitWith {
			OOP_ERROR_MSG("Can't call applyInfantryGear on player unit (%1)", [_this]);
		};

		// Remove all weapons
		removeAllWeapons _hO;

		// Set headgear
		removeHeadgear _hO;
		pr _headgear = _gear#UNIT_GEAR_ID_HEADGEAR;
		if(_headgear != "") then {
			_hO addHeadgear _headgear;
		};

		// Set vest
		removeVest _hO;
		pr _vest = _gear#UNIT_GEAR_ID_VEST;
		if(_vest != "") then {
			_hO addVest _vest;
		};

		// Add main gun
		pr _primary = _gear#UNIT_GEAR_ID_PRIMARY;
		if (_primary != "") then {
			pr _primaryMags = getArray (configfile >> "CfgWeapons" >> _primary >> "magazines");
			pr _mag = _primaryMags select 0;
			_hO addWeapon _primary;
			for "_i" from 0 to 8 do { _hO addItemToVest _mag; };
			for "_i" from 0 to 8 do { _hO addItemToUniform _mag; };
			_hO addPrimaryWeaponItem _mag;

			pr _muzzles = getArray(configFile >> "cfgWeapons" >> _primary >> "muzzles");
			if (count _muzzles > 1) then {
				_hO selectWeapon (_muzzles select 0);

				// Also give mags for GL
				pr _muzzle = _muzzles select 1;
				if (_muzzle != "this") then {
					pr _muzzleMags = getArray (configfile >> "CfgWeapons" >> _primary >> _muzzle >> "magazines");
					if (count _muzzleMags > 0) then {
						pr _mag = _muzzleMags select 0;
						for "_i" from 0 to 8 do { _hO addItemToVest _mag; };
						for "_i" from 0 to 8 do { _hO addItemToUniform _mag; };
						_hO addPrimaryWeaponItem _mag;
					};
				};
			} else {
				_hO selectWeapon _primary;
			};
		};

		// Process backpack
		// Soldiers without a secondary weapon keep their backpack
		pr _backpack = backpack _hO;

		// Add secondary weapon
		pr _secondary = _gear#UNIT_GEAR_ID_SECONDARY;
		if (_secondary != "") then {
			// Soldiers with secondary weapon get backpack emptied
			// Or are given a default backpack
			if (_backpack == "") then { _backpack = "B_Kitbag_rgr"; }; // Default backpack
			removeBackpack _hO;
			_hO addBackpack _backpack;
			clearAllItemsFromBackpack _hO; // In case the backpack has items from config

			pr _secondaryMags = getArray (configfile >> "CfgWeapons" >> _secondary >> "magazines");
			pr _mag = _secondaryMags select 0;
			_hO addWeapon _secondary;
			for "_i" from 0 to 4 do { _hO addItemToBackpack _mag; };
			_hO addSecondaryWeaponItem _mag;
		};

		// Force select primary weapon
		// https://community.bistudio.com/wiki/selectWeapon  notes by MaestrO.fr and Dr_Eyeball
		if (primaryWeapon _hO != "") then
		{			
			pr _type = primaryWeapon _hO;
			// check for multiple muzzles (eg: GL)
			pr _muzzles = getArray(configFile >> "cfgWeapons" >> _type >> "muzzles");
			
			if (count _muzzles > 1) then {
				_hO selectWeapon (_muzzles select 0);
			} else {
				_hO selectWeapon _type;
			};
		};

	ENDMETHOD;


	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// - - - - - - - - - - - - - - - - - - G E T   M E M B E R S - - - - - - - - - - - - - - - - - - -
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	//                         G E T   G A R R I S O N
	/*
	Method: getGarrison
	Returns the garrison this unit is attached to

	Returns: <Garrison>
	*/
	public METHOD(getGarrison)
		params [P_THISOBJECT];
		private _data = T_GETV("data");

		// If unit is in a group, get the garrison of its group
		pr _group = _data select UNIT_DATA_ID_GROUP;
		if (_group != "") then {
			CALLM0(_group, "getGarrison")
		} else {
			// For ungrouped units, return the garrison of the unit
			_data select UNIT_DATA_ID_GARRISON
		};
	ENDMETHOD;

	//                         G E T   O B J E C T   H A N D L E
	/*
	Method: getObjectHandle
	Returns the object handle of this unit if it's spawned, objNull otherwise.

	Returns: object handle of this unit, or objNull if it's not spawned
	*/
	public METHOD(getObjectHandle)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data select UNIT_DATA_ID_OBJECT_HANDLE
	ENDMETHOD;

	/*
	Method: getClassName
	Returns class name of this unit

	Returns: String
	*/
	public METHOD(getClassName)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data select UNIT_DATA_ID_CLASS_NAME
	ENDMETHOD;

	/*
	Method: isPlayer
	Returns: true if the unit is a player
	*/
	public METHOD(isPlayer)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		private _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		!(isNull _hO) && {_hO in allPlayers}
	ENDMETHOD;

	//                        G E T   G R O U P
	/*
	Method: getGroup
	Returns the <Group> this unit is attached to.

	Returns: <Group>
	*/
	// Returns the group of this unit
	public METHOD(getGroup)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data # UNIT_DATA_ID_GROUP
	ENDMETHOD;


	//                    G E T   M A I N   D A T A
	/*
	Method: getMainData
	Returns category ID, subcategory ID and class name of this unit

	Returns: array: [_catID, _subcatID, _className]
	*/
	public METHOD(getMainData)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		[_data # UNIT_DATA_ID_CAT, _data # UNIT_DATA_ID_SUBCAT, _data # UNIT_DATA_ID_CLASS_NAME]
	ENDMETHOD;
	
	//                    G E T   E F F I C I E N C Y
	/*
	Method: getEfficiency
	Returns efficiency vector of this unit

	Returns: Efficiency vector
	*/
	public METHOD(getEfficiency)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		T_efficiency # (_data # UNIT_DATA_ID_CAT) # (_data # UNIT_DATA_ID_SUBCAT)
	ENDMETHOD;

	//                        G E T   D A T A
	/*
	Method: getData

	Access: Meant for internal use since you can break the <Unit> object this way.

	Returns: the internal data array of this unit.
	*/
	public METHOD(getData)
		params [P_THISOBJECT];
		T_GETV("data")
	ENDMETHOD;


	//                             G E T   P O S
	/*
	Method: getPos
	Returns position of this unit or [] if the unit is not spawned

	Returns: [x, y, z]
	*/
	public METHOD(getPos)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		private _oh = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		getPos _oh
	ENDMETHOD;

	/*
	Method: getDespawnLocation
	Returns the location this unit despawned at last time, or ""

	Returns: <Location> or ""
	*/
	public METHOD(getDespawnLocation)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data#UNIT_DATA_ID_LOCATION
	ENDMETHOD;

	/*
	Method: getCategory
	Returns category ID, number
	*/
	public METHOD(getCategory)
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		_data#UNIT_DATA_ID_CAT
	ENDMETHOD;

	/*
	Method: getSubcategory
	Returns subcategory ID, number
	*/
	public METHOD(getSubcategory)
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		_data#UNIT_DATA_ID_SUBCAT
	ENDMETHOD;

	//                     H A N D L E   K I L L E D
	/*
	Method: handleKilled
	Gets called when a unit is killed.
	*/
	public METHOD(handleKilled)
		params [P_THISOBJECT];

		// Delete the brain of this unit, if it exists
		pr _data = T_GETV("data");
		pr _AI = _data select UNIT_DATA_ID_AI;
		if (_AI != "") then {
			CALLM2(gMessageLoopGroupManager, "postMethodSync", "deleteObject", [_AI]);
			_data set [UNIT_DATA_ID_AI, ""];
		};

		// Ungroup this unit
		_data set [UNIT_DATA_ID_GROUP, ""];

		// Clear the object variables
		private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (!isNull _objectHandle) then {
			T_CALLM0("deinitObjectVariables");
		};
	ENDMETHOD;

	// Some cargo was loaded into this unit
	public METHOD(handleCargoLoaded)
		params [P_THISOBJECT, P_OOP_OBJECT("_cargoUnit")];
		pr _AI = T_CALLM0("getAI");
		if (_AI != "") then {
			CALLM1(_AI, "addCargoUnit", _cargoUnit);
		};
	ENDMETHOD;

	// Some cargo was unloaded from this unit
	public METHOD(handleCargoUnloaded)
		params [P_THISOBJECT, P_OOP_OBJECT("_cargoUnit")];
		pr _AI = T_CALLM0("getAI");
		if (_AI != "") then {
			CALLM1(_AI, "removeCargoUnit", _cargoUnit);
		};
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               S T A T I C   M E T H O D S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	//          G E T   U N I T   F R O M   O B J E C T   H A N D L E
	/*
	Method: (static)getUnitFromObjectHandle
	Returns the <Unit> object the given object handle is associated with, or "" if this objectHandle is not associated with <Unit>

	Parameters: _objectHandle

	_objectHandle - the object handle of a unit.

	Returns: <Unit> or ""
	*/
	public STATIC_METHOD(getUnitFromObjectHandle)
		params [P_THISCLASS, P_OBJECT("_objectHandle") ];
		GET_UNIT_FROM_OBJECT_HANDLE(_objectHandle);
	ENDMETHOD;

	/*
	Method: (static)createUnitFromObjectHandle
	NYI
	Creates a unit and instantly attaches it to provided object handle.

	Returns: <Unit>
	*/
	public STATIC_METHOD(createUnitFromObjectHandle)
	ENDMETHOD;


	/*
	Method: (static)getRequiredCrew
	Returns amount of needed drivers and turret operators for all vehicles in this garrison.

	Parameters: _units

	_units - array of <Unit> objects

	Returns: [_nDrivers, _nTurrets, _nCargo]
	*/
	
	public STATIC_METHOD(getRequiredCrew)
		params ["_thisClass", P_ARRAY("_units")];
		
		pr _nDrivers = 0;
		pr _nTurrets = 0;
		pr _nCargo = 0;
		{
			if (CALLM0(_x, "isVehicle")) then {
				pr _className = CALLM0(_x, "getClassName");
				([_className] call misc_fnc_getFullCrew) params ["_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
				_nDrivers = _nDrivers + _n_driver;
				_nTurrets = _nTurrets + (count _copilotTurrets) + (count _stdTurrets);
				_nCargo = _nCargo + (count _psgTurrets) + _n_cargo;
			};
		} forEach _units;
		[_nDrivers, _nTurrets, _nCargo]
	ENDMETHOD;
	
	/*
	Function: (static)getCargoInfantryCapacity
	Returns how many units can be loaded as cargo by all the vehicles from _units
	
	Parameters: _units
	
	_units - array of <Unit> objects
	
	Returns: Number
	*/
	public STATIC_METHOD(getCargoInfantryCapacity)
		params ["_thisClass", P_ARRAY("_units")];
		pr _unitsClassNames = _units apply { pr _data = GETV(_x, "data"); _data select UNIT_DATA_ID_CLASS_NAME };
		_unitsClassNames call misc_fnc_getCargoInfantryCapacity;
	ENDMETHOD;
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	//                                       G E T   P R O P E R T I E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	//                    G E T   B E H A V I O U R
	/*
	Method: getVehaviour
	Runs 'behaviour' command on the object handle of this unit. See https://community.bistudio.com/wiki/behaviour

	Returns: String - One of "CARELESS", "SAFE", "AWARE", "COMBAT" and "STEALTH"
	*/
	public METHOD(getBehaviour)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		private _object = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		behaviour _object
	ENDMETHOD;

	//                          I S  A L I V E
	/*
	Method: isAlive
	Returns true if this unit is alive, false otherwise.
	Despawned unit is always considered alive.

	Returns: Bool
	*/
	public METHOD(isAlive)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		private _object = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (_object isEqualTo objNull) then {
			// Unit is despawned
			true
		} else {
			alive _object
		};
	ENDMETHOD;

	/*
	Method: isConscious
	Returns true if this unit is conscious, false otherwise.
	Despawned unit is always considered conscious.

	Returns: Bool
	*/
	public METHOD(isConscious)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		private _object = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (_object isEqualTo objNull) then {
			// Unit is despawned
			true
		} else {
			!(_object getVariable ["ACE_isUnconscious", false])
		};
	ENDMETHOD;

	//                          I S   S P A W N E D
	/*
	Method: isSpawned
	Checks if given unit is currently spawned or not

	Returns: bool, true if the unit is spawned
	*/
	public METHOD(isSpawned)
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		private _return = !( isNull (_data select UNIT_DATA_ID_OBJECT_HANDLE));
		_return
	ENDMETHOD;

	public METHOD(isDamaged)
		params [P_THISOBJECT];
		if(T_CALLM0("isSpawned")) then {
			pr _oh = T_CALLM0("getObjectHandle");
			damage _oh > 0.61 || { !T_CALLM0("isStatic") && { !canMove _oh || { [_oh] call AI_misc_fnc_isAnyWheelDamaged } } }
		} else {
			false
		}
	ENDMETHOD;

	public METHOD(canMove)
		params [P_THISOBJECT];
		if(T_CALLM0("isSpawned")) then {
			pr _oh = T_CALLM0("getObjectHandle");
			T_CALLM0("isStatic") || { canMove _oh && fuel _oh >= 0.01 }
		} else {
			true
		}
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |               I S   I N F A N T R Y   /   V E H I C L E   /   D R O N E
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	//                       I S   I N F A N T R Y
	/*
	Method: isInfantry
	Returns true if given <Unit> is infantry

	Returns: Bool
	*/
	public METHOD(isInfantry)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data#UNIT_DATA_ID_CAT == T_INF
	ENDMETHOD;

	//                       I S   V E H I C L E
	/*
	Method: isVehicle
	Returns true if given <Unit> is vehicle

	Returns: Bool
	*/
	public METHOD(isVehicle)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data#UNIT_DATA_ID_CAT == T_VEH
	ENDMETHOD;

	//                         I S   D R O N E
	/*
	Method: isDrone
	Returns true if given <Unit> is drone

	Returns: Bool
	*/
	public METHOD(isDrone)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data#UNIT_DATA_ID_CAT == T_DRONE
	ENDMETHOD;

	/*
	Method: isCargo
	Returns true if given <Unit> is cargo

	Returns: Bool
	*/
	public METHOD(isCargo)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data#UNIT_DATA_ID_CAT == T_CARGO
	ENDMETHOD;

	/*
	Method: isAir
	Returns true if given <Unit> is an air unit

	Returns: Bool
	*/
	public METHOD(isAir)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data#UNIT_DATA_ID_CAT == T_VEH && { _data#UNIT_DATA_ID_SUBCAT in T_VEH_air }
	ENDMETHOD;

	//                         I S   S T A T I C
	/*
	Method: isStatic
	Returns true if given <Unit> is one of static vehicles defined in Templates

	Returns: Bool
	*/
	public METHOD(isStatic)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		[_data#UNIT_DATA_ID_CAT, _data#UNIT_DATA_ID_SUBCAT] in T_static
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               B U I L D   R E S O U R C E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	public METHOD(setBuildResources)
		params [P_THISOBJECT, P_NUMBER("_value")];

		// Bail if we can't carry any build resources
		if (!T_CALLM0("canHaveBuildResources")) exitWith {};

		private _data = T_GETV("data");
		_data set [UNIT_DATA_ID_BUILD_RESOURCE, _value];
		if (T_CALLM0("isSpawned")) then {
			T_CALLM1("_setBuildResourcesSpawned", _value);
		} else {
			pr _dataList = _data#UNIT_DATA_ID_LIMITED_ARSENAL;
		};
	ENDMETHOD;

	public METHOD(getBuildResources)
		params [P_THISOBJECT];

		//OOP_INFO_0("GET BUILD RESOURCES");

		private _data = T_GETV("data");

		if (_data#UNIT_DATA_ID_CAT == T_INF) exitWith { 0 };

		private _return = if (T_CALLM0("isSpawned")) then {
			OOP_INFO_0("  spawned");
			T_CALLM0("_getBuildResourcesSpawned")
		} else {
			OOP_INFO_0("  despawned");
			_data select UNIT_DATA_ID_BUILD_RESOURCE
		};
		_return
		
	ENDMETHOD;

	public METHOD(addBuildResources)
		params [P_THISOBJECT, P_NUMBER("_value")];

		// Bail if a negative number is specified
		if(_value < 0) exitWith {};

		if (!T_CALLM0("canHaveBuildResources")) exitWith {};

		pr _resCurrent = T_CALLM0("getBuildResources");
		pr _resNew = _resCurrent + _value;
		T_CALLM1("setBuildResources", _resNew);
	ENDMETHOD;

	public METHOD(removeBuildResources)
		params [P_THISOBJECT, P_NUMBER("_value")];

		// Bail if a negative number is specified
		if (_value < 0) exitWith {};

		pr _resCurrent = T_CALLM0("getBuildResources");
		pr _resNew = _resCurrent - _value;
		if (_resNew < 0) then {_resNew = 0;};
		T_CALLM1("setBuildResources", _resNew);
	ENDMETHOD;

	METHOD(_setBuildResourcesSpawned)
		params [P_THISOBJECT, P_NUMBER("_value")];

		private _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {0};

		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		pr _nItemsNeeded = ceil (_value/_buildResPerMag);
		pr _dataList = _data#UNIT_DATA_ID_LIMITED_ARSENAL;
		if (count _dataList == 0) then {
			// There is no limited arsenal, it's a plain cargo container
			pr _magCargo = getMagazineCargo _hO;
			pr _index = _magCargo#0 find "vin_build_res_0";

			// Make the exact needed amount of items in the inventory
			pr _nItemsInCargo = 0;
			pr _nItemsToAdd = _nItemsNeeded;
			if (_index != -1) then { // If such items are already in the inventory
				pr _nItemsInCargo = _magCargo#1#_index;
				_nItemsToAdd = _nItemsNeeded - _nItemsInCargo;
			};
			if (_nItemsToAdd > 0) then {
				// Add items
				_hO addMagazineCargoGlobal ["vin_build_res_0", _nItemsToAdd];
			} else {
				if (_nItemsToAdd < 0) then {
					// Remove items
					[_hO, "vin_build_res_0", -_nItemsToAdd] call CBA_fnc_removeMagazineCargo;
				};
			};
		} else {
			// There is a limited arsenal
			_dataList = _hO getVariable "jna_dataList";
			pr _index = ["vin_build_res_0"] call jn_fnc_arsenal_itemType;
			pr _nItemsInArsenal = ["vin_build_res_0", _dataList#_index] call jn_fnc_arsenal_itemCount;
			
			// Make the exact needed amount of items in the inventory
			pr _nItemsToAdd = _nItemsNeeded;
			if (_nItemsInArsenal > 0) then { // If such items are already in the arsenal
				_nItemsToAdd = _nItemsNeeded - _nItemsInArsenal;
			};
			OOP_INFO_1(" >>> Adding build resources: %1", _nItemsToAdd);
			pr _index = ["vin_build_res_0"] call jn_fnc_arsenal_itemType;
			if (_nItemsToAdd > 0) then {
				// Add items
				[_hO, _index, "vin_build_res_0", _nItemsToAdd] call jn_fnc_arsenal_addItem;
			} else {
				if (_nItemsToAdd < 0) then {
					// Remove items
					[_hO, _index, "vin_build_res_0", -_nItemsToAdd] call jn_fnc_arsenal_removeItem;
				};
			};
		};
	ENDMETHOD;

	METHOD(_getBuildResourcesSpawned)
		params [P_THISOBJECT];

		//OOP_INFO_0("_getBuildResourcesSpawned");

		private _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {
			OOP_ERROR_0("getBuildResourcesSpawned: object handle is null");
			0
		};

		pr _dataList = _data#UNIT_DATA_ID_LIMITED_ARSENAL;
		if (count _dataList == 0) then {
			//OOP_INFO_0("  no limited arsenal at this unit");

			// There is no limited arsenal, it's a plain cargo container
			CALLSM1("Unit", "getVehicleBuildResources", _hO)
		} else {
			// There is a limited arsenal
			_dataList = _hO getVariable "jna_dataList";

			//OOP_INFO_1("  there is limited arsenal at this unit: %1", _dataList);

			pr _index = ["vin_build_res_0"] call jn_fnc_arsenal_itemType;
			_count = ["vin_build_res_0", _dataList#_index] call jn_fnc_arsenal_itemCount;

			//OOP_INFO_1("  amount of build res items: %1", _count);

			pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
			pr _return = _count*_buildResPerMag;

			//OOP_INFO_1("  return value: %1", _return);

			_return
		};
	ENDMETHOD;

	public METHOD(canHaveBuildResources)
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		pr _cat = _data#UNIT_DATA_ID_CAT;
		_cat != T_INF
	ENDMETHOD;

	public STATIC_METHOD(getInfantryBuildResources)
		params [P_THISCLASS, P_OBJECT("_hO")];
		pr _items = (uniformItems _hO) + (vestItems _hO) + (backpackitems _hO);
		pr _nItems = {_x == "vin_build_res_0"} count _items;
		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		_nItems*_buildResPerMag
	ENDMETHOD;

	public STATIC_METHOD(removeInfantryBuildResources)
		params [P_THISCLASS, P_OBJECT("_hO"), P_NUMBER("_value")];
		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		pr _nItemsToRemove = round (_value / _buildResPerMag);
		pr _i = 0;
		while {_i < _nItemsToRemove} do {
			_hO removeMagazine "vin_build_res_0";
			_i = _i + 1;
		};
	ENDMETHOD;

	public STATIC_METHOD(getVehicleBuildResources)
		params [P_THISCLASS, P_OBJECT("_hO")];

		pr _magCargo = getMagazineCargo _hO;
		pr _index = _magCargo#0 find "vin_build_res_0";
		if (_index != -1) then {
			pr _amount = _magCargo#1#_index;
			pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
			_amount * _buildResPerMag
		} else {
			0
		};
	ENDMETHOD;

	public STATIC_METHOD(removeVehicleBuildResources)
		params [P_THISCLASS, P_OBJECT("_hO"), P_NUMBER("_value")];

		// Bail if negative number is passed
		if (_value < 0) exitWith {};

		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		pr _nItemsToRemove = ceil (_value/_buildResPerMag);

		[_hO, "vin_build_res_0", _nItemsToRemove] call CBA_fnc_removeMagazineCargo;
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               G O A P
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	//                          G E T   S U B A G E N T S
	/*
	Method: getSubagents
	Returns subagents of this agent. For Unit it's an empty array since units have no subagents.

	Access: Used by AI class

	Returns: []
	*/
	public override METHOD(getSubagents)
		[] // A single unit has no subagents
	ENDMETHOD;

	//                           G E T   A I
	/*
	Method: getAI
	Returns the <AIUnit> object of this unit, or "" if it's not spawned

	Returns: <AIUnit>
	*/
	public override METHOD(getAI)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		_data select UNIT_DATA_ID_AI
	ENDMETHOD;

	/*
	Method: createDefaultCrew
	Creates default crew for a vehicle.
	The vehicle must be in a group.

	Parameters: _template

	_template - the template array to get unit's class name from.

	Returns: nil
	*/

	public METHOD(createDefaultCrew)
		params [P_THISOBJECT, P_ARRAY("_template") ];

		private _data = T_GETV("data");

		// Check if the unit is in a group
		private _group = _data select UNIT_DATA_ID_GROUP;
		if (_group == "") exitWith { diag_log format ["[Unit::createDefaultCrew] Error: cannot create crew for a unit which has no group: %1", T_CALLM("getData", [])] };

		private _className = _data select UNIT_DATA_ID_CLASS_NAME;
		private _catID = _data select UNIT_DATA_ID_CAT;
		private _subcatID = _data select UNIT_DATA_ID_SUBCAT;
		private _crewData = [_catID, _subcatID, _className] call t_fnc_getDefaultCrew;

		{
			private _unitCatID = _x select 0; // Unit's category
			private _unitSubcatID = _x select 1; // Unit's subcategory
			private _unitClassID = _x select 2;
			private _args = [_template, _unitCatID, _unitSubcatID, _unitClassID, _group]; // P_ARRAY("_template"), P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_NUMBER("_classID"), P_OOP_OBJECT("_group")
			private _newUnit = NEW("Unit", _args);
		} forEach _crewData;
	ENDMETHOD;

	//                             I S   E M P T Y
	/*
	Method: isEmpty
	Returns true if there are no units in this vehicle or it is not a vehicle

	Returns: bool
	*/
	public METHOD(isEmpty)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		private _oh = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		(count fullCrew _oh) == 0
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               L I M I T E D   A R S E N A L
	// | Methods for manipulating the limited arsenal
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	public METHOD(limitedArsenalEnable)
		params [P_THISOBJECT, P_BOOL("_enabled")];

		pr _data = T_GETV("data");

		// Bail if this item can't have a limited arsenal
		pr _catID = _data select UNIT_DATA_ID_CAT;
		if (_catID != T_CARGO) exitWith {};

		pr _dataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
		pr _arsenalAlreadyEnabled = count _dataList > 0;

		// Bail if object is already in this state
		if (_enabled && _arsenalAlreadyEnabled || (!_enabled) && (!_arsenalAlreadyEnabled) ) exitWith {};

		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;

		if (_enabled) then {
			pr _arsenalArray = call jn_fnc_arsenal_getEmptyArray; // I can't include defineCommon.inc because it includes files from arma and it makes SQF VM complain
			
			// Lets apply our civ settings from selected faction template
			private _civTemplate = CALLM1(gGameMode, "getTemplate", civilian);
			private _allArsenalItems = [];
			{
				_allArsenalItems = _allArsenalItems + _x;
			} forEach (_civTemplate#T_ARSENAL);
			// Init default unlimited items in the arsenal
			// Add uniforms and other things
			{
				pr _className = _x;
				pr _index = [_className] call jn_fnc_arsenal_itemType;
				(_arsenalArray#_index) pushBack [_className, -1];
			} forEach _allArsenalItems;

			_data set [UNIT_DATA_ID_LIMITED_ARSENAL, _arsenalArray]; // Limited Arsenal's empty array for items
			if (isNull _hO) then {
				// Object is currently despawned
			} else {
				// Object is currently spawned

				// Clear the inventory
				/// although, maybe we should move it into the arsenal?
				// For now I only care to clear the inventory when we create an ammo box

				// hopefully catch inventory wipe bug!
				if(_hO in allPlayers) exitWith {
					DUMP_CALLSTACK;
					OOP_ERROR_MSG("PLAYERINVBUG: limitedArsenalEnable _this:%1, _data:%2, _hO:%3", [_this ARG _data ARG _hO]);
					// Broadcast notification
					pr _msg = format["%1 just avoided the inventory clear bug, please send your .rpt to the developers so we can fix it!", name _hO];
					REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createCritical", [_msg], ON_CLIENTS, NO_JIP);
				};

				clearItemCargoGlobal _hO;
				clearWeaponCargoGlobal _hO;
				clearMagazineCargoGlobal _hO;
				clearBackpackCargoGlobal _hO;

				[_hO, _arsenalArray] call jn_fnc_arsenal_initPersistent;
			};
		} else {
			_data set [UNIT_DATA_ID_LIMITED_ARSENAL, []]; // This unit doesn't have arsenal any more
			if (isNull _hO) then {
				// Object is currently despawned
				// Do nothing
			} else {
				// Object is spawned
				// todo remove actions, kick players out of arsenal, etc ...
			};
		};
	ENDMETHOD;

	public METHOD(limitedArsenalEnabled)
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		pr _dataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
		count _dataList > 0
	ENDMETHOD;

	METHOD(limitedArsenalOnSpawn)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _dataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
		if (count _dataList > 0) then {
			// This object has a limited arsenal
			// We need to initialize the object

			// Restore the jna_dataList variable with the arsenal contents
			pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;

			// Initialize the limited arsenal
			[_hO, _dataList] call jn_fnc_arsenal_initPersistent;

			// Make the object movable again for the Build UI
			CALLSM2("BuildUI", "setObjectMovable", _hO, true);

			true
		} else {
			false
		}
	ENDMETHOD;

	METHOD(limitedArsenalOnDespawn)
		params [P_THISOBJECT];

		T_CALLM0("limitedArsenalSyncToUnit");
	ENDMETHOD;

	// This method must synchronize Unit OOP object's data fields to match those of the 'real' unit
	METHOD(limitedArsenalSyncToUnit)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _dataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
		if (count _dataList > 0) then {
			// This object has a limited arsenal
			// We need to save data

			pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
			pr _dataList = _hO getVariable "jna_dataList";
			if (isNil "_dataList") exitWith {
				OOP_ERROR_2("Limited Arsenal was not initialized for unit: %1: %2", _thisObject, _dataList);
			};
			_data set [UNIT_DATA_ID_LIMITED_ARSENAL, _dataList];
		};
	ENDMETHOD;

	// Gets JNA data list depending on the spawn state of the unit
	public METHOD(limitedArsenalGetDataList)
		params [P_THISOBJECT];
		pr _data = T_GETV("data");

		// Bail if arsenal is not enabled at this unit
		pr _dataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
		if (count _dataList == 0) exitWith { [] };

		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) then {
			_dataList
		} else {
			_hO getVariable "jna_dataList";
		};
	ENDMETHOD;

	// Removes items from the arsenal
	public METHOD(limitedArsenalRemoveItem)
		params [P_THISOBJECT, P_STRING("_item"), P_NUMBER("_amount")];
		pr _index = _item call jn_fnc_arsenal_itemType;
		pr _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) then {
			// It's despawned
			// Remove it from the array
			pr _dataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
			_dataList set [_index, [_dataList select _index, [_item, _amount]] call jn_fnc_common_array_remove];
		} else {
			// It's spawned
			// Use general arsenal code
			CRITICAL_SECTION { // Because our code runs scheduled
				[_hO, _index, _item, 1] call jn_fnc_arsenal_removeItem;
			};
		};
	ENDMETHOD;

	// - - - - STORAGE - - - - -

	public override METHOD(serializeForStorage)
		params [P_THISOBJECT];

		// Need to do this before copying "data"
		if (T_CALLM0("isSpawned")) then {
			// Save the inventory (for cargo and vics)
			T_CALLM0("saveInventory");
			T_CALLM0("limitedArsenalSyncToUnit");
		};

		pr _data = +T_GETV("data");

		if (T_CALLM0("isSpawned")) then {
			// Set the pos, vector dir and up, location
			pr _objectHandle = _data#UNIT_DATA_ID_OBJECT_HANDLE;
			pr _posATL = getPosATL _objectHandle;
			pr _dirAndUp = [vectorDir _objectHandle, vectorUp _objectHandle];
			pr _gar = _data#UNIT_DATA_ID_GARRISON;
			pr _loc = if (_gar != NULL_OBJECT) then {CALLM0(_gar, "getLocation")} else {NULL_OBJECT};
			_data set [UNIT_DATA_ID_POS_ATL, _posATL];
			_data set [UNIT_DATA_ID_VECTOR_DIR_UP, _dirAndUp];
			_data set [UNIT_DATA_ID_LOCATION, _loc];
		};

		_data set [UNIT_DATA_ID_OBJECT_HANDLE, 0];
		_data set [UNIT_DATA_ID_OWNER, 0];
		_data set [UNIT_DATA_ID_MUTEX, 0];
		_data set [UNIT_DATA_ID_AI, 0];

		// Filter inventory
		// Array of patterns of items we do not want to save in inventory
		pr _itemsNoSave = [
			"vin_tablet_",
			"vin_document_"
		];

		pr _inv = _data#UNIT_DATA_ID_INVENTORY;
		{
			pr _invArray = _x; // Array of [item, count]
			_inv set [_foreachindex, _invArray select { pr _className = _x#0; _itemsNoSave findIf {_x in _className} == -1}];
		} forEach _inv;
		///

		//diag_log _data;

		_data 
	ENDMETHOD;

	public override METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial")];
		_serial set [UNIT_DATA_ID_OWNER, 2]; // Server
		_serial set [UNIT_DATA_ID_MUTEX, MUTEX_NEW()];
		_serial set [UNIT_DATA_ID_OBJECT_HANDLE, objNull];
		_serial set [UNIT_DATA_ID_AI, ""];

		// Check class exists, if not re-resolve it from the cat and sub-cat if possible
		private _class = _serial#UNIT_DATA_ID_CLASS_NAME;
		#ifndef _SQF_VM
		if(!isClass (configFile >> "CfgVehicles" >> _class)) then {
			private _garrison = _serial#UNIT_DATA_ID_GARRISON;
			private _template = if(IS_NULL_OBJECT(_garrison)) then { "" } else { CALLM0(_garrison, "getTemplate") };
			if(!(_template isEqualTo "")) then {
				// Select a new random class/loadout
				private _catID = _serial#UNIT_DATA_ID_CAT;
				private _subcatID = _serial#UNIT_DATA_ID_SUBCAT;
				private _newClass = [_template, _catID, _subcatID, -1] call t_fnc_select;

				// Check if the class is actually a custom loadout
				pr _loadout = "";
				if ([_newClass] call t_fnc_isLoadout) then {
					_loadout = _newClass;
					_newClass = _template # _catID # 0 # 0; // Default class name from the template
				};
				_serial set [UNIT_DATA_ID_CLASS_NAME, _newClass];
				_serial set [UNIT_DATA_ID_LOADOUT, _loadout];

				OOP_WARNING_MSG("Class %1 no longer exists, using %2 instead", [_class ARG _newClass]);
			} else {
				OOP_ERROR_MSG("Class %1 no longer exists, and garrison template couldn't be found, so no automatic replacement can happen", [_class]);
			};
		};
		#endif
		FIX_LINE_NUMBERS()

		T_SETV("data", _serial);

		true
	ENDMETHOD;

	public STATIC_METHOD(saveStaticVariables)
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		pr _all = GETSV("Unit", "all");
		CALLM2(_storage, "save", "Unit_all", +_all);
	ENDMETHOD;

	public STATIC_METHOD(loadStaticVariables)
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		pr _all = CALLM1(_storage, "load", "Unit_all");
		SETSV("Unit", "all", +_all);
	ENDMETHOD;

ENDCLASS;

if (isNil {GETSV("Unit", "all")} ) then {
	SETSV("Unit", "all", []);
};

#ifdef _SQF_VM

Test_group_args = [WEST, 0]; // Side, group type
Test_unit_args = [tNATO, T_INF, T_INF_LMG, -1];

["Unit.new", {
	private _group = NEW("Group", Test_group_args);
	private _obj = NEW("Unit", Test_unit_args + [_group]);
	private _class = OBJECT_PARENT_CLASS_STR(_obj);
	!(isNil "_class")
}] call test_AddTest;

["Unit.save and load", {
	private _group = NEW("Group", Test_group_args);
	private _unit = NEW("Unit", Test_unit_args + [_group]);
	pr _storage = NEW("StorageProfileNamespace", []);
	CALLM1(_storage, "open", "testRecordUnit");
	CALLM1(_storage, "save", _unit);
	CALLSM1("Unit", "saveStaticVariables", _storage);
	DELETE(_unit);
	CALLSM1("Unit", "loadStaticVariables", _storage);
	CALLM1(_storage, "load", _unit);

	["Object loaded", CALLM0(_unit, "getCategory") == T_INF ] call test_Assert;

	true
}] call test_AddTest;

#endif
