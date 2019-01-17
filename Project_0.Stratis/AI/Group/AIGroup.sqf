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
		
		//SETV(_thisObject, "worldState", _ws);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The group AI resides in its own thread
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		gMessageLoopGroupAI
	} ENDMETHOD;
	
	/*
	Method: handleUnitRemoved
	Handles what happens when a unit gets removed from its group, for instance when it gets killed.
	Currently it called handleUnitRemoved of the current action.
	
	Access: internal
	
	How to call: through postMethodAsync
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/
	METHOD("handleUnitRemoved") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		
		OOP_INFO_1("handleUnitRemoved: %1", _unit);
		
		// Call handleUnitRemoved of the current action, if it exists
		pr _currentAction = T_GETV("currentAction");
		if (_currentAction != "") then {
			CALLM1(_currentAction, "handleUnitRemoved", _unit);
		};
	} ENDMETHOD;
	
ENDCLASS;