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
Makes a unit get into a specific vehicle.
Assumes the vehicle is on foot already.
*/

#define pr private

CLASS("ActionUnitGetInVehicle", "Action")

	VARIABLE("objectHandle");
	VARIABLE("vehHandle");
	VARIABLE("vehRole");
	
	// ------------ N E W ------------
	// _vehHandle - objectHandle of the vehicle to get in
	// _vehRole - one of "DRIVER", "GUNNER", "COMMANDER", "CARGO"
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_vehHandle", objNull, [objNull]], ["_vehRole", "", [""]] ];
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _oh = CALLM(_a, "getObjectHandle", []);
		SETV(_thisObject, "objectHandle", _oh);
		SETV(_thisObject, "vehHandle", _vehHandle);
		SETV(_thisObject, "vehRole", _vehRole);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];
		
		
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD; 

ENDCLASS;