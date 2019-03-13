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
A virtualized Unit is a man, vehicle or a drone which can be spawned or not spawned.

Author: Sparker
10.06.2018
*/

#define pr private

Unit_fnc_EH_Killed = compile preprocessFileLineNumbers "Unit\EH_Killed.sqf";
Unit_fnc_EH_handleDamageInfantry = compile preprocessFileLineNumbers "Unit\EH_handleDamageInfantry.sqf";
Unit_fnc_EH_GetIn = compile preprocessFileLineNumbers "Unit\EH_GetIn.sqf";


CLASS(UNIT_CLASS_NAME, "");
	VARIABLE("data");
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

		if (!_valid) exitWith { SET_MEM(_thisObject, "data", []);  diag_log format ["[Unit::new] Error: created invalid unit: %1", _this] };
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

		// Create the data array
		private _data = UNIT_DATA_DEFAULT;
		_data set [UNIT_DATA_ID_CAT, _catID];
		_data set [UNIT_DATA_ID_SUBCAT, _subcatID];
		_data set [UNIT_DATA_ID_CLASS_NAME, _class];
		_data set [UNIT_DATA_ID_MUTEX, MUTEX_NEW()];
		_data set [UNIT_DATA_ID_GROUP, ""];
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

		// Initialize variables and event handlers
		if (!isNull _hO) then {
			CALLM0(_thisObject, "initObjectVariables");
			CALLM0(_thisObject, "initObjectEventHandlers");
		};
	} ENDMETHOD;


	//                             D E L E T E
	/*
	Method: delete
	Deletes this object, despawns the physical unit if neccessary.
	*/

	METHOD("delete") {
		params[["_thisObject", "", [""]]];
		private _data = GET_MEM(_thisObject, "data");

		//Despawn this unit if it was spawned
		CALLM(_thisObject, "despawn", []);

		// Remove the unit from its group
		private _group = _data select UNIT_DATA_ID_GROUP;
		CALL_METHOD(_group, "removeUnit", [_thisObject]);

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
		if (isNil "_data") exitWith {false};
		//Return true if the data array is of the correct size
		( (count _data) == UNIT_DATA_SIZE)
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

		OOP_INFO_0("SPAWN");

		//Unpack data
		private _data = GET_MEM(_thisObject, "data");

		//private _mutex = _data select UNIT_DATA_ID_MUTEX;

		//Lock the mutex
		//MUTEX_LOCK(_mutex);
		CRITICAL_SECTION_START

		//Unpack more data...
		private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _objectHandle) then { //If it's not spawned yet
			private _className = _data select UNIT_DATA_ID_CLASS_NAME;
			private _group = _data select UNIT_DATA_ID_GROUP;

			//Perform object creation
			private _catID = _data select UNIT_DATA_ID_CAT;
			switch(_catID) do {
				case T_INF: {
					private _groupHandle = CALL_METHOD(_group, "getGroupHandle", []);
					//diag_log format ["---- Received group of side: %1", side _groupHandle];
					_objectHandle = _groupHandle createUnit [_className, _pos, [], 10, "FORM"];
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
				};
				case T_VEH: {
					_objectHandle = createVehicle [_className, _pos, [], 0, "can_collide"];

					_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];

					CALLM1(_thisObject, "createAI", "AIUnitVehicle");
				};
				case T_DRONE: {
				};
			};


			// Initialize variables
			CALLM0(_thisObject, "initObjectVariables");

			// Initialize event handlers
			CALLM0(_thisObject, "initObjectEventHandlers");

			_objectHandle setDir _dir;
			_objectHandle setPos _pos;
		} else {
			OOP_WARNING_0("Already spawned");
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
	Method: initObjectEventHandlers
	Adds event handlers to unit.

	Returns: nil
	*/
	METHOD("initObjectEventHandlers") {
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

			// Delete the vehicle
			deleteVehicle _objectHandle;
			private _group = _data select UNIT_DATA_ID_GROUP;
			//if (_group != "") then { CALL_METHOD(_group, "handleUnitDespawned", [_thisObject]) };
			_data set [UNIT_DATA_ID_OBJECT_HANDLE, objNull];
		} else {
			OOP_WARNING_0("Already despawned");
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

	Returns: [_nDrivers, _nTurrets]
	*/
	
	STATIC_METHOD("getRequiredCrew") {
		params ["_thisClass", ["_units", [], [[]]]];
		
		pr _nDrivers = 0;
		pr _nTurrets = 0;
		{
			if (CALLM0(_x, "isVehicle")) then {
				pr _className = CALLM0(_x, "getClassName");
				([_className] call misc_fnc_getFullCrew) params ["_n_driver", "_copilotTurrets", "_stdTurrets"];//, "_psgTurrets", "_n_cargo"];
				_nDrivers = _nDrivers + _n_driver;
				_nTurrets = _nTurrets + (count _copilotTurrets) + (count _stdTurrets);
			};
		} forEach _units;
		[_nDrivers, _nTurrets]
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






	// ================= File based methods ======================
	METHOD_FILE("createDefaultCrew", "Unit\createDefaultCrew.sqf");
	//METHOD_FILE("doMoveInf", "Unit\doMoveInf.sqf");
	//METHOD_FILE("doStopInf", "Unit\doStopInf.sqf");
	//METHOD_FILE("doSitOnBench", "Unit\doSitOnBench.sqf");
	//METHOD_FILE("doGetUpFromBench", "Unit\doGetUpFromBench.sqf");
	//METHOD_FILE("doAnimRepairVehicle", "Unit\doAnimRepairVehicle.sqf");
	//METHOD_FILE("doInteractAnimObject", "Unit\doInteractAnimObject.sqf");
	//METHOD_FILE("doStopInteractAnimObject", "Unit\doStopInteractAnimObject.sqf");
	//METHOD_FILE("distance", "Unit\distance.sqf"); // Returns distance between this unit and another position

ENDCLASS;

SET_STATIC_MEM("Unit", "all", []);
