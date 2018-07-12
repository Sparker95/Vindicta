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
		params ["_thisObject", "_side"];
		private _data = DATA_DEFAULT;
		_data set [DATA_ID_SIDE, _side];
		_data set [DATA_ID_MUTEX, MUTEX_NEW()];
		SET_VAR(_thisObject, "data", _data);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params ["_thisObject"];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           A D D U N I T                            |
	// ----------------------------------------------------------------------
	
	METHOD("addUnit") {
		params ["_thisObject", "_unit"];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _unitList = _data select DATA_ID_UNIT_LIST;
		_unitList pushBackUnique _unit;
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        R E M O V E U N I T                         |
	// ----------------------------------------------------------------------
	
	METHOD("removeUnit") {
		params ["_thisObject", "_unit"];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _unitList = _data select DATA_ID_UNIT_LIST;
		_unitList = _unitList - [_unit];
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                         G E T U N I T S                            |
	// ----------------------------------------------------------------------
	
	METHOD("getUnits") {
		params ["_thisObject"];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _unitList = _data select DATA_ID_UNIT_LIST;
		private _return = +_unitList;
		MUTEX_UNLOCK(_mutex);
		_return
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                  G E T G R O U P H A N D L E                       |
	// ----------------------------------------------------------------------
	
	/*
	Returns a valid group handle of this group. Creates a group with createGroup if it wasn't created yet.
	*/
	
	METHOD("getGroupHandle") {
		params ["_thisObject"];
		private _data = GET_VAR(_thisObject, "data");
		private _mutex = _data select DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _groupHandle = _data select DATA_ID_GROUP_HANDLE;
		if (isNull _groupHandle) then { //Check if the group has been spawned
			private _side = _data select DATA_ID_SIDE;
			//Spawn the group
			_groupHandle = createGroup [_side, true]; //side, delete when empty
			_data set [DATA_ID_GROUP_HANDLE, _groupHandle];
		};
		MUTEX_UNLOCK(_mutex);
		_groupHandle
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E U N I T K I L L E D                 |
	// ----------------------------------------------------------------------

	METHOD("handleUnitKilled") {
		params ["_thisObject"];
	} ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E U N I T K I L L E D                 |
	// ----------------------------------------------------------------------

	METHOD("handleUnitDespawned") {
		params ["_thisObject", "_unit"];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                  H A N D L E U N I T S P A W N E D                 |
	// ----------------------------------------------------------------------

	METHOD("handleUnitSpawned") {
		params ["_thisObject", "_unit"];
	} ENDMETHOD;
	
ENDCLASS;