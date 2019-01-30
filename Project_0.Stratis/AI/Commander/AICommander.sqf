#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"

/*
Class: AI.AICommander
AI class for the commander.

Author: Sparker 12.11.2018
*/

#define pr private

CLASS("AICommander", "AI")

	VARIABLE("side");
	VARIABLE("msgLoop");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]], ["_side", WEST, [WEST]], ["_msgLoop", "", [""]]];
		
		ASSERT_OBJECT_CLASS(_msgLoop, "MessageLoop");
		
		T_SETV("side", _side);
		T_SETV("msgLoop", _msgLoop);
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The group AI resides in its own thread
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		params [["_thisObject", "", [""]]];
		
		T_GETV("msgLoop");
	} ENDMETHOD;
	
ENDCLASS;