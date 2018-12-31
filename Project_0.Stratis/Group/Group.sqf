#include "Group.hpp"
#include "..\Unit\Unit.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\GlobalAssert.hpp"

// Class: Group
/*
Virtualized Group has <Unit> objects inside it.

Unlike standard ARMA group, it can have men, vehicles and drones inside it.

Author: Sparker
11.06.2018
*/

#define pr private

CLASS(GROUP_CLASS_NAME, "MessageReceiverEx")
	
	//Variables
	VARIABLE("data");
	
	// |                             N E W                                  |
	/*
	Method: new
	
	Parameters: _side, _groupType, 
	
	_side - Side (west, east, etc) of this group
	_groupType - Number, group type, see <GROUP_TYPE>
	
	Returns: nil
	*/
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]], ["_groupType", GROUP_TYPE_IDLE, [GROUP_TYPE_IDLE]]];
		
		// Check existance of neccessary global objects
		ASSERT_GLOBAL_OBJECT(gMessageLoopMain);
		
		private _data = GROUP_DATA_DEFAULT;
		_data set [GROUP_DATA_ID_SIDE, _side];
		_data set [GROUP_DATA_ID_TYPE, _groupType];
		_data set [GROUP_DATA_ID_MUTEX, MUTEX_NEW()];
		SET_VAR(_thisObject, "data", _data);
	} ENDMETHOD;
	

	// |                            D E L E T E
	/*
	Method: delete
	NYI
	*/
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		// todo
	} ENDMETHOD;
	
	/*
	Method: getMessageLoop
	See <MessageReceiver.getMessageLoop>
	
	Returns: <MessageLoop>
	*/
	// Returns the message loop this object is attached to
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;
	
	
	// |                           A D D   U N I T
	/*
	Method: addUnit
	Adds an existing <Unit> to this group. You don't need to call it manually.
	
	Access: internal use!
	
	Parameters: _unit
	
	_unit - <Unit> to add
	
	Returns: nil
	*/
	METHOD("addUnit") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select GROUP_DATA_ID_MUTEX;
		private _unitList = _data select GROUP_DATA_ID_UNITS;
		_unitList pushBackUnique _unit;
	} ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |                        R E M O V E   U N I T                       |
	// ----------------------------------------------------------------------
	/*
	Method: removeUnit
	Removes a unit from this group.
	
	Access: internal use
	
	Parameters: _unit
	
	_unit - <Unit> that will be removed from this group.

	Returns: nil
	*/
	METHOD("removeUnit") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select GROUP_DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _unitList = _data select GROUP_DATA_ID_UNITS;
		_unitList = _unitList - [_unit];
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	



	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                          G E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	


	// |                         G E T   U N I T S
	/*
	Method: getUnits
	Returns an array with units in this group.
	
	Returns: Array of units.
	*/
	METHOD("getUnits") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select GROUP_DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _unitList = _data select GROUP_DATA_ID_UNITS;
		private _return = +_unitList;
		MUTEX_UNLOCK(_mutex);
		_return
	} ENDMETHOD;
	
	// |                         G E T   T Y P E                            |
	/*
	Method: getType
	Description
	
	Returns: Number, grup type. See <GROUP_TYPE>,
	*/
	METHOD("getType") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select GROUP_DATA_ID_TYPE
	} ENDMETHOD;
	
	
	// |                  G E T   G R O U P   H A N D L E
	/*
	Method: getGroupHandle
	Returns the group handle of this group.
	
	Returns: group handle.
	*/
	METHOD("getGroupHandle") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");		
		_data select GROUP_DATA_ID_GROUP_HANDLE
	} ENDMETHOD;
	
	
	// |                     S E T / G E T   G A R R I S O N                |
	// 
	/*
	Method: setGarrison
	Sets the <Garrison> of this garrison.
	Use <Garrison.addGroup> to add a group to a garrison.
	
	Access: internal use.
	
	Parameters: _garrison
	
	_garrison - <Garrison>
	
	Returns: nil
	*/
	METHOD("setGarrison") {
		params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];
		private _data = GET_VAR(_thisObject, "data");
		_data set [GROUP_DATA_ID_GARRISON, _garrison];
		
		// Set the garrison of all units in this group
		private _units = _data select GROUP_DATA_ID_UNITS;
		{ CALL_METHOD(_x, "setGarrison", [_garrison]); } forEach _units;
	} ENDMETHOD;
	
	
	/*
	Method: getGarrison
	Returns the <Garrison> this Group is attached to.
	
	Returns: String, <Garrison>
	*/
	METHOD("getGarrison") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select GROUP_DATA_ID_GARRISON
	} ENDMETHOD;
	
	
	// |                           G E T   A I
	/*
	Method: getAI
	Returns the <AI> of this group, if it's spawned, or "" otherwise.
	
	Returns: String, <AIGroup>
	*/
	METHOD("getAI") {
		params [["_thisObject", "", [""]]];
		
		pr _data = GETV(_thisObject, "data");
		_data select GROUP_DATA_ID_AI
	} ENDMETHOD;
	
	// |                           I S   S P A W N E D
	/*
	Method: isSpawned
	Returns the spawned state of this group
	
	Returns: Bool
	*/
	METHOD("isSpawned") {
		params [["_thisObject", "", [""]]];
		
		pr _data = GETV(_thisObject, "data");
		_data select GROUP_DATA_ID_SPAWNED
	} ENDMETHOD;
	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                E V E N T   H A N D L E R S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
	
	// |                 H A N D L E   U N I T   K I L L E D                |
	/*
	Method: handleUnitKilled
	Called when the unit has been killed.
	
	Must be called inside the group's thread, not inside event handler.
	
	Returns: nil
	*/
	METHOD("handleUnitKilled") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		
		diag_log format ["[Group::handleUnitKilled] Info: %1", _unit];
		
		pr _data = GETV(_thisObject, "data");
		pr _units = _data select GROUP_DATA_ID_UNITS;
		
		// Remove the unit from this group
		_units deleteAt (_units find _unit);
		
		// Set group of this unit
		CALLM1(_unit, "setGroup", "");	
	} ENDMETHOD;
	
	
	// |              H A N D L E   U N I T   D E S P A W N E D             |
	/*
	Method: handleUnitDespawned
	NYI
	
	Returns: nil
	*/
	METHOD("handleUnitDespawned") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]] ];
	} ENDMETHOD;
	
	
	
	// |                 H A N D L E   U N I T   S P A W N E D              |
	/*
	Method: handleUnitSpawned
	NYI
	
	Returns: nil
	*/
	METHOD("handleUnitSpawned") {
		params [["_thisObject", "", [""]], "_unit"];
	} ENDMETHOD;
	



	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                          S P A W N I N G   A N D   D E S P A W N I N G
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
	
	
	// |                           C R E A T E   A I
	/*
	Method: createAI
	Creates an <AIGroup> for this group.
	
	Access: internal.
	
	Returns: nil
	*/
	METHOD("createAI") {
		params [["_thisObject", "", [""]]];
		
		pr _data = GETV(_thisObject, "data");
		pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
		
		// Create an AI for this group if it has any units
		if (count _groupUnits > 0) then {
			pr _AI = NEW("AIGroup", [_thisObject]);
			pr _data = GETV(_thisObject, "data");
			_data set [GROUP_DATA_ID_AI, _AI];
			CALLM(_AI, "setProcessInterval", [3]); // How often its process method will be called
			CALLM(_AI, "start", []); // Kick start it
		};

	} ENDMETHOD;
	
	
	
	
	// |         S P A W N
	/*
	Method: spawn
	Spawns all the units in this group.
	
	Parameters: _loc
	
	_loc - <Location> where the group will spawn.
	
	Returns: nil
	*/
	METHOD("spawn") {
		params [["_thisObject", "", [""]], ["_loc", "", [""]]];
		pr _data = GETV(_thisObject, "data");
		if (!(_data select GROUP_DATA_ID_SPAWNED)) then {
			pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
			pr _groupType = _data select GROUP_DATA_ID_TYPE;
			{
				private _unit = _x;
				private _unitData = CALL_METHOD(_unit, "getMainData", []);
				
				// Create a group handle if we have any infantry and the group handle doesn't exist yet
				private _catID = _unitData select 0;
				if (_catID == T_INF) then {
					pr _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
					if (isNull _groupHandle) then {
						private _side = _data select GROUP_DATA_ID_SIDE;
						_groupHandle = createGroup [_side, false]; //side, delete when empty
						_data set [GROUP_DATA_ID_GROUP_HANDLE, _groupHandle];
					};
				};			
				private _args = _unitData + [_groupType]; // ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_className", "", [""]], ["_groupType", "", [""]]
				private _posAndDir = CALL_METHOD(_loc, "getSpawnPos", _args);
				CALL_METHOD(_unit, "spawn", _posAndDir);
			} forEach _groupUnits;
			
			// Set group default behaviour
			pr _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
			_groupHandle setBehaviour "SAFE";
			
			// Create an AI for this group
			CALLM0(_thisObject, "createAI");
			
			// Set the spawned flag to true
			_data set [GROUP_DATA_ID_SPAWNED, true];
		};
	} ENDMETHOD;
	
	
	
	// |         D E S P A W N
	/*
	Method: despawn
	Despawns all units in this group. Also deletes the group handle.
	
	Returns: nil
	*/
	METHOD("despawn") {
		params [["_thisObject", "", [""]]];
		pr _data = GETV(_thisObject, "data");
		if ((_data select GROUP_DATA_ID_SPAWNED)) then {
			pr _AI = _data select GROUP_DATA_ID_AI;
			if (_AI != "") then {
				// Switch off their brain
				// We must safely delete the AI object because it might be currently used in its own thread
				pr _msg = MESSAGE_NEW_SHORT(_AI, AI_MESSAGE_DELETE);
				pr _msgID = CALLM2(_AI, "postMessage", _msg, true);
				_data set [GROUP_DATA_ID_AI, ""];
				CALLM(_thisObject, "waitUntilMessageDone", [_msgID]);
			};
			
			// Despawn everything
			pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
			{
				CALL_METHOD(_x, "despawn", []);
			} forEach _groupUnits;
			
			// Delete the group handle
			pr _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
			if (count units _groupHandle > 0) then {
				diag_log format ["[Group] Warning: group is not empty at despawning: %1. Units remaining:", _data];
				{
					diag_log format ["  %1,  alive: %2", _x, alive _x];
				} forEach (units _groupHandle);
				_groupHandle deleteGroupWhenEmpty true;
			} else {			
				deleteGroup _groupHandle;
			};
			_data set [GROUP_DATA_ID_GROUP_HANDLE, grpNull];
			
			// Set the spawned flag to false
			_data set [GROUP_DATA_ID_SPAWNED, false];
		};
	} ENDMETHOD;
	
	
	
	
	
	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                         G O A P 
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



	//                          G E T   S U B A G E N T S
	/*
	Method: getSubagents
	Returns subagents of this agent.
	For group subagents are its units, since their <AIUnit> is processed synchronosuly with <AIGroup> by default.
	
	Access: Used by AI class
	
	Returns: array of units.
	*/
	METHOD("getSubagents") {
		params [["_thisObject", "", [""]]];
		
		// Get all units
		private _data = GET_VAR(_thisObject, "data");
		private _unitList = _data select GROUP_DATA_ID_UNITS;
		
		// Return only units which actually have an AI object (soldiers and drones)
		pr _return = _unitList select {
			CALLM(_x, "isInfantry", [])
		};
		_return
	} ENDMETHOD;
	
	
	//                        G E T   P O S S I B L E   G O A L S
	/*
	Method: getPossibleGoals
	Returns the list of goals this agent evaluates on its own.
	
	Access: Used by AI class
	
	Returns: Array with goal class names
	*/
	METHOD("getPossibleGoals") {
		["GoalGroupRelax"]
	} ENDMETHOD;
	
	
	//                      G E T   P O S S I B L E   A C T I O N S
	/*
	Method: getPossibleActions
	Returns the list of actions this agent can use for planning.
	
	Access: Used by AI class
	
	Returns: Array with action class names
	*/
	METHOD("getPossibleActions") {
		[]
	} ENDMETHOD;
	
	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                O W N E R S H I P   T R A N S F E R
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	/*
	Method: serialize
	See <MessageReceiver.serialize>
	*/
	// Must return a single value which can be deserialized to restore value of an object
	METHOD("serialize") {
		params [["_thisObject", "", [""]]];
		
		diag_log "[Group:serialize] was called!";
		
		pr _data = GETV(_thisObject, "data");
		pr _units = _data select GROUP_DATA_ID_UNITS;
		//pr _mutex = _data select GROUP_DATA_ID_MUTEX;
		//MUTEX_LOCK(_mutex);
		
		// Store data on all units in this group
		pr _unitsSerialized = [];
		private _units = _data select GROUP_DATA_ID_UNITS;
		{
			pr _unitDataArray = GETV(_x, "data");
			_unitsSerialized pushBack [_x, +_unitDataArray];
		} forEach _units;
		
		// Store data about this group
		// ??
		
		pr _return = [_unitsSerialized, _data];
		
		//MUTEX_UNLOCK(_mutex);
		_return
	} ENDMETHOD;
	
	/*
	Method: deserialize
	See <MessageReceiver.deserialize>
	*/
	// Takes the output of deserialize and restores values of an object
	METHOD("deserialize") {
		params [["_thisObject", "", [""]], "_serialData"];
		
		diag_log "[Group:deserialize] was called!";
		
		// Unpack the array
		_serialData params ["_unitsSerialized", "_data"];
		SETV(_thisObject, "data", _data);
		_data set [GROUP_DATA_ID_MUTEX, MUTEX_NEW()];
		
		// Unpack all the units
		{ // forEach _unitsSerialized
			_x params ["_unitObjNameStr", "_unitDataArray"];
			pr _newUnit = NEW_EXISTING("Unit", _unitObjNameStr);
			SETV(_newUnit, "data", +_unitDataArray);
			
			// Create a new AI for this unit, if it existed
			pr _unitAI = _unitDataArray select UNIT_DATA_ID_AI;
			diag_log format [" --- Old unit AI: %1", _unitAI];
			if (_unitAI != "") then {
				CALLM0(_newUnit, "createAI");				
				diag_log format [" --- Created new unit AI: %1", _unitDataArray select UNIT_DATA_ID_AI];
			};
		} forEach _unitsSerialized;
		
		// Create a new AI for this group
		if ((_data select GROUP_DATA_ID_AI) != "") then {
			CALLM0(_thisObject, "createAI");
		};		
		
	} ENDMETHOD;
	
	/*
	Method: transferOwnership
	See <MessageReceiver.transferOwnership>
	*/
	METHOD("transferOwnership") {
		params [ ["_thisObject", "", [""]], ["_newOwner", 0, [0]] ];
		
		diag_log "[Group:transferOwnership] was called!";
		
		pr _data = GETV(_thisObject, "data");
		
		// Delete the AI of this group
		// todo transfer the AI instead, or just transfer the goals and most important data?
		pr _AI = _data select GROUP_DATA_ID_AI;
		if (_AI != "") then {
			pr _msg = MESSAGE_NEW_SHORT(_AI, AI_MESSAGE_DELETE);
			pr _msgID = CALLM2(_AI, "postMessage", _msg, true);
			//if (_msgID < 0) then {diag_log format ["--- Got wrong msg ID %1 %2 %3", _msgID, __FILE__, __LINE__];};
			CALLM(_thisObject, "waitUntilMessageDone", [_msgID]);
		};
		
		// Delete AI of all the units
		pr _units = _data select GROUP_DATA_ID_UNITS;
		{
			pr _unitData = GETV(_x, "data");
			pr _unitAI = _unitData select UNIT_DATA_ID_AI;
			if (_unitAI != "") then {
				pr _msg = MESSAGE_NEW_SHORT(_unitAI, AI_MESSAGE_DELETE);
				pr _msgID = CALLM2(_unitAI, "postMessage", _msg, true);
				//diag_log format ["--- Got msg ID %1 %2 %3 while deleting Unit's AI", _msgID, __FILE__, __LINE__];
				CALLM(_thisObject, "waitUntilMessageDone", [_msgID]);
			};
		} forEach _units;
		
		// Switch group owner if the group was spawned
		pr _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
		if (!isNull _groupHandle) then {
			if (clientOwner == 2) then {
				_groupHandle setGroupOwner _newOwner;
			} else {
				[_groupHandle, _newOwner] remoteExecCall ["setGroupOwner", 2, false];
			};
		};

		// We're done here
		true
	} ENDMETHOD;
	
	
	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               O T H E R   M E T H O D S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
	
	// |         C R E A T E   U N I T S   F R O M   T E M P L A T E
	/*
	Method: createUnitsFromTemplate
	Creates units from template and adds them to this group.
	
	Parameters: _template, _subcatID
	
	_template - <Template>
	_subcatID - subcategory of this group template
	
	Returns: Number, amount of created units.
	*/
	METHOD("createUnitsFromTemplate") {
		params [["_thisObject", "", [""]], ["_template", [], [[]]], ["_subcatID", 0, [0]]];
		private _groupData = [_template, _subcatID, -1] call t_fnc_selectGroup;
		
		// Create every unit and add it to this group
		{
			private _catID = _x select 0;
			private _subcatID = _x select 1;
			private _classID = _x select 2;
			private _args = [_template, _catID, _subcatID, _classID, _thisObject]; //["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]]
			NEW("Unit", _args);
		} forEach _groupData;
		
		(count _groupData)
	} ENDMETHOD;
	
ENDCLASS;