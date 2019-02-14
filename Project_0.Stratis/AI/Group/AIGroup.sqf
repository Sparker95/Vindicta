#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "groupWorldStateProperties.hpp"
#include "..\..\GlobalAssert.hpp"

/*
Class: AI.AIGroup
AI class for the group

Author: Sparker 12.11.2018
*/

#define pr private

CLASS("AIGroup", "AI")

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		ASSERT_OBJECT_CLASS(_agent, "Group");
		
		// Make sure that the needed MessageLoop exists
		ASSERT_GLOBAL_OBJECT(gMessageLoopGroupAI);
		
		// Initialize the world state
		//pr _ws = [WSP_GAR_COUNT] call ws_new; // todo WorldState size must depend on the agent
		//[_ws, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;
		
		// Initialize sensors
		pr _sensorTargets = NEW("SensorGroupTargets", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorTargets]);
		
		pr _sensorHealth = NEW("SensorGroupHealth", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorHealth]);
		
		// Initialize the world state
		pr _ws = [WSP_GROUP_COUNT] call ws_new; // todo WorldState size must depend on the agent
		[_ws, WSP_GROUP_ALL_VEHICLES_REPAIRED, true] call ws_setPropertyValue;
		[_ws, WSP_GROUP_ALL_VEHICLES_TOUCHING_GROUND, true] call ws_setPropertyValue;
		SETV(_thisObject, "worldState", _ws);
		
		// Set process interval
		CALLM1(_thisObject, "setProcessInterval", 3);		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The group AI resides in its own thread
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		gMessageLoopGroupAI
	} ENDMETHOD;
	
	/*
	Method: handleUnitsRemoved
	Handles what happens when units get removed from their group, for instance when they gets destroyed.
	Currently it deletes goals from units that have been given by this AI object and calls handleUnitsRemoved of the current action.
	
	Access: internal
	
	Parameters: _units
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		OOP_INFO_1("handleUnitsRemoved: %1", _units);
		
		// Delete goals that have been given by this object
		{
			pr _unitAI = CALLM0(_x, "getAI");
			if (!isNil "_unitAI") then {
				if (_unitAI != "") then {
					CALLM2(_unitAI, "deleteExternalGoal", "", _thisObject);
				};
			};
		} forEach _units;
		
		// Call handleUnitsRemoved of the current action, if it exists
		pr _currentAction = T_GETV("currentAction");
		if (_currentAction != "") then {
			CALLM1(_currentAction, "handleUnitsRemoved", _units);
		};
	} ENDMETHOD;
	
	/*
	Method: handleUnitsAdded
	Handles what happens when units get added to a group.
	Currently it calles handleUnitAdded of the current action.
	
	Access: internal
	
	Parameters: _unit
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		OOP_INFO_1("handleUnitsAdded: %1", _units);
		
		// Call handleUnitAdded of the current action, if it exists
		pr _currentAction = T_GETV("currentAction");
		if (_currentAction != "") then {
			CALLM1(_currentAction, "handleUnitsAdded", _units);
		};
	} ENDMETHOD;
	
ENDCLASS;