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


CLASS(UNIT_CLASS_NAME, "");
	VARIABLE_ATTR("data", [ATTR_PRIVATE]);
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
	*/

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]], ["_hO", objNull]];

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
			CALLM0(_thisObject, "initObjectVariables");
			CALLM0(_thisObject, "initObjectEventHandlers");
			CALLM0(_thisObject, "initObjectDynamicSimulation");
		};
	} ENDMETHOD;


	//                             D E L E T E
	/*
	Method: delete
	Deletes this object, despawns the physical unit if neccessary.
	*/

	METHOD("delete") {
		params[["_thisObject", "", [""]]];

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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]], ["_AIClassName", "", [""]]];

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
		params [["_thisObject", "", [""]], "_pos", "_dir"];

		OOP_INFO_2("SPAWN pos: %1, dir: %2", _pos, _dir);

		//Unpack data
		private _data = GET_MEM(_thisObject, "data");

		//private _mutex = _data select UNIT_DATA_ID_MUTEX;

		//Lock the mutex
		//MUTEX_LOCK(_mutex);
		CRITICAL_SECTION_START

		//Unpack more data...
		private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		private _buildResources = _data select UNIT_DATA_ID_BUILD_RESOURCE;
		if (isNull _objectHandle) then { //If it's not spawned yet
			private _className = _data select UNIT_DATA_ID_CLASS_NAME;
			private _group = _data select UNIT_DATA_ID_GROUP;

			//Perform object creation
			private _catID = _data select UNIT_DATA_ID_CAT;
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
					if (_groupType == GROUP_TYPE_BUILDING_SENTRY) then {
						CALLM1(_AI, "setSentryPos", _pos);
					};

					// Give intel to this unit
					//if ((random 10) < 4) then {
						CALLSM1("UnitIntel", "initUnit", _thisObject);
					//};
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
						sleep 1;
						_objectHandle allowDamage true;
						// If it survived spawning
						if (alive _objectHandle) then {
							OOP_INFO_MSG("Vehicle %1 passed spawn check, did not explode!", [_objectHandle]);
							_objectHandle removeEventHandler ["EpeContactStart", _spawnCheckEv];
						} else {
							
						};
					};

					_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];
					CALLM1(_thisObject, "createAI", "AIUnitVehicle");					
					// Give intel to this unit
					CALLSM1("UnitIntel", "initUnit", _thisObject);
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
						sleep 1;
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


			// Initialize variables
			CALLM0(_thisObject, "initObjectVariables");

			// Initialize event handlers
			CALLM0(_thisObject, "initObjectEventHandlers");

			// Initialize dynamic simulation
			CALLM0(_thisObject, "initObjectDynamicSimulation");

			// Initialize cargo if there is no limited arsenal
			CALLM0(_thisObject, "initObjectInventory");

			// Set build resources
			if (_buildResources > 0 && {T_CALLM0("canHaveBuildResources")}) then {
				T_CALLM1("_setBuildResourcesSpawned", _buildResources);
			};

			_objectHandle setDir _dir;
			_objectHandle setPos _pos;
		} else {
			OOP_ERROR_0("Already spawned");
			DUMP_CALLSTACK;
		};

		CRITICAL_SECTION_END
		//Unlock the mutex
		//MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;

	/*
	Method: initObjectVariables
	Sets variables of unit's object handle.

	Returns: nil
	*/
	METHOD("initObjectVariables") {
		params [["_thisObject", "", [""]]];

		pr _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;

		// Set variables of the object
		if (!isNull _hO) then {
			// Variable with a reference to Unit object
			_hO setVariable [UNIT_VAR_NAME_STR, _thisObject];
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
		params [["_thisObject", "", [""]]];

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
		params [["_thisObject", "", [""]]];

		pr _data = T_GETV("data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		pr _catID = _data select UNIT_DATA_ID_CAT;

		// Killed
		_hO addEventHandler ["Killed", Unit_fnc_EH_Killed];
		
		// HandleDamage for infantry
		if (_data select UNIT_DATA_ID_CAT == T_INF) then {
			_hO addEventHandler ["handleDamage", Unit_fnc_EH_handleDamageInfantry];
		};

		// GetIn, if it's a vehicle
		if (_catID == T_VEH) then {
			_hO addEventHandler ["GetIn", Unit_fnc_EH_GetIn];
		};
	} ENDMETHOD;

	METHOD("initObjectDynamicSimulation") {
		params [["_thisObject", "", [""]]];
		
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
			pr _nGuns = _nInf / 2 / ((_nVeh + _nCargo) max 1);

			// Add weapons and magazines
			pr _arr = [[T_INV_primary, _nGuns], [T_INV_secondary, 0.2*_nGuns], [T_INV_handgun, 0.1*_nGuns]]; // [_subcatID, num. attempts]
			{
				_x params ["_subcatID", "_n"];
				if (count (_tInv#_subcatID) > 0) then { // If there are any weapons in this subcategory

					// Randomize _n
					_n = round (random [0.2*_n, _n, 1.8*_n]);

					for "_i" from 0 to (_n-1) do {
						pr _weaponsAndMags = _tInv#_subcatID;
						pr _weaponAndMag = selectRandom _weaponsAndMags;
						_weaponAndMag params ["_weaponClassName", "_magazines"];
						_hO addItemCargoGlobal [_weaponClassName, round (1 + random 1) ];
						if (count _magazines > 0) then {
							_hO addMagazineCargoGlobal [selectRandom _magazines, 5];
						};
					};
				};
			} forEach _arr;

			// Add items
			pr _arr = [	[T_INV_primary_items, 0.3*_nGuns], [T_INV_secondary_items, 0.2*_nGuns],
						[T_INV_handgun_items, 0.1*_nGuns], [T_INV_items, 0.1*_nGuns]]; // [_subcatID, num. attempts]
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
			_hO addBackpackCargoGlobal ["B_TacticalPack_blk", (round random 2)];
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
		params [["_thisObject", "", [""]]];

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
				pr _msg = MESSAGE_NEW();
				MESSAGE_SET_TYPE(_msg, AI_MESSAGE_DELETE);
				pr _msgID = CALLM2(_AI, "postMessage", _msg, true);
				CALLM(_AI, "waitUntilMessageDone", [_msgID]);
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

			// Deinitialize the limited arsenal
			T_CALLM0("limitedArsenalOnDespawn");

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
		params [["_thisObject", "", [""]], "_vehicle", "_vehicleRole"];
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
		params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];

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
		params [["_thisObject", "", [""]], ["_group", "", [""]] ];
		private _data = GET_VAR(_thisObject, "data");
		_data set [UNIT_DATA_ID_GROUP, _group];
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_OBJECT_HANDLE
	} ENDMETHOD;

	/*
	Method: getClassName
	Returns class name of this unit

	Returns: String
	*/
	METHOD("getClassName") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CLASS_NAME
	} ENDMETHOD;


	//                        G E T   G R O U P
	/*
	Method: getGroup
	Returns the <Group> this unit is attached to.

	Returns: <Group>
	*/
	// Returns the group of this unit
	METHOD("getGroup") {
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "data")
	} ENDMETHOD;


	//                             G E T   P O S
	/*
	Method: getPos
	Returns position of this unit or [] if the unit is not spawned

	Returns: [x, y, z]
	*/
	METHOD("getPos") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _oh = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		getPos _oh
	} ENDMETHOD;


	//                     H A N D L E   K I L L E D
	/*
	Method: handleKilled
	Gets called when a unit is killed.
	*/
	METHOD("handleKilled") {
		params [["_thisObject", "", [""]]];

		// Delete the brain of this unit, if it exists
		pr _data = T_GETV("data");
		pr _AI = _data select UNIT_DATA_ID_AI;
		if (_AI != "") then {
			pr _msg = MESSAGE_NEW();
			MESSAGE_SET_TYPE(_msg, AI_MESSAGE_DELETE);
			pr _msgID = CALLM2(_AI, "postMessage", _msg, true);
			CALLM1(_AI, "waitUntilMessageDone", _msgID);

			_data set [UNIT_DATA_ID_AI, ""];
		};

		// Ungroup this unit
		_data set [UNIT_DATA_ID_GROUP, ""];
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
		_objectHandle getVariable [UNIT_VAR_NAME_STR, ""]
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CAT == T_DRONE
	} ENDMETHOD;

	/*
	Method: isCargo
	Returns true if given <Unit> is cargo

	Returns: Bool
	*/
	METHOD("isCargo") {
		params [["_thisObject", "", [""]]];
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
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		[_data select UNIT_DATA_ID_CAT, _data select UNIT_DATA_ID_SUBCAT] in T_static
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               B U I L D   R E S O U R C E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	METHOD("setBuildResources") {
		params [["_thisObject", "", [""]], ["_value", 0, [0]]];

		// Bail if we can't carry any build resources
		if (!T_CALLM0("canHaveBuildResources")) exitWith {};

		private _data = GET_VAR(_thisObject, "data");
		_data set [UNIT_DATA_ID_BUILD_RESOURCE, _value];
		if (T_CALLM0("isSpawned")) then {
			T_CALLM1("_setBuildResourcesSpawned", _value);
		};
	} ENDMETHOD;

	METHOD("getBuildResources") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");

		if (_data#UNIT_DATA_ID_CAT == T_INF) exitWith { 0 };

		private _return = if (T_CALLM0("isSpawned")) then {
			T_CALLM0("_getBuildResourcesSpawned")
		} else {
			_data select UNIT_DATA_ID_BUILD_RESOURCE
		};
		_return
	} ENDMETHOD;

	METHOD("addBuildResources") {
		params [["_thisObject", "", [""]], ["_value", 0, [0]]];

		// Bail if a negative number is specified
		if(_value < 0) exitWith {};

		if (!T_CALLM0("canHaveBuildResources")) exitWith {};

		pr _resCurrent = T_CALLM0("getBuildResources");
		pr _resNew = _resCurrent + _value;
		T_CALLM1("setBuildResources", _resNew);
	} ENDMETHOD;

	METHOD("removeBuildResources") {
		params [["_thisObject", "", [""]], ["_value", 0, [0]]];

		// Bail if a negative number is specified
		if (_value < 0) exitWith {};

		pr _resCurrent = T_CALLM0("getBuildResources");
		pr _resNew = _resCurrent - _value;
		if (_resNew < 0) then {_resNew = 0;};
		T_CALLM1("setBuildResources", _resNew);
	} ENDMETHOD;

	METHOD("_setBuildResourcesSpawned") {
		params [["_thisObject", "", [""]], ["_value", 0, [0]]];

		private _data = GET_VAR(_thisObject, "data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {0};

		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		pr _nItemsNeeded = ceil (_value/_buildResPerMag);
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
	} ENDMETHOD;

	METHOD("_getBuildResourcesSpawned") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _hO) exitWith {0};
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

	METHOD("canHaveBuildResources") {
		params [P_THISOBJECT];
		pr _data = T_GETV("data");
		pr _cat = _data#UNIT_DATA_ID_CAT;
		_cat != T_INF
	} ENDMETHOD;

	STATIC_METHOD("getInfantryBuildResources") {
		params [P_THISOBJECT, P_OBJECT("_hO")];
		pr _items = (uniformItems _hO) + (vestItems _hO) + (backpackitems _hO);
		pr _nItems = {_x == "vin_build_res_0"} count _items;
		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		_nItems*_buildResPerMag
	} ENDMETHOD;

	STATIC_METHOD("removeInfantryBuildResources") {
		params [P_THISOBJECT, P_OBJECT("_hO"), P_NUMBER("_value")];
		pr _buildResPerMag = getNumber (configfile >> "CfgMagazines" >> "vin_build_res_0" >> "buildResource");
		pr _nItemsToRemove = round (_value / _buildResPerMag);
		pr _i = 0;
		while {_i < _nItemsToRemove} do {
			_hO removeMagazine "vin_build_res_0";
			_i = _i + 1;
		};
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
		params [ ["_thisObject", "", [""]], ["_template", [], [[]]] ];

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
			pr _emptyArray = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]; // I can't include defineCommon.inc because it includes files from arma and it makes SQF VM complain
			_data set [UNIT_DATA_ID_LIMITED_ARSENAL, _emptyArray]; // Limited Arsenal's empty array for items
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

				[_hO] call jn_fnc_arsenal_initPersistent;
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

	METHOD("limitedArsenalOnSpawn") {
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _dataList = _data select UNIT_DATA_ID_LIMITED_ARSENAL;
		if (count _dataList > 0) then {
			// This object has a limited arsenal
			// We need to initialize the object

			// Restore the jna_dataList variable with the arsenal contents
			pr _hO = _data select UNIT_DATA_ID_OBJECT_HANDLE;
			_hO setVariable ["jna_dataList", _dataList];

			// Initialize the limited arsenal
			[_hO] call jn_fnc_arsenal_initPersistent;
		};
	} ENDMETHOD;

	METHOD("limitedArsenalOnDespawn") {
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

ENDCLASS;

SET_STATIC_MEM("Unit", "all", []);

#ifdef _SQF_VM

Test_group_args = [WEST, 0]; // Side, group type
Test_unit_args = [tNATO, T_INF, T_INF_LMG, -1];

["Unit.new", {
	private _group = NEW("Group", Test_group_args);
	private _obj = NEW("Unit", Test_unit_args + [_group]);
	private _class = OBJECT_PARENT_CLASS_STR(_obj);
	!(isNil "_class")
}] call test_AddTest;

#endif