#include "common.hpp"

/*
Class: AI.AIGarrison
*/

#define pr private

CLASS("AIGarrison", "AI")

	// Array of targets known by this garrison
	VARIABLE("targets");
	
	VARIABLE("sensorHealth");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		// Initialize sensors
		pr _sensorHealth = NEW("SensorGarrisonHealth", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorHealth]);
		T_SETV("sensorHealth", _sensorHealth); // Keep reference to this sensor in case we want to update it
		
		pr _sensorTargets = NEW("SensorGarrisonTargets", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorTargets]);
		
		pr _loc = CALLM0(_agent, "getLocation");
		if (_loc != "") then {
			pr _sensorObserved = NEW("SensorGarrisonLocationIsObserved", [_thisObject]);
			CALLM1(_thisObject, "addSensor", _sensorObserved);
		};
		
		// Initialize the world state
		pr _ws = [WSP_GAR_COUNT] call ws_new; // todo WorldState size must depend on the agent
		[_ws, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_ALL_CREW_MOUNTED, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_ALL_INFANTRY_MOUNTED, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_VEHICLE_GROUPS_MERGED, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_VEHICLE_GROUPS_BALANCED, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_CLEARING_AREA, [0, 0, 0]] call ws_setPropertyValue;
		
		
		SETV(_thisObject, "worldState", _ws);
		SETV(_thisObject, "targets", []);
		
		// Set process interval
		CALLM1(_thisObject, "setProcessInterval", 1); //6);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The garrison AI resides in the same thread as the garrison
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;

	/*
	Method: handleGroupsAdded
	Handles what happens when groups get added while there is an active action.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD("handleGroupsAdded") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		pr _action = T_GETV("currentAction");
		if (_action != "") then {
			// Call it directly since it is in the same thread
			CALLM1(_action, "handleGroupsAdded", [_groups]);
		};
		
		nil
	} ENDMETHOD;


	/*
	Method: handleGroupsRemoved
	Handles a group being removed from its garrison while the AI object is still operational.
	Currently it deletes goals from groups that have been assigned by this AI object and calls handleGroupsRemoved of current action of this AI object, if it exists.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD("handleGroupsRemoved") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		// Delete goals that have been given by this object
		{
			pr _groupAI = CALLM0(_x, "getAI");
			if (!isNil "_groupAI") then {
				if (_groupAI != "") then {
					CALLM2(_groupAI, "deleteExternalGoal", "", _thisObject);
				};
			};
		} forEach _groups;
		
		pr _action = T_GETV("currentAction");
		if (_action != "") then {
			// Call it directly since it is in the same thread
			CALLM1(_action, "handleGroupsRemoved", [_groups]);
		};
		
		nil
	} ENDMETHOD;
	
	
	
	/*
	Method: handleUnitsRemoved
	Handles what happens when units get removed from their group, for instance when they gets destroyed.
	
	Access: internal
	
	Parameters: _units
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		// Update health sensor
		CALLM0(T_GETV("sensorHealth"), "update");
	} ENDMETHOD;
	
	/*
	Method: handleUnitsAdded
	Handles what happens when units get added to a group.
	
	Access: internal
	
	Parameters: _unit
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		// Update health sensor
		CALLM0(T_GETV("sensorHealth"), "update");
	} ENDMETHOD;

ENDCLASS;