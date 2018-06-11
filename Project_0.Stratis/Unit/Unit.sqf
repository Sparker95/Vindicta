/*
Unit class.
A virtualized Unit is a man, vehicle or a drone which can be spawned or not spawned.

Author: Sparker
10.06.2018
*/

#include "Unit.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"

CLASS(UNIT_CLASS_NAME, "")
	VARIABLE("data");
	STATIC_VARIABLE("all");
	
	// ----------------------------------------------------------------------
	// |                             N E W                                  |
	// ----------------------------------------------------------------------
					
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]]];

		//Check argument validity
		private _valid = false;
		//Check template
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
		if (!_valid) exitWith { SET_MEM(_thisObject, "data", []); };
		//Check group
		if(_group == "" && _catID == T_INF) exitWith { diag_log "[Unit] Error: men must be added with a group!";};
		
		//Add this unit to a group
		if(_group != "") then {
			CALL_METHOD(_group, "addUnit", [_thisObject]);
		};
		
		//If a random class was requested to be added
		private _class = "";
		if(_classID == -1) then {
			private _classData = [_template, _catID, _subcatID] call t_fnc_selectRandom;
			_class = _classData select 0;
		} else {
			_class = [_template, _catID, _subcatID, _classID] call t_fnc_select;
		};
		
		//Create the data array
		private _data = DATA_DEFAULT;
		_data set [DATA_ID_CAT, _catID];
		_data set [DATA_ID_SUBCAT, _subcatID];
		_data set [DATA_ID_CLASS_NAME, _class];
		_data set [DATA_ID_MUTEX, MUTEX_NEW()];
		_data set [DATA_ID_GROUP, _group];
		SET_MEM(_thisObject, "data", _data);
		
		//Push the new object into the array with all units
		private _allArray = GET_STATIC_MEM(UNIT_CLASS_NAME, "all");
		_allArray pushBack _thisObject;
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params["_thisObject"];
		private _data = GET_MEM(_thisObject, "data");
		private _mutex = _data select DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		//Delete this unit from the physical world
		private _objectHandle = _data select DATA_ID_OBJECT_HANDLE;
		if (!(isNull _objectHandle)) then {
			deleteVehicle _objectHandle;
		};
		
		//Remove this unit from array with all units
		private _allArray = GET_STATIC_MEM(UNIT_CLASS_NAME, "all");
		_allArray = _allArray - [_thisObject];
		MUTEX_UNLOCK(_mutex);
		SET_MEM(_thisObject, "data", nil);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                             I S V A L I D                          |
	// ----------------------------------------------------------------------
	
	//Checks if the created unit is valid(check the constructor code)
	//After creating a new unit, make sure it's valid before adding it to other objects
	METHOD("isValid") {
		params ["_thisObject"];
		private _data = GET_MEM(_thisObject, "data");
		//Return true if the data array is of the correct size
		( (count _data) == DATA_SIZE)
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                         I S S P A W N E D                          |
	// ----------------------------------------------------------------------
	
	//Returns true if the unit is spawned
	METHOD("isSpawned") {
		params ["_thisObject"];
		private _mutex = _data select DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _return = !( isNull (_data select DATA_ID_OBJECT_HANDLE));
		MUTEX_UNLOCK(_mutex);
		_return
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                             S P A W N                              |
	// ----------------------------------------------------------------------
	
	METHOD("spawn") {
		params ["_thisObject", "_pos", "_dir"];
		//Unpack data
		private _data = GET_MEM(_thisObject, "data");
		private _mutex = _data select DATA_ID_MUTEX;
		
		//Lock the mutex
		MUTEX_LOCK(_mutex);
		
		//Unpack more data...
		private _objectHandle = _data select DATA_ID_OBJECT_HANDLE;
		if (isNull _objectHandle) then { //If it's not spawned yet
			private _className = _data select DATA_ID_CLASS_NAME;
			private _group = _data select DATA_ID_GROUP;
			
			//Perform object creation
			private _catID = _data select DATA_ID_CAT;
			switch(_catID) do {
				case T_INF: {
					private _groupHandle = CALL_METHOD(_group, "getGroupHandle", []);
					_objectHandle = _groupHandle createUnit [_className, _pos, [], 10, "FORM"];
					[_objectHandle] joinSilent _groupHandle; //To force the unit join this side
				};
				case T_VEH: {
				};
				case T_DRONE: {
				};
			};
			if (_group != "") then { CALL_METHOD(_group, "handleUnitSpawned", []) };
			_data set [DATA_ID_OBJECT_HANDLE, _objectHandle];
			_objectHandle setDir _dir;
			_objectHandle setPos _pos;
		};		
		//Unlock the mutex
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           D E S P A W N                            |
	// ----------------------------------------------------------------------
	
	METHOD("despawn") {
		params ["_thisObject"];
		//Unpack data
		private _data = GET_MEM(_thisObject, "data");
		private _mutex = _data select DATA_ID_MUTEX;
		
		//Lock the mutex
		MUTEX_LOCK(_mutex);
		
		//Unpack more data...
		private _objectHandle = _data select DATA_ID_OBJECT_HANDLE;
		if (!(isNull _objectHandle)) then { //If it's been spawned before
			deleteVehicle _objectHandle;
			private _group = _data select DATA_ID_GROUP;
			if (_group != "") then { CALL_METHOD(_group, "handleUnitDespawned", []) };
			_data set [DATA_ID_OBJECT_HANDLE, objNull];
		};		
		//Unlock the mutex
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E U N I T K I L L E D                 |
	// ----------------------------------------------------------------------
	
	//Called by event dispatcher	
	METHOD("handleKilled") {
		params ["_thisObject"];
		//Oh no, Johny is down! What should we do?
	} ENDMETHOD;
	
	
ENDCLASS;

SET_STATIC_MEM("Unit", "all", []);