/*
Group class.
Group class is a set of Units. A group can have men, vehicles and drones.

Author: Sparker
11.06.2018
*/

#include "Group.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"

CLASS(GROUP_CLASS_NAME, "")
	
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
			//Spawn the group
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
			private _args = [_template, _catID, _subcatID, _classID, _thisObject];
			NEW("Unit", _args);
		} forEach _groupData;
		
		(count _groupData)
	} ENDMETHOD;
	
ENDCLASS;