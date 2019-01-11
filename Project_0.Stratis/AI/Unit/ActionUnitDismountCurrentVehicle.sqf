#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Author: Sparker 26.11.2018
*/

#define pr private

CLASS("ActionUnitDismountCurrentVehicle", "ActionUnit")
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		pr _return = GETV(_thisObject, "state");
		switch(GETV(_thisObject, "state")) do {
			case ACTION_STATE_ACTIVE : {
				pr _oh = GETV(_thisObject, "hO");
				// Did we dismount already?
				if (!((vehicle _oh) isEqualTo _oh)) then {
					// If yes, the action is complete
					SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
					_return = ACTION_STATE_COMPLETED;
				} else {
					// If not, order to dismount
					_oh action ["getOut", vehicle _oh];
				};				
			};
		};
		
		_return
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD; 

ENDCLASS;
