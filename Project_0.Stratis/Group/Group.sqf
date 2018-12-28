#include "Group.hpp"
#include "..\Unit\Unit.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

// Class: Group
/*
Virtualized Group has <Unit> objects inside it.

Unlike standard ARMA group, it can have men, vehicles and drones inside it.

Author: Sparker
11.06.2018
*/

#define pr private

CLASS(GROUP_CLASS_NAME, "MessageReceiver")
	
	//Variables
	VARIABLE("data");
	
	// ----------------------------------------------------------------------
	// |                             N E W                                  |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]], ["_groupType", GROUP_TYPE_IDLE, [GROUP_TYPE_IDLE]]];
		private _data = GROUP_DATA_DEFAULT;
		_data set [GROUP_DATA_ID_SIDE, _side];
		_data set [GROUP_DATA_ID_TYPE, _groupType];
		_data set [GROUP_DATA_ID_MUTEX, MUTEX_NEW()];
		SET_VAR(_thisObject, "data", _data);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		// todo
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           A D D   U N I T                          |
	// ----------------------------------------------------------------------
	
	METHOD("addUnit") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select GROUP_DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _unitList = _data select GROUP_DATA_ID_UNITS;
		_unitList pushBackUnique _unit;
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        R E M O V E   U N I T                       |
	// ----------------------------------------------------------------------
	
	METHOD("removeUnit") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select GROUP_DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _unitList = _data select GROUP_DATA_ID_UNITS;
		_unitList = _unitList - [_unit];
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                         G E T   U N I T S                          |
	// ----------------------------------------------------------------------
	
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
	
	// ----------------------------------------------------------------------
	// |                         G E T   T Y P E                            |
	// ----------------------------------------------------------------------
	
	METHOD("getType") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select GROUP_DATA_ID_TYPE
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                  G E T   G R O U P   H A N D L E                   |
	// ----------------------------------------------------------------------
	
	/*
	Returns a valid group handle of this group. Creates a group with createGroup if it wasn't created yet.
	*/
	
	METHOD("getGroupHandle") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select GROUP_DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
		if (isNull _groupHandle) then { //Check if the group has been spawned
			private _side = _data select GROUP_DATA_ID_SIDE;
			// Spawn the group
			_groupHandle = createGroup [_side, true]; //side, delete when empty
			_data set [GROUP_DATA_ID_GROUP_HANDLE, _groupHandle];
		};
		MUTEX_UNLOCK(_mutex);
		_groupHandle
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                     S E T / G E T   G A R R I S O N                |
	// ----------------------------------------------------------------------
	// Sets the garrison of this garrison (use Garrison::addGroup to add a group to a garrison)
	METHOD("setGarrison") {
		params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];
		private _data = GET_VAR(_thisObject, "data");
		_data set [GROUP_DATA_ID_GARRISON, _garrison];
		
		// Set the garrison of all units in this group
		private _units = _data select GROUP_DATA_ID_UNITS;
		{ CALL_METHOD(_x, "setGarrison", [_thisObject]); } forEach _units;
	} ENDMETHOD;
	
	// Returns the garrison of this group
	METHOD("getGarrison") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select GROUP_DATA_ID_GARRISON
	} ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |                 H A N D L E   U N I T   K I L L E D                |
	// ----------------------------------------------------------------------

	METHOD("handleUnitKilled") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |              H A N D L E   U N I T   D E S P A W N E D             |
	// ----------------------------------------------------------------------

	METHOD("handleUnitDespawned") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]] ];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                 H A N D L E   U N I T   S P A W N E D              |
	// ----------------------------------------------------------------------

	METHOD("handleUnitSpawned") {
		params [["_thisObject", "", [""]], "_unit"];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |         C R E A T E   U N I T S   F R O M   T E M P L A T E        |
	// ----------------------------------------------------------------------
	
	// Creates units from template and adds them to this given group
	// Returns amount of units added
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
	
	// ----------------------------------------------------------------------
	// |                           C R E A T E   A I
	// ----------------------------------------------------------------------
	
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
	
	// ----------------------------------------------------------------------
	// |                           G E T   A I
	// ----------------------------------------------------------------------
	
	METHOD("getAI") {
		params [["_thisObject", "", [""]]];
		
		pr _data = GETV(_thisObject, "data");
		_data select GROUP_DATA_ID_AI
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |         S P A W N
	// | Spawns all units in this group at specified location
	// ----------------------------------------------------------------------
	METHOD("spawn") {
		params [["_thisObject", "", [""]], ["_loc", "", [""]]];
		pr _data = GETV(_thisObject, "data");
		pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
		pr _groupType = _data select GROUP_DATA_ID_TYPE;
		{
			private _unit = _x;
			private _unitData = CALL_METHOD(_unit, "getMainData", []);
			private _args = _unitData + [_groupType]; // ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_className", "", [""]], ["_groupType", "", [""]]
			private _posAndDir = CALL_METHOD(_loc, "getSpawnPos", _args);
			CALL_METHOD(_unit, "spawn", _posAndDir);
		} forEach _groupUnits;
		
		// Set group default behaviour
		pr _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
		_groupHandle setBehaviour "SAFE";
		
		// Create an AI for this group
		CALLM0(_thisObject, "createAI");
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |         D E S P A W N
	// | Despawns all units in this group
	// ----------------------------------------------------------------------
	METHOD("despawn") {
		params [["_thisObject", "", [""]], ["_loc", "", [""]]];
		pr _data = GETV(_thisObject, "data");
		pr _AI = _data select GROUP_DATA_ID_AI;
		
		// Switch off their brain
		// We must safely delete the AI object because it might be currently used in its own thread
		pr _msg = MESSAGE_NEW_SHORT(_AI, AI_MESSAGE_DELETE);
		pr _msgID = CALLM2(_AI, "postMessage", _msg, true);
		CALLM(_thisObject, "waitUntilMessageDone", [_msgID]);
		_data set [GROUP_DATA_ID_AI, ""];
		
		// Despawn everything
		pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
		{
			CALL_METHOD(_x, "despawn", []);
		} forEach _groupUnits;
		
		// Delete the group handle
		pr _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
		if (count units _groupHandle > 0) then {
			diag_log format ["[Group] Error: group is not empty at despawning: %1. Units remaining: %2", _data, units _groupHandle];
		} else {			
			deleteGroup _groupHandle;
		};
		_data set [GROUP_DATA_ID_GROUP_HANDLE, grpNull];
	} ENDMETHOD;
	
	
	// ========================= AI-related =====================================
	
	// ----------------------------------------------------------------------
	// |         G E T   S U B A G E N T S
	// | Returns the list of agents which have an AI object which must be processed through its process method
	// ----------------------------------------------------------------------
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
	
	METHOD("getPossibleGoals") {
		["GoalGroupRelax"]
	} ENDMETHOD;
	
	METHOD("getPossibleActions") {
		[]
	} ENDMETHOD;
	
	
	
	// ======================== OWNERSHIP RELATED ================================
	
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
	
	// Must handle transfer of ownership of underlying objects
	// Must return true if all objects have been successfully transfered and return false otherwise
	// You can also clear unneeded variables of this object here
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
	
ENDCLASS;