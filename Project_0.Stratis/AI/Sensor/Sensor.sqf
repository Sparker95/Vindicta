/*
Sensor class
It abstracts the abilities of an agent to receive information from the external world

Author: Sparker 08.11.2018
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"

#define pr private

CLASS("Sensor", "MessageReceiver")

	VARIABLE("agent"); // Pointer to the unit which holds this AI object
	VARIABLE("currentAction"); // The current action
	VARIABLE("currentGoal"); // The current goal
	VARIABLE("goalExtHigh"); // Goal suggested to this Agent by a high level AI
	VARIABLE("goalExtMedium"); // Goal suggested to this Agent by a medium level AI
	VARIABLE("goalExtLow"); // Goal suggested to this Agent by a low level AIVARIABLE("worldState"); // The world state relative to this Agent
	VARIABLE("worldState"); // The world state relative to this Agent
	VARIABLE("timer"); // The timer of this object
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		SETV(_thisObject, "agent", _agent);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	METHOD("update") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E   M E S S A G E
	// | 
	// ----------------------------------------------------------------------
	
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		pr _msgType = _msg select MESSAGE_ID_TYPE;
		switch (_msgType) do {	
			default {false}; // Message not handled
		};
	} ENDMETHOD;
	
ENDCLASS;