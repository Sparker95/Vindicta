#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "LocationData.hpp"

/*
Class: AI.AICommander
AI class for the commander.

Author: Sparker 12.11.2018
*/

#define pr private

CLASS("AICommander", "AI")

	VARIABLE("side");
	VARIABLE("msgLoop");
	VARIABLE("locationData");
	VARIABLE("notificationID");
	VARIABLE("notifications"); // Array with [task name, task creation time]

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]], ["_side", WEST, [WEST]], ["_msgLoop", "", [""]]];
		
		ASSERT_OBJECT_CLASS(_msgLoop, "MessageLoop");
		
		T_SETV("side", _side);
		T_SETV("msgLoop", _msgLoop);
		T_SETV("locationData", []);
		T_SETV("notificationID", 0);
		T_SETV("notifications", []);
		
		// Create sensors
		pr _sensorLocation = NEW("SensorCommanderLocation", [_thisObject]);
		CALLM1(_thisObject, "addSensor", _sensorLocation);
		
		
	} ENDMETHOD;
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		// Delete old notifications
		pr _nots = T_GETV("notifications");
		pr _i = 0;
		while {_i < count (_nots)} do {
			(_nots select _i) params ["_task", "_time"];
			// If this notification ahs been here for too long
			if (time - _time > 60) then {
				[_task, T_GETV("side")] call BIS_fnc_deleteTask;
				// Delete this notification from the list				
				_nots deleteAt _i;
			} else {
				_i = _i + 1;
			};
		};
		
		// Call base class method
		CALL_CLASS_METHOD("AI", "process", []);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The group AI resides in its own thread
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		params [["_thisObject", "", [""]]];
		
		T_GETV("msgLoop");
	} ENDMETHOD;
	
	/*
	Method: (static)getCommanderAIOfSide
	Returns AICommander object that commands given side
	
	Parameters: _side
	
	_side - side
	
	Returns: <AICommander>
	*/
	STATIC_METHOD("getCommanderAIOfSide") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]]];
		switch (_side) do {
			case WEST: {
				gAICommanderWest
			};
			
			case EAST: {
				gAICommanderEast
			};
			
			case INDEPENDENT: {
				gAICommanderInd
			};
		};
	} ENDMETHOD;
	
	// Location data
	METHOD("updateLocationData") {
		params [["_thisObject", "", [""]], ["_CLD", [], [[]]]];
		pr _ld = T_GETV("locationData");
		
		pr _locPos = _CLD select CLD_ID_POS;
		
		// Fill missing fields
		_CLD set [CLD_ID_TIME, time];
		
		// Check this location already exists
		pr _entry = _ld findIf {(_x select CLD_ID_POS) isEqualTo _locPos};
		if (_entry == -1) then {
			// Add new entry
			_ld pushBack _CLD;
			
			systemChat "Discovered new location";
			
			CALLM2(_thisObject, "showLocationNotification", _locPos, "DISCOVERED");
			
		} else {
			pr _prevUpdateTime = (_ld select _entry select CLD_ID_TIME);
			_ld set [_entry, _CLD];
			
			systemChat "Location data was updated";
			
			// Show notification if we haven't updated this data for quite some time
			if (time - _prevUpdateTime > 600) then {
				CALLM2(_thisObject, "showLocationNotification", _locPos, "UPDATED");
			};
		};
	} ENDMETHOD;
	
	// Shows notification and keeps track of it to delete some time later
	METHOD("showLocationNotification") {
		params ["_thisObject", ["_locPos", [], [[]]], ["_state", "", [""]]];
		
		OOP_INFO_1("show notification called!!11");
		
		//ade_dumpCallstack;
		
		pr _id = T_GETV("notificationID");
		pr _nots = T_GETV("notifications");
		switch (_state) do {
			case "DISCOVERED": {
				pr _descr = format ["Friendly units have discovered an enemy location at %1", mapGridPosition _locPos];
				_tsk = [T_GETV("side"), _thisObject+"task"+(str _id), [_descr, "Discovered enemy location", ""], _locPos + [0], "CREATED", 0, false, "scout", true] call BIS_fnc_taskCreate;
				[_tsk, "SUCCEEDED", true] call BIS_fnc_taskSetState;
				_nots pushBack [_tsk, time];
			};
			
			case "UPDATED": {
				pr _descr = format ["Updated data on enemy garrisons at %1", mapGridPosition _locPos];
				_tsk = [T_GETV("side"), _thisObject+"task"+(str _id), [_descr, "Updated data on enemy location", ""], _locPos + [0], "CREATED", 0, false, "intel", true] call BIS_fnc_taskCreate;
				[_tsk, "SUCCEEDED", true] call BIS_fnc_taskSetState;
				_nots pushBack [_tsk, time];
			};
		};
		T_SETV("notificationID", _id + 1);
	} ENDMETHOD;
	
ENDCLASS;