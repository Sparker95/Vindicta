#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "Main.rpt"
#include "Unit.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\Group\Group.hpp"

/*
Class: Unit
A virtualized Unit is a man, vehicle or a drone (or a cargo box!) which can be spawned or not spawned.

Author: Sparker
10.06.2018
*/

#define pr private

Unit_fnc_EH_Killed = compile preprocessFileLineNumbers "Unit\EH_Killed.sqf";
Unit_fnc_EH_handleDamageInfantry = compile preprocessFileLineNumbers "Unit\EH_handleDamageInfantry.sqf";
Unit_fnc_EH_GetIn = compile preprocessFileLineNumbers "Unit\EH_GetIn.sqf";
Unit_fnc_EH_GetOut = compile preprocessFileLineNumbers "Unit\EH_GetOut.sqf";
Unit_fnc_EH_aceCargoLoaded = compile preprocessFileLineNumbers "Unit\EH_aceCargoLoaded.sqf";
Unit_fnc_EH_aceCargoUnloaded = compile preprocessFileLineNumbers "Unit\EH_aceCargoUnloaded.sqf";

// Add CBA ACE event handler for loading cargo
#ifndef _SQF_VM
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
#endif

CLASS(UNIT_CLASS_NAME, "Storable")
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
	_weapons - array with weapons to give to this unit, for format check Unit.hpp. Can be an empty array, then unit will have standard weapons from the config or loadout.
	*/

	METHOD("new") {
		params [P_THISOBJECT, ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]], ["_hO", objNull], ["_weapons", []]];

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

		if (!_valid) exitWith { SET_MEM(_thisObject, "data", []);
			diag_log format ["[Unit::new] Error: created invalid unit: %1", _this];
			DUMP_CALLSTACK
		};
		// Check group
		if(_group == "" && _catID == T_INF && isNull _hO) exitWith { diag_log "[Unit] Error: men must be added with a group!";};

		// If a random class was requested to be added
		private _class = "";
		if (isNull _hO) then {
			if(_classID == -1) then {
				private _classData = [_template, _catID, _subcatID] call t_fnc_selectRandom;
				_class = _classData select 0;
			} else {
				_class = [_template, _catID, _subcatID, _classID] call t_fnc_select;
			};
		} else {
			_class = typeOf _hO;
		};

		OOP_INFO_MSG("class = %1, _this = %2", [_class ARG _this]);

		// Check if the class is actually a custom loadout
		pr _loadout = "";
		if ([_class] call t_fnc_isLoadout) then {
			_loadout = _class;
			_class = _template select _catID select 0 select 0; // Default class name from the template
		};

		// Create the data array
		private _data = UNIT_DATA_DEFAULT;
		_data set [UNIT_DATA_ID_CAT, _catID];
		_data set [UNIT_DATA_ID_SUBCAT, _subcatID];
		_data set [UNIT_DATA_ID_CLASS_NAME, _class];
		_data set [UNIT_DATA_ID_MUTEX, MUTEX_NEW()];
		_data set [UNIT_DATA_ID_GROUP, ""];
		_data set [UNIT_DATA_ID_LOADOUT, _loadout];
		_data set [UNIT_DATA_ID_WEAPONS, _weapons];
		_data set [UNIT_DATA_ID_INVENTORY, []];
		if (!isNull _hO) then {
			_data set [UNIT_DATA_ID_OBJECT_HANDLE, _hO];
		};
		SET_MEM(_thisObject, "data", _data);

		// Push the new object into the array with all units
		private _allArray = GET_STATIC_MEM(UNIT_CLASS_NAME, "all");
		_allArray pushBack _thisObject;

		// Add this unit to a group
		if(_group != "") then {
			CALL_METHOD(_group, "addUnit", [_thisObject]);
		};

		// Initialize variables, event handlers and other things
		if (!isNull _hO) then {
			_hO enableWeaponDisassembly false; // Disable weapon disassmbly
			CALLM0(_thisObject, "initObjectVariables");
			CALLM0(_thisObject, "initObjectEventHandlers");
			CALLM0(_thisObject, "initObjectDynamicSimulation");
			CALLM0(_thisObject, "applyInfantryWeapons");
		};

	} ENDMETHOD;


	//                             D E L E T E
	/*
	Method: delete
	Deletes this object, despawns the physical unit if neccessary.
	*/

	METHOD("delete") {
		params[P_THISOBJECT];

		OOP_INFO_0("DELETE UNIT");

		private _data = GET_MEM(_thisObject, "data");

		//Despawn this unit if it was spawned
		if (T_CALLM0("isSpawned")) then {
			CALLM(_thisObject, "despawn", []);
		};

		// Remove the unit from its group
		private _group = _data select UNIT_DATA_ID_GROUP;
		if(_group != "") then {
			CALL_METHOD(_group, "removeUnit", [_thisObject]);
		};

		// Remove this unit from its garrison
		private _gar = _data select UNIT_DATA_ID_GARRISON;
		if (_gar != "") then {
			CALL_METHOD(_gar, "removeUnit", [_thisObject]);
		};

		//Remove this unit from array with all units
		private _allArray = GET_STATIC_MEM(UNIT_CLASS_NAME, "all");
		_allArray deleteAt (_allArray find _thisObject);
		SET_MEM(_thisObject, "data", nil);
	} ENDMETHOD;



	//                              I S   V A L I D
	/*
	Method: isValid
	Checks if the created unit is valid(check the constructor code)
	After creating a new unit, make sure it's valid before adding it to other objects.

	Returns: bool
	*/
	METHOD("isValid") {
		params [P_THISOBJECT];
		private _data = GET_MEM(_thisObject, "data");
		pr _return = if (isNil "_data") then {
			false
		} else {
			//Return true if the data array is of the correct size
			( (count _data) == UNIT_DATA_SIZE)
		};

		if (!_return) then {OOP_ERROR_1("INVALID UNIT, _data: %1", _data);};

		_return
	} ENDMETHOD;



	//                            C R E A T E   A I
	/*
	Method: createAI
	Creates an AI object for this unit after it has been spawned or changed owner.

	Parameters: _AIClassName

	_AIClassName - class name of <AI> object to create

	Access: meant for internal use!

	Returns: Created <AI> object
	*/
	METHOD("createAI") {
		params [P_THISOBJECT, ["_AIClassName", "", [""]]];

		// Create an AI object of the unit
		// Don't start the brain, because its process method will be called by
		// its group's AI brain
		pr _data = GETV(_thisObject, "data");
		pr _AI = NEW(_AIClassName, [_thisObject]);
		_data set [UNIT_DATA_ID_AI, _AI];

		// Return
		_AI
	} ENDMETHOD;



	//                              S P A W N
	/*
	Method: spawn
	Spawns given unit at specified coordinates. Will take care if the unit has already been spawned. Creates an AI object attached to this unit.

	Parameters: _pos, _dir

	_pos - position
	_dir - direction

	Returns: nil
	*/
	METHOD("spawn") {
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
				pr _vectorDir = _dirAndUpPrev#0;
				pr _dirToCheck = (_vectorDir#0) atan2 (_vectorDir#1);

				pr _prevPosSafe = CALLSM3("Location", "isPosSafe", _posATLPrev, _dirToCheck, _className);
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
						pr _className = T_CALLM0("getClassName");
						CALLSM2("Location", "findSafeSpawnPos", _className, _pos)
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
						private _groupHandle = CALL_METHOD(_group, "getGroupHandle", []);
						if (isNull _groupHandle) then {
							OOP_ERROR_0("Spawn: group handle is null!");
						};
						//diag_log format ["---- Received group of side: %1", side _groupHandle];
						_objectHandle = _groupHandle createUnit [_className, _pos, [], 10, "FORM"];
						
						// Set loadout if requited
						pr _loadout = _data select UNIT_DATA_ID_LOADOUT;
						if (_loadout != "") then {
							[_objectHandle, _loadout] call t_fnc_setUnitLoadout;
						};

						if (isNull _objectHandle) then {
							OOP_ERROR_1("Created infantry unit is Null. Unit data: %1", _data);
							_objectHandle = _groupHandle createUnit ["I_Protagonist_VR_F", _pos, [], 10, "FORM"];
						};
						[_objectHandle] joinSilent _groupHandle; //To force the unit join this side
						_objectHandle allowFleeing 0;
						
						_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];

						//_objectHandle disableAI "PATH";
						//_objectHandle setUnitPos "UP"; //Force him to not sit or lay down

						pr _AI = CALLM1(_thisObject, "createAI", "AIUnitInfantry");

						pr _groupType = CALLM0(_group, "getType");

						// Give weapons to the unit (if he has special weapons)
						CALLM0(_thisObject, "applyInfantryWeapons");

						// Set unit skill
						_objectHandle setSkill ["aimingAccuracy", 0.6];	// Aiming and precision
						_objectHandle setSkill ["aimingShake", 0.6];
						_objectHandle setSkill ["aimingSpeed", 0.8];
						_objectHandle setSkill ["commanding", 1];		// Everything else
						_objectHandle setSkill ["courage", 0.5];
						//_objectHandle setSkill ["endurance", 0.8];
						_objectHandle setSkill ["general", 1];
						_objectHandle setSkill ["reloadSpeed", 0.5];
						_objectHandle setSkill ["spotDistance", 1];
						_objectHandle setSkill ["spotTime", 1];

						// Set unit insignia
						// todo find a better way to handle this?
						if ( (side _groupHandle) == CALLM0(gGameMode, "getPlayerSide")) then {
							[_objectHandle, "Vindicta"] call BIS_fnc_setUnitInsignia;
						};
					};
					case T_VEH: {

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

						_objectHandle allowDamage false;
						private _spawnCheckEv = _objectHandle addEventHandler ["EpeContactStart", {
							params ["_object1", "_object2", "_selection1", "_selection2", "_force"];
							OOP_INFO_MSG("Vehicle %1 failed spawn check, collided with %2 force %3!", [_object1 ARG _object2 ARG _force]);
							// if(_force > 100) then {
							// 	deleteVehicle _object1;
							// };
						}];

						[_thisObject, _objectHandle, _group, _spawnCheckEv, _data] spawn {
							params ["_thisObject", "_objectHandle", "_group", "_spawnCheckEv", "_data"];
							sleep 2;
							_objectHandle allowDamage true;
							// If it survived spawning
							if (alive _objectHandle) then {
								OOP_INFO_MSG("Vehicle %1 passed spawn check, did not explode!", [_objectHandle]);
								_objectHandle removeEventHandler ["EpeContactStart", _spawnCheckEv];
							} else {
								
							};
						};

						_objectHandle enableWeaponDisassembly false; // Disable weapon disassmbly

						_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];
						CALLM1(_thisObject, "createAI", "AIUnitVehicle");
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

						_objectHandle allowDamage false;
						private _spawnCheckEv = _objectHandle addEventHandler ["EpeContactStart", {
							params ["_object1", "_object2", "_selection1", "_selection2", "_force"];
							OOP_INFO_MSG("Vehicle %1 failed spawn check, collided with %2 force %3!", [_object1 ARG _object2 ARG _force]);
							// if(_force > 100) then {
							// 	deleteVehicle _object1;
							// };
						}];

						[_thisObject, _objectHandle, _group, _spawnCheckEv, _data] spawn {
							params ["_thisObject", "_objectHandle", "_group", "_spawnCheckEv", "_data"];
							sleep 2;
							_objectHandle allowDamage true;
							// If it survived spawning
							if (alive _objectHandle) then {
								OOP_INFO_MSG("Vehicle %1 passed spawn check, did not explode!", [_objectHandle]);
								_objectHandle removeEventHandler ["EpeContactStart", _spawnCheckEv];
							} else {
								
							};
						};

						_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];

						// Initialize limited arsenal
						T_CALLM0("limitedArsenalOnSpawn");

						//CALLM1(_thisObject, "createAI", "AIUnitVehicle");		// A box probably has no AI?			
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
				CALLM0(_thisObject, "initObjectVariables");

				// Initialize event handlers
				CALLM0(_thisObject, "initObjectEventHandlers");

				// Initialize dynamic simulation
				CALLM0(_thisObject, "initObjectDynamicSimulation");
			}; // CRITICAL_SECTION

			// !! Functions below might need to lock the garrison mutex, so we release the critical section

			// Try and restore saved inventory, otherwise generate one
			if(!T_CALLM0("restoreInventory")) then {
				// Initialize cargo if there is no limited arsenal
				CALLM0(_thisObject, "initObjectInventory");
			};

			// Set build resources
			if (_buildResources > 0 && {T_CALLM0("canHaveBuildResources")}) then {
				T_CALLM1("_setBuildResourcesSpawned", _buildResources);
			};
					
			// Give intel to this unit

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
	} ENDMETHOD;

	/*
	Method: initObjectVariables
	Sets variables of unit's object handle.

	Returns: nil
	*/
	METHOD("initObjectVariables") {
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

	} ENDMETHOD;

	/*
	Method: initObjectVariables
	Deletes variables of unit's object handle.

	Returns: nil
	*/
	METHOD("deinitObjectVariables") {
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
	} ENDMETHOD;

	/*
	Method: initObjectEventHandlers
	Adds event handlers to unit.

	Returns: nil
	*/
	METHOD("initObjectEventHandlers") {
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		pr _catID = _data select UNIT_DATA_ID_CAT;

		// Killed
		if (isNil {_hO getVariable UNIT_EH_KILLED_STR}) then {
			pr _ehid = _hO addEventHandler ["Killed", Unit_fnc_EH_Killed];
			_hO setVariable [UNIT_EH_KILLED_STR, _ehid];
		};
		
		// HandleDamage for infantry
		/* // Disabled for now, let's see if it changed anything
		//diag_log format ["Trying to add damage EH. Objects owner: %1, my clientOwner: %2", owner _hO, clientOwner];
		if ((_data select UNIT_DATA_ID_CAT == T_INF) &&	// Only to infantry
			{owner _hO in [0, clientOwner]} &&			// We only add handleDamage to the units which we own. 0 is owner ID of a just-created unit
			{!(_hO isEqualTo player)}) then { 			// Ignore player
			if (isNil {_hO getVariable UNIT_EH_DAMAGE_STR}) then {
				_hO removeAllEventHandlers "handleDamage";
				pr _ehid = _hO addEventHandler ["handleDamage", Unit_fnc_EH_handleDamageInfantry];
				//diag_log format ["Added damage event handler: %1", _thisObject];
				_hO setVariable [UNIT_EH_DAMAGE_STR, _ehid];
			};
		};
		*/

		// GetIn, if it's a vehicle
		if (_catID == T_VEH) then {
			_hO addEventHandler ["GetIn", Unit_fnc_EH_GetIn];
			_hO addEventHandler ["GetOut", Unit_fnc_EH_GetOut];
		};
	} ENDMETHOD;

	METHOD("initObjectDynamicSimulation") {
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
	} ENDMETHOD;

	Unit_fnc_hasInventory = {
		//check if object has inventory
		pr _className = typeOf _this;
		pr _tb = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxbackpacks");
		pr _tm = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxmagazines");
		pr _tw = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxweapons");
		(_tb > 0  || _tm > 0 || _tw > 0)
	};

	METHOD("restoreInventory") {
		params [P_THISOBJECT];
		T_PRVAR(data);

		// Bail if not spawned
		pr _hO = _data#UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith { false };

		pr _savedInventory = if(count _data > UNIT_DATA_ID_INVENTORY) then {
			_data#UNIT_DATA_ID_INVENTORY
		} else {
			[]
		};
		if ((_hO call Unit_fnc_hasInventory) && count _savedInventory == 4) then {
			diag_log format["RESTORING INV FOR %1: %2", _hO, _savedInventory];
			// Clear cargo
			clearWeaponCargoGlobal _hO;
			clearItemCargoGlobal _hO;
			clearMagazineCargoGlobal _hO;
			clearBackpackCargoGlobal _hO;
			//weapons
			{
				_hO addWeaponCargoGlobal _x;
			} forEach _savedInventory#0;
			//items
			{
				_hO addItemCargoGlobal _x;
			} forEach _savedInventory#1;
			//magazines
			{
				_x params ["_item", "_amount"];
				private _count = getNumber (configfile >> "CfgMagazines" >> _item >> "count");
				private _full = floor (_amount / _count);
				if(_full > 0) then {
					_hO addMagazineAmmoCargo [_item, _full, _count];
				};
				private _remainder = floor(_amount % _count);
				if(_remainder > 0) then {
					_hO addMagazineAmmoCargo [_item, 1, _remainder];
				};
			} forEach _savedInventory#2;
			//backpack
			{
				_hO addBackpackCargoGlobal _x;
			} forEach _savedInventory#3;

			true
		} else {
			false
		}
	} ENDMETHOD;

	METHOD("saveInventory") {
		params [P_THISOBJECT];
		T_PRVAR(data);

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
			diag_log format["SAVED INV FOR %1: %2", _hO, _savedInventory];
			_data set [UNIT_DATA_ID_INVENTORY, _savedInventory];
		};
	} ENDMETHOD;

	METHOD("initObjectInventory") {
		params [P_THISOBJECT];

		pr _data = T_GETV("data");

		// Bail if not spawned
		pr _hO = _data#UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {};

		pr _catid = _data select UNIT_DATA_ID_CAT;
		if (_catID in [T_VEH, T_DRONE, T_CARGO]) then {
			// Clear cargo
			clearItemCargoGlobal _hO;
			clearWeaponCargoGlobal _hO;
			clearMagazineCargoGlobal _hO;
			clearBackpackCargoGlobal _hO;

			// Bail if there is a limited arsenal
			pr _arsenalDataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
			if ((count _arsenalDataList) != 0) exitWith {};

			// Otherwise fill the ammo box with stuff from the template
			pr _gar = _data select UNIT_DATA_ID_GARRISON;
			if (_gar == "") exitWith {};
			pr _nInf = CALLM0(_gar, "countInfantryUnits");
			pr _nVeh = CALLM0(_gar, "countVehicleUnits");
			pr _nCargo = CALLM0(_gar, "countCargoUnits");
			pr _tName = CALLM0(_gar, "getTemplateName");
			if (_tName == "") exitWith {};

			// Add stuff to cargo from the template
			pr _t = [_tName] call t_fnc_getTemplate;
			pr _tInv = _t#T_INV;

			// Some number which scales the amount of items in this box
			pr _nGuns = 1 * _nInf / ((_nVeh + _nCargo) max 1);

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

			// Add items
			pr _arr = [	[T_INV_primary_items, 0.6*_nGuns], [T_INV_secondary_items, 0.6*_nGuns],
						[T_INV_handgun_items, 0.1*_nGuns], [T_INV_items, 0.3*_nGuns]]; // [_subcatID, num. attempts]
			{
				_x params ["_subcatID", "_n"];

				if (count (_tInv#_subcatID) > 0) then { // If there are any items in this subcategory

					// Randomize _n
					_n = round (random [0.2*_n, _n, 1.8*_n]);
					pr _items = _tInv#_subcatID;
					for "_i" from 0 to (_n-1) do {
						_hO addItemCargoGlobal [selectRandom _items, round (1 + random 1)];
					};
				};
			} forEach _arr;

			_hO addItemCargoGlobal ["FirstAidKit", 5 + round (random 5)];
			_hO addItemCargoGlobal ["ItemGPS", 1 + round (random 2)];
			_hO addItemCargoGlobal ["ToolKit", random [1, 2, 5]];
			_hO addBackpackCargoGlobal ["B_TacticalPack_blk", (round random 2)]; // Backpacks

			// Customize non-civilian containers
			if (CALLM0(_data#UNIT_DATA_ID_GARRISON, "getSide") != CIVILIAN) then {
				// Add some maps and radios for non-civilian units
				{
					_hO addItemCargoGlobal [_x, 4 + ( ceil random 10)];
				} forEach ["ItemMap", "ItemCompass", "ItemRadio" ];

				// Add ACRE Radios
				// We probably want them in all vehicles, not only in boxes
				if (isClass (configfile >> "CfgPatches" >> "acre_main")) then {
					// Array with item class name, count
					pr _ACREclassNames = [
										["ACRE_SEM52SL",2],
										["ACRE_SEM70",4],
										["ACRE_PRC77",1],
										["ACRE_PRC343",6],
										["ACRE_PRC152",3],
										["ACRE_PRC148",3],
										["ACRE_PRC117F",1],
										["ACRE_VHF30108SPIKE",1],
										["ACRE_VHF30108",3],
										["ACRE_VHF30108MAST",1]
									];
					{
						_x params ["_itemName", "_itemCount"];
						_hO addItemCargoGlobal [_itemName, round (random [0.8*_itemCount, 1.4*_itemCount, 2*_itemCount])];
					} forEach _ACREclassNames;
				};

				// Add special items to cargo containers
				if (_catID == T_CARGO) then {
					// Add ACE medical items
					if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {
						{
							pr _itemName = getText (_x >> "name");
							pr _itemCount = getNumber (_x >> "count");
							_hO addItemCargoGlobal [_itemName, round (random [0.8*_itemCount, 1.4*_itemCount, 2*_itemCount])];
						} forEach ("true" configClasses (configfile >> "CfgVehicles" >> "ACE_medicalSupplyCrate_advanced" >> "TransportItems"));
					};

					// Add ACE misc items
					if (isClass (configfile >> "CfgPatches" >> "ace_common")) then {
						// Array with item class name, count
						// Exported from the ACE_Box_Misc
						// Then modified a bit
						pr _classNames = [
											//["ACE_muzzle_mzls_H",2],
											//["ACE_muzzle_mzls_B",2],
											//["ACE_muzzle_mzls_L",2],
											//["ACE_muzzle_mzls_smg_01",2],
											//["ACE_muzzle_mzls_smg_02",2],
											//["ACE_muzzle_mzls_338",5],
											//["ACE_muzzle_mzls_93mmg",5],
											//["ACE_HuntIR_monitor",5],
											//["ACE_acc_pointer_green",4],
											["ACE_UAVBattery",6],
											["ACE_wirecutter",4],
											["ACE_MapTools",12],
											["ACE_microDAGR",3],
											//["ACE_MX2A",6], // Thermal imager
											//["ACE_NVG_Gen1",6],
											//["ACE_NVG_Gen2",6],
											//["ACE_NVG_Gen4",6],
											//["ACE_NVG_Wide",6],
											//["ACE_optic_Hamr_2D",2],
											//["ACE_optic_Hamr_PIP",2],
											//["ACE_optic_Arco_2D",2],
											//["ACE_optic_Arco_PIP",2],
											//["ACE_optic_MRCO_2D",2],
											//["ACE_optic_SOS_2D",2],
											//["ACE_optic_SOS_PIP",2],
											//["ACE_optic_LRPS_2D",2],
											//["ACE_optic_LRPS_PIP",2],
											["ACE_Altimeter",3],
											["ACE_Sandbag_empty",10],
											["ACE_SpottingScope",1],
											//["ACE_SpraypaintBlack",5],
											//["ACE_SpraypaintRed",5],
											//["ACE_SpraypaintBlue",5],
											//["ACE_SpraypaintGreen",5],
											["ACE_EntrenchingTool",8],
											["ACE_Tripod",1],
											//["ACE_Vector",6],
											//["ACE_Yardage450",4],
											//["ACE_IR_Strobe_Item",12],
											["ACE_CableTie",12],
											//["ACE_Chemlight_Shield",12],
											["ACE_DAGR",3],
											["ACE_Clacker",12],
											["ACE_M26_Clacker",6],
											["ACE_DefusalKit",4],
											//["ACE_Deadmanswitch",6],
											//["ACE_Cellphone",10],
											//["ACE_Flashlight_MX991",12],
											//["ACE_Flashlight_KSF1",12],
											//["ACE_Flashlight_XL50",12],
											["ACE_EarPlugs",20],
											["ACE_Kestrel4500",2],
											["ACE_ATragMX",6],
											["ACE_RangeCard",6]
										];
						{
							_x params ["_itemName", "_itemCount"];
							_hO addItemCargoGlobal [_itemName, round (random [0.8*_itemCount, 1.4*_itemCount, 2*_itemCount])];
						} forEach _classNames;
					};

					// Add ADV medical items
					// Defibrilator
					if (isClass (configfile >> "CfgPatches" >> "adv_aceCPR")) then {
						_hO addItemCargoGlobal ["adv_aceCPR_AED", random [4, 8, 12]];
					};
					// Splint
					if (isClass (configfile >> "CfgPatches" >> "adv_aceSplint")) then {
						_hO addItemCargoGlobal ["adv_aceSplint_splint", random [10, 20, 30]];
					};

					// What else?
				};
			};

			// Add vests
			pr _nVests = ceil (0.5*_nGuns + (random (0.5*_nGuns)));
			pr _vests = _tInv#T_INV_vests;
			for "_i" from 0 to _nVests do {
				_hO addItemCargoGlobal [selectRandom _vests, 1];
			};

			// Add backpacks
			pr _nBackpacks = ceil (0.5*_nGuns + (random (0.5*_nGuns)));
			pr _backpacks = _tInv#T_INV_backpacks;
			for "_i" from 0 to _nVests do {
				_hO addBackpackCargoGlobal [selectRandom _backpacks, 1];
			};
		} else {
			if (random 100 <= 5) then {
				_hO addItemToUniform "vin_pills";
				_hO addItemToUniform "vin_pills";
				_hO addItemToUniform "vin_pills";
			};
		};
	} ENDMETHOD;

	//                            D E S P A W N
	/*
	Method: despawn
	Despawns given unit. Deletes the AI object attached to this unit.

	Parameters: _pos, _dir

	_pos - position
	_dir - direction

	Returns: nil
	*/
	METHOD("despawn") {
		params [P_THISOBJECT];

		OOP_INFO_0("DESPAWN");

		//Unpack data
		private _data = GET_MEM(_thisObject, "data");
		private _mutex = _data select UNIT_DATA_ID_MUTEX;

		//Lock the mutex
		//MUTEX_LOCK(_mutex);

		//Unpack more data...
		private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (!(isNull _objectHandle)) then { //If it's been spawned before
			// Stop AI, sensors, etc
			pr _AI = _data select UNIT_DATA_ID_AI;
			// Some units are brainless. Check if the unit had a brain.
			if (_AI != "") then {
				CALLM2(gMessageLoopGroupManager, "postMethodSync", "deleteObject", [_AI]);
				_data set [UNIT_DATA_ID_AI, ""];
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

			// Set the pos, vector dir and up, location
			pr _posATL = getPosATL _objectHandle;
			pr _dirAndUp = [vectorDir _objectHandle, vectorUp _objectHandle];
			pr _gar = _data#UNIT_DATA_ID_GARRISON;
			pr _loc = if (_gar != "") then {CALLM0(_gar, "getLocation")} else {""};
			_data set [UNIT_DATA_ID_POS_ATL, _posATL];
			_data set [UNIT_DATA_ID_VECTOR_DIR_UP, _dirAndUp];
			_data set [UNIT_DATA_ID_LOCATION, _loc];

			// Delete the vehicle
			deleteVehicle _objectHandle;
			private _group = _data select UNIT_DATA_ID_GROUP;
			//if (_group != "") then { CALL_METHOD(_group, "handleUnitDespawned", [_thisObject]) };
			_data set [UNIT_DATA_ID_OBJECT_HANDLE, objNull];
		} else {
			OOP_ERROR_0("Already despawned");
			DUMP_CALLSTACK;
		};
		//Unlock the mutex
		//MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;



	//                     S E T   V E H I C L E   R O L E
	/*
	Method: assignVehicleRole
	NYI

	Assigns the unit to a vehicle with specified vehicle role
	*/
	METHOD("setVehicleRole") {
		params [P_THISOBJECT, "_vehicle", "_vehicleRole"];
	} ENDMETHOD;


	//                         S E T   G A R R I S O N
	/*
	Method: setGarrison
	Sets the garrison this unit is attached to.

	Access: internal use! You must use Garrison::addUnit to add a unit to a garrison properly.

	Parameters: _garrison

	_garrison - the garrison object

	Returns: nil
	*/
	METHOD("setGarrison") {
		params [P_THISOBJECT, ["_garrison", "", [""]] ];

		OOP_INFO_1("SET GARRISON: %1", _garrison);

		private _data = GET_VAR(_thisObject, "data");
		_data set [UNIT_DATA_ID_GARRISON, _garrison];
	} ENDMETHOD;

	//                         S E T   G R O U P
	/*
	Method: setGroup
	Sets the group this unit is attached to.

	Access: internal use!

	Parameters: _garrison

	_garrison - the garrison object

	Returns: nil
	*/
	METHOD("setGroup") {
		params [P_THISOBJECT, ["_group", "", [""]] ];
		private _data = GET_VAR(_thisObject, "data");
		_data set [UNIT_DATA_ID_GROUP, _group];
	} ENDMETHOD;

	/*
	Method: applyWeapons
	Gives weapons to the unit from the weapons array of this unit
	*/
	METHOD("applyInfantryWeapons") {
		params [P_THISOBJECT];
		pr _data = GET_VAR(_thisObject, "data");

		// Bail if unit does not have special weapons
		pr _weapons = _data select UNIT_DATA_ID_WEAPONS;
		if (count _weapons == 0) exitWith {};

		// Bail if unit is not spawned
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {};

		// Remove all weapons
		removeAllWeapons this;

		// Remove all items from vest
		pr _vest = vest _hO;
		if (_vest == "") then { _vest = "V_Chestrig_oli"; }; // Default vest
		removeVest _hO;
		_hO addVest _vest;
			
		// Add main gun
		pr _primary = _weapons#UNIT_WEAPONS_ID_PRIMARY;
		if (_primary != "") then {
			pr _primaryMags = getArray (configfile >> "CfgWeapons" >> _primary >> "magazines");
			pr _mag = _primaryMags select 0;
			_hO addWeapon _primary;
			for "_i" from 0 to 8 do { _hO addItemToVest _mag; };
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
		pr _secondary = _weapons#UNIT_WEAPONS_ID_SECONDARY;
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
		if ( (primaryWeapon _hO) != "") then
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

	} ENDMETHOD;


	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// - - - - - - - - - - - - - - - - - - G E T   M E M B E R S - - - - - - - - - - - - - - - - - - -
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	//                         G E T   G A R R I S O N
	/*
	Method: getGarrison
	Returns the garrison this unit is attached to

	Returns: <Garrison>
	*/
	METHOD("getGarrison") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");

		// If unit is in a group, get the garrison of its group
		pr _group = _data select UNIT_DATA_ID_GROUP;
		if (_group != "") then {
			CALLM0(_group, "getGarrison")
		} else {
			// For ungrouped units, return the garrison of the unit
			_data select UNIT_DATA_ID_GARRISON
		};
	} ENDMETHOD;

	//                         G E T   O B J E C T   H A N D L E
	/*
	Method: getObjectHandle
	Returns the object handle of this unit if it's spawned, objNull otherwise.

	Returns: object handle of this unit, or objNull if it's not spawned
	*/
	METHOD("getObjectHandle") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_OBJECT_HANDLE
	} ENDMETHOD;

	/*
	Method: getClassName
	Returns class name of this unit

	Returns: String
	*/
	METHOD("getClassName") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CLASS_NAME
	} ENDMETHOD;

	/*
	Method: isPlayer
	Returns: true if the unit is a player
	*/
	METHOD("isPlayer") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		private _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		!(isNull _hO) && {_hO in allPlayers}
	} ENDMETHOD;

	//                        G E T   G R O U P
	/*
	Method: getGroup
	Returns the <Group> this unit is attached to.

	Returns: <Group>
	*/
	// Returns the group of this unit
	METHOD("getGroup") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_GROUP
	} ENDMETHOD;

	//                           G E T   A I
	/*
	Method: getAI
	Returns the <AIUnit> object of this unit, or "" if it's not spawned

	Returns: <AIUnit>
	*/
	METHOD("getAI") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_AI
	} ENDMETHOD;

	//                    G E T   M A I N   D A T A
	/*
	Method: getMainData
	Returns category ID, subcategory ID and class name of this unit

	Returns: array: [_catID, _subcatID, _className]
	*/
	METHOD("getMainData") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		[_data select UNIT_DATA_ID_CAT, _data select UNIT_DATA_ID_SUBCAT, _data select UNIT_DATA_ID_CLASS_NAME]
	} ENDMETHOD;
	
	//                    G E T   E F F I C I E N C Y
	/*
	Method: getEfficiency
	Returns efficiency vector of this unit

	Returns: Efficiency vector
	*/
	METHOD("getEfficiency") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		T_efficiency select (_data select UNIT_DATA_ID_CAT) select (_data select UNIT_DATA_ID_SUBCAT)
	} ENDMETHOD;

	//                        G E T   D A T A
	/*
	Method: getData

	Access: Meant for internal use since you can break the <Unit> object this way.

	Returns: the internal data array of this unit.
	*/
	METHOD("getData") {
		params [P_THISOBJECT];
		GET_VAR(_thisObject, "data")
	} ENDMETHOD;


	//                             G E T   P O S
	/*
	Method: getPos
	Returns position of this unit or [] if the unit is not spawned

	Returns: [x, y, z]
	*/
	METHOD("getPos") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		private _oh = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		getPos _oh
	} ENDMETHOD;

	/*
	Method: getDespawnLocation
	Returns the location this unit despawned at last time, or ""

	Returns: <Location> or ""
	*/
	METHOD("getDespawnLocation") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data#UNIT_DATA_ID_LOCATION
	} ENDMETHOD;

	/*
	Method: getCategory
	Returns category ID, number
	*/
	METHOD("getCategory") {
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		_data#UNIT_DATA_ID_CAT
	} ENDMETHOD;

	/*
	Method: getSubcategory
	Returns subcategory ID, number
	*/
	METHOD("getSubcategory") {
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		_data#UNIT_DATA_ID_SUBCAT
	} ENDMETHOD;

	//                     H A N D L E   K I L L E D
	/*
	Method: handleKilled
	Gets called when a unit is killed.
	*/
	METHOD("handleKilled") {
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
	} ENDMETHOD;

	// Some cargo was loaded into this unit
	METHOD("handleCargoLoaded") {
		params [P_THISOBJECT, P_OOP_OBJECT("_cargoUnit")];
		pr _AI = T_CALLM0("getAI");
		if (_AI != "") then {
			CALLM1(_AI, "addCargoUnit", _cargoUnit);
		};
	} ENDMETHOD;

	// Some cargo was unloaded from this unit
	METHOD("handleCargoUnloaded") {
		params [P_THISOBJECT, P_OOP_OBJECT("_cargoUnit")];
		pr _AI = T_CALLM0("getAI");
		if (_AI != "") then {
			CALLM1(_AI, "removeCargoUnit", _cargoUnit);
		};
	} ENDMETHOD;

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
	STATIC_METHOD("getUnitFromObjectHandle") {
		params [ ["_thisClass", "", [""]], ["_objectHandle", objNull, [objNull]] ];
		GET_UNIT_FROM_OBJECT_HANDLE(_objectHandle);
	} ENDMETHOD;

	/*
	Method: (static)createUnitFromObjectHandle
	NYI
	Creates a unit and instantly attaches it to provided object handle.

	Returns: <Unit>
	*/
	STATIC_METHOD("createUnitFromObjectHandle") {
	} ENDMETHOD;


	/*
	Method: (static)getRequiredCrew
	Returns amount of needed drivers and turret operators for all vehicles in this garrison.

	Parameters: _units

	_units - array of <Unit> objects

	Returns: [_nDrivers, _nTurrets, _nCargo]
	*/
	
	STATIC_METHOD("getRequiredCrew") {
		params ["_thisClass", ["_units", [], [[]]]];
		
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
	} ENDMETHOD;
	
	/*
	Function: (static)getCargoInfantryCapacity
	Returns how many units can be loaded as cargo by all the vehicles from _units
	
	Parameters: _units
	
	_units - array of <Unit> objects
	
	Returns: Number
	*/
	STATIC_METHOD("getCargoInfantryCapacity") {
		params ["_thisClass", ["_units", [], [[]]]];
		pr _unitsClassNames = _units apply { pr _data = GETV(_x, "data"); _data select UNIT_DATA_ID_CLASS_NAME };
		_unitsClassNames call misc_fnc_getCargoInfantryCapacity;
	} ENDMETHOD;

	/*
	Function: (static) getTemplateForSide
	Get the appropriate unit template for the side specified
	
	Parameters: _side
	
	_side - side (WEST/EAST/INDEPENDENT/etc.)
	
	Returns: Template
	*/
	STATIC_METHOD("getTemplateForSide") {
		params [P_THISCLASS, P_SIDE("_side")];
		if(_side == INDEPENDENT) then { tAAF } else { if(_side == WEST) then { tGUERILLA } else { tGUERILLA } };
	} ENDMETHOD;
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	//                                       G E T   P R O P E R T I E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	//                    G E T   B E H A V I O U R
	/*
	Method: getVehaviour
	Runs 'behaviour' command on the object handle of this unit. See https://community.bistudio.com/wiki/behaviour

	Returns: String - One of "CARELESS", "SAFE", "AWARE", "COMBAT" and "STEALTH"
	*/
	METHOD("getBehaviour") {
		params [P_THISOBJECT];
		private _data = GETV(_thisObject, "data");
		private _object = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		behaviour _object
	} ENDMETHOD;

	//                          I S  A L I V E
	/*
	Method: isAlive
	Returns true if this unit is alive, false otherwise.
	Despawned unit is always considered alive.

	Returns: Bool
	*/
	METHOD("isAlive") {
		params [P_THISOBJECT];
		private _data = GETV(_thisObject, "data");
		private _object = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (_object isEqualTo objNull) then {
			// Unit is despawned
			true
		} else {
			alive _object
		};
	} ENDMETHOD;

	//                          I S   S P A W N E D
	/*
	Method: isSpawned
	Checks if given unit is currently spawned or not

	Returns: bool, true if the unit is spawned
	*/
	METHOD("isSpawned") {
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		private _return = !( isNull (_data select UNIT_DATA_ID_OBJECT_HANDLE));
		_return
	} ENDMETHOD;


	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |               I S   I N F A N T R Y   /   V E H I C L E   /   D R O N E
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	//                       I S   I N F A N T R Y
	/*
	Method: isInfantry
	Returns true if given <Unit> is infantry

	Returns: Bool
	*/
	METHOD("isInfantry") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CAT == T_INF
	} ENDMETHOD;

	//                       I S   V E H I C L E
	/*
	Method: isVehicle
	Returns true if given <Unit> is vehicle

	Returns: Bool
	*/
	METHOD("isVehicle") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CAT == T_VEH
	} ENDMETHOD;

	//                         I S   D R O N E
	/*
	Method: isDrone
	Returns true if given <Unit> is drone

	Returns: Bool
	*/
	METHOD("isDrone") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CAT == T_DRONE
	} ENDMETHOD;

	/*
	Method: isCargo
	Returns true if given <Unit> is cargo

	Returns: Bool
	*/
	METHOD("isCargo") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CAT == T_CARGO
	} ENDMETHOD;
	
	//                         I S   S T A T I C
	/*
	Method: isStatic
	Returns true if given <Unit> is one of static vehicles defined in Templates

	Returns: Bool
	*/
	METHOD("isStatic") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		[_data select UNIT_DATA_ID_CAT, _data select UNIT_DATA_ID_SUBCAT] in T_static
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               B U I L D   R E S O U R C E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	METHOD("setBuildResources") {
		params [P_THISOBJECT, ["_value", 0, [0]]];

		// Bail if we can't carry any build resources
		if (!T_CALLM0("canHaveBuildResources")) exitWith {};

		private _data = GET_VAR(_thisObject, "data");
		_data set [UNIT_DATA_ID_BUILD_RESOURCE, _value];
		if (T_CALLM0("isSpawned")) then {
			T_CALLM1("_setBuildResourcesSpawned", _value);
		} else {
			pr _dataList = _data#UNIT_DATA_ID_LIMITED_ARSENAL;
		};
	} ENDMETHOD;

	METHOD("getBuildResources") {
		params [P_THISOBJECT];

		//OOP_INFO_0("GET BUILD RESOURCES");

		private _data = GET_VAR(_thisObject, "data");

		if (_data#UNIT_DATA_ID_CAT == T_INF) exitWith { 0 };

		private _return = if (T_CALLM0("isSpawned")) then {
			OOP_INFO_0("  spawned");
			T_CALLM0("_getBuildResourcesSpawned")
		} else {
			OOP_INFO_0("  despawned");
			_data select UNIT_DATA_ID_BUILD_RESOURCE
		};
		_return
		
	} ENDMETHOD;

	METHOD("addBuildResources") {
		params [P_THISOBJECT, ["_value", 0, [0]]];

		// Bail if a negative number is specified
		if(_value < 0) exitWith {};

		if (!T_CALLM0("canHaveBuildResources")) exitWith {};

		pr _resCurrent = T_CALLM0("getBuildResources");
		pr _resNew = _resCurrent + _value;
		T_CALLM1("setBuildResources", _resNew);
	} ENDMETHOD;

	METHOD("removeBuildResources") {
		params [P_THISOBJECT, ["_value", 0, [0]]];

		// Bail if a negative number is specified
		if (_value < 0) exitWith {};

		pr _resCurrent = T_CALLM0("getBuildResources");
		pr _resNew = _resCurrent - _value;
		if (_resNew < 0) then {_resNew = 0;};
		T_CALLM1("setBuildResources", _resNew);
	} ENDMETHOD;

	METHOD("_setBuildResourcesSpawned") {
		params [P_THISOBJECT, ["_value", 0, [0]]];

		private _data = GET_VAR(_thisObject, "data");
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
	} ENDMETHOD;

	METHOD("_getBuildResourcesSpawned") {
		params [P_THISOBJECT];

		//OOP_INFO_0("_getBuildResourcesSpawned");

		private _data = GET_VAR(_thisObject, "data");
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
	} ENDMETHOD;

	METHOD("canHaveBuildResources") {
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		pr _cat = _data#UNIT_DATA_ID_CAT;
		_cat != T_INF
	} ENDMETHOD;

	STATIC_METHOD("getInfantryBuildResources") {
		params [P_THISCLASS, P_OBJECT("_hO")];
		pr _items = (uniformItems _hO) + (vestItems _hO) + (backpackitems _hO);
		pr _nItems = {_x == "vin_build_res_0"} count _items;
		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		_nItems*_buildResPerMag
	} ENDMETHOD;

	STATIC_METHOD("removeInfantryBuildResources") {
		params [P_THISCLASS, P_OBJECT("_hO"), P_NUMBER("_value")];
		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		pr _nItemsToRemove = round (_value / _buildResPerMag);
		pr _i = 0;
		while {_i < _nItemsToRemove} do {
			_hO removeMagazine "vin_build_res_0";
			_i = _i + 1;
		};
	} ENDMETHOD;

	STATIC_METHOD("getVehicleBuildResources") {
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
	} ENDMETHOD;

	STATIC_METHOD("removeVehicleBuildResources") {
		params [P_THISCLASS, P_OBJECT("_hO"), P_NUMBER("_value")];

		// Bail if negative number is passed
		if (_value < 0) exitWith {};

		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		pr _nItemsToRemove = ceil (_value/_buildResPerMag);

		[_hO, "vin_build_res_0", _nItemsToRemove] call CBA_fnc_removeMagazineCargo;
	} ENDMETHOD;

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
	METHOD("getSubagents") {
		[] // A single unit has no subagents
	} ENDMETHOD;

	//                        G E T   P O S S I B L E   G O A L S
	/*
	Method: getPossibleGoals
	Returns the list of goals this agent evaluates on its own.

	Access: Used by AI class

	Returns: Array with goal class names
	*/
	METHOD("getPossibleGoals") {
		["GoalUnitSalute","GoalUnitScareAway"]
	} ENDMETHOD;

	//                      G E T   P O S S I B L E   A C T I O N S
	/*
	Method: getPossibleActions
	Returns the list of actions this agent can use for planning.

	Access: Used by AI class

	Returns: Array with action class names
	*/
	METHOD("getPossibleActions") {
		["ActionUnitSalute","ActionUnitScareAway"]
	} ENDMETHOD;

	/*
	Method: createDefaultCrew
	Creates default crew for a vehicle.
	The vehicle must be in a group.

	Parameters: _template

	_template - the template array to get unit's class name from.

	Returns: nil
	*/

	METHOD("createDefaultCrew") {
		params [ P_THISOBJECT, ["_template", [], [[]]] ];

		private _data = GET_VAR(_thisObject, "data");

		// Check if the unit is in a group
		private _group = _data select UNIT_DATA_ID_GROUP;
		if (_group == "") exitWith { diag_log format ["[Unit::createDefaultCrew] Error: cannot create crew for a unit which has no group: %1", CALL_METHOD(_thisObject, "getData", [])] };

		private _className = _data select UNIT_DATA_ID_CLASS_NAME;
		private _catID = _data select UNIT_DATA_ID_CAT;
		private _subcatID = _data select UNIT_DATA_ID_SUBCAT;
		private _crewData = [_catID, _subcatID, _className] call t_fnc_getDefaultCrew;

		{
			private _unitCatID = _x select 0; // Unit's category
			private _unitSubcatID = _x select 1; // Unit's subcategory
			private _unitClassID = _x select 2;
			private _args = [_template, _unitCatID, _unitSubcatID, _unitClassID, _group]; // ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]]
			private _newUnit = NEW("Unit", _args);
		} forEach _crewData;
	} ENDMETHOD;

	//                             I S   E M P T Y
	/*
	Method: isEmpty
	Returns true if there are no units in this vehicle or it is not a vehicle

	Returns: bool
	*/
	METHOD("isEmpty") {
		params [P_THISOBJECT];
		private _data = GET_VAR(_thisObject, "data");
		private _oh = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		(count fullCrew _oh) == 0
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               L I M I T E D   A R S E N A L
	// | Methods for manipulating the limited arsenal
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	METHOD("limitedArsenalEnable") {
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
			
			// Init default unlimited items in the arsenal
			// Add uniforms and other things
			{
				pr _className = _x;
				pr _index = [_className] call jn_fnc_arsenal_itemType;
				(_arsenalArray#_index) pushBack [_className, -1];
			} forEach (g_UM_civHeadgear + g_UM_civUniforms + g_UM_civFacewear + g_UM_civBackpacks);

			_data set [UNIT_DATA_ID_LIMITED_ARSENAL, _arsenalArray]; // Limited Arsenal's empty array for items
			if (isNull _hO) then {
				// Object is currently despawned
			} else {
				// Object is currently spawned

				// Clear the inventory
				/// although, maybe we should move it into the arsenal?
				// For now I only care to clear the inventory when we create an ammo box
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
	} ENDMETHOD;

	METHOD("limitedArsenalEnabled") {
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		pr _dataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
		count _dataList > 0
	} ENDMETHOD;

	METHOD("limitedArsenalOnSpawn") {
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
			CALL_STATIC_METHOD_2("BuildUI", "setObjectMovable", _hO, true);
		};
	} ENDMETHOD;

	METHOD("limitedArsenalOnDespawn") {
		params [P_THISOBJECT];

		T_CALLM0("limitedArsenalSyncToUnit");
	} ENDMETHOD;

	// This method must synchronize Unit OOP object's data fields to match those of the 'real' unit
	METHOD("limitedArsenalSyncToUnit") {
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
	} ENDMETHOD;

	// Gets JNA data list depending on the spawn state of the unit
	METHOD("limitedArsenalGetDataList") {
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
	} ENDMETHOD;

	// Removes items from the arsenal
	METHOD("limitedArsenalRemoveItem") {
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
	} ENDMETHOD;

	// - - - - STORAGE - - - - -

	/* override */ METHOD("serializeForStorage") {
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

		diag_log _data;

		_data 
	} ENDMETHOD;

	/* override */ METHOD("deserializeFromStorage") {
		params [P_THISOBJECT, P_ARRAY("_serial")];
		_serial set [UNIT_DATA_ID_OWNER, 2]; // Server
		_serial set [UNIT_DATA_ID_MUTEX, MUTEX_NEW()];
		_serial set [UNIT_DATA_ID_OBJECT_HANDLE, objNull];
		_serial set [UNIT_DATA_ID_AI, ""];
		// SAVEBREAK DELETE >>> 
		if(count _serial < UNIT_DATA_SIZE) then {
			_serial set[UNIT_DATA_ID_INVENTORY, []];
		};
		// SAVEBREAK DELETE <<<
		T_SETV("data", _serial);

		diag_log _serial;

		true
	} ENDMETHOD;

	/* virtual */ STATIC_METHOD("saveStaticVariables") {
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		pr _all = GETSV("Unit", "all");
		CALLM2(_storage, "save", "Unit_all", +_all);
	} ENDMETHOD;

	/* virtual */ STATIC_METHOD("loadStaticVariables") {
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		pr _all = CALLM1(_storage, "load", "Unit_all");
		SETSV("Unit", "all", +_all);
	} ENDMETHOD;

ENDCLASS;

if (isNil {GETSV("Unit", "all")} ) then {
	SET_STATIC_MEM("Unit", "all", []);
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
