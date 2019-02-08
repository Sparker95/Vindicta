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
	VARIABLE("locationDataWest");
	VARIABLE("locationDataEast");
	VARIABLE("locationDataInd");
	VARIABLE("locationDataThis"); // Points to one of the above arrays depending on its side
	VARIABLE("notificationID");
	VARIABLE("notifications"); // Array with [task name, task creation time]

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]], ["_side", WEST, [WEST]], ["_msgLoop", "", [""]]];
		
		ASSERT_OBJECT_CLASS(_msgLoop, "MessageLoop");
		
		T_SETV("side", _side);
		T_SETV("msgLoop", _msgLoop);
		T_SETV("locationDataWest", []);
		T_SETV("locationDataEast", []);
		T_SETV("locationDataInd", []);
		pr _thisLDArray = switch (_side) do {
			case WEST: {T_GETV("locationDataWest")};
			case EAST: {T_GETV("locationDataEast")};
			case INDEPENDENT: {T_GETV("locationDataInd")};
		};
		T_SETV("locationDataThis", _thisLDArray);
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
			if (time - _time > 120) then {
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
	// Any side except EAST, WEST, INDEPENDENT means AI object will update its own knowledge about locations
	METHOD("updateLocationData") {
		params [["_thisObject", "", [""]], ["_locs", "", ["", []]], ["_side", CIVILIAN]];
		
		pr _thisSide = T_GETV("side");
		
		pr _ld = switch (_side) do {
			case WEST: {T_GETV("locationDataWest")};
			case EAST: {T_GETV("locationDataEast")};
			case INDEPENDENT: {T_GETV("locationDataInd")};
			default { _side = _thisSide; T_GETV("locationDataThis")};
		};
		
		// It accepts array of locations or one location
		// So convert parameter types here
		if (_locs isEqualType "") then {_locs = [_locs]};
		
		{ // foreach _locs
			pr _loc = _x;
			
			pr _CLD = CALL_STATIC_METHOD("AICommander", "createCLDFromLocation", [_loc]);
		
			if (_CLD isEqualTo []) then {
				OOP_ERROR_1("Can't update location data: %1", _loc);
			} else {		
				// Check this location already exists
				pr _locPos = _CLD select CLD_ID_POS;
				pr _locSide = _CLD select CLD_ID_SIDE;
				pr _entry = _ld findIf {(_x select CLD_ID_POS) isEqualTo _locPos};
				if (_entry == -1) then {
					// Add new entry
					_ld pushBack _CLD;
					
					systemChat "Discovered new location";
					
					if (_side == _thisSide && _side != _locSide) then {
						CALLM2(_thisObject, "showLocationNotification", _locPos, "DISCOVERED");
					};
					
				} else {
					pr _prevUpdateTime = (_ld select _entry select CLD_ID_TIME);
					_ld set [_entry, _CLD];
					
					systemChat "Location data was updated";
					
					// Show notification if we haven't updated this data for quite some time
					if (_side == _thisSide && _side != _locSide) then {
						if ((time - _prevUpdateTime) > 600) then {
							CALLM2(_thisObject, "showLocationNotification", _locPos, "UPDATED");
						};
					};
				};			
			};
				
		} forEach _locs;
		
		// Broadcast new data to clients, add it to JIP queue
		pr _JIPID = (_thisObject+"_JIP_"+(str _side)); // We use this object as JIP id because it's a string :D
		pr _args = [_ld, _side];
		REMOTE_EXEC_CALL_STATIC_METHOD("ClientMapUI", "updateLocationData", _args, _thisSide, _JIPID);
	} ENDMETHOD;
	
	
	
	
	// Shows notification and keeps track of it to delete some time later
	METHOD("showLocationNotification") {
		params ["_thisObject", ["_locPos", [], [[]]], ["_state", "", [""]]];
		
		//ade_dumpCallstack;
		
		pr _id = T_GETV("notificationID");
		pr _nots = T_GETV("notifications");
		switch (_state) do {
			case "DISCOVERED": {
				pr _descr = format ["Friendly units have discovered an enemy location at %1", mapGridPosition _locPos];
				_tsk = [T_GETV("side"), _thisObject+"task"+(str _id), [_descr, "Discovered location", ""], _locPos + [0], "CREATED", 0, false, "scout", true] call BIS_fnc_taskCreate;
				[_tsk, "SUCCEEDED", true] call BIS_fnc_taskSetState;
				_nots pushBack [_tsk, time];
			};
			
			case "UPDATED": {
				pr _descr = format ["Updated data on enemy garrisons at %1", mapGridPosition _locPos];
				_tsk = [T_GETV("side"), _thisObject+"task"+(str _id), [_descr, "Updated data on location", ""], _locPos + [0], "CREATED", 0, false, "intel", true] call BIS_fnc_taskCreate;
				[_tsk, "SUCCEEDED", true] call BIS_fnc_taskSetState;
				_nots pushBack [_tsk, time];
			};
		};
		T_SETV("notificationID", _id + 1);
	} ENDMETHOD;
	
	// Updates knowledge about friendly locations
	METHOD("updateFriendlyLocationsData") {
		params [["_thisObject", "", [""]]];
		
		pr _thisSide = T_GETV("side");
		
		// Now find all locations that are of this side
		pr _friendlyLocs = [];
		pr _allLocs = CALL_STATIC_METHOD("Location", "getAll", []);
		{
			pr _loc = _x;
			pr _gar = CALLM0(_loc, "getGarrisonMilitaryMain");
			pr _garSide = CALLM0(_gar, "getSide");
			if (_garSide == _thisSide) then {
				_friendlyLocs pushBack _loc;
			};
		} forEach _allLocs;
		
		OOP_INFO_1("Adding locations to database: %1", _friendlyLocs);
		
		// Update data on these locations
		if (count _friendlyLocs > 0) then {
			CALLM1(_thisObject, "updateLocationData", _friendlyLocs);
		};
	} ENDMETHOD;
	
	// Creates a LocationData array from Location
	STATIC_METHOD("createCLDFromLocation") {
		params ["_thisClass", ["_loc", "", [""]]];
		
		ASSERT_OBJECT_CLASS(_loc, "Location");
		
		pr _gar = CALLM0(_loc, "getGarrisonMilitaryMain");
		
		if (_gar == "") exitWith {[]};
		
		pr _value = CLD_NEW();
		_value set [CLD_ID_TYPE, 1]; // todo add types for locations at some point?
		_value set [CLD_ID_SIDE, CALLM0(_gar, "getSide")];
		pr _locPos = +(CALLM0(_loc, "getPos"));
		_locPos resize 2;
		_value set [CLD_ID_POS, _locPos];
		_value set [CLD_ID_TIME, time];
		// Now count all the units
		{
			_x params ["_catID", "_catSize"];
			pr _query = [[_catID, 0]];
			for "_subcatID" from 0 to (_catSize - 1) do {
				(_query select 0) set [1, _subcatID];
				pr _amount = CALLM1(_gar, "countUnits", _query);
				(_value select CLD_ID_UNIT_AMOUNT select _catID) set [_subcatID, _amount];
			};
			
		} forEach [[T_INF, T_INF_SIZE], [T_VEH, T_VEH_SIZE], [T_DRONE, T_DRONE_SIZE]];
		
		_value
	} ENDMETHOD;
	
ENDCLASS;