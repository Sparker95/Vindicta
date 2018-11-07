/*
Garrison AI class
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"

#define pr private

CLASS("AIGarrison", "AI")

	METHOD("new") {
		params [["_thisObject", "", [""]]];
		pr _ws = [3] call ws_new; // todo WorldState size must depend on the agent
		SETV(_thisObject, "worldState", _ws);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The garrison AI resides in the same thread as the garrison
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;

ENDCLASS;