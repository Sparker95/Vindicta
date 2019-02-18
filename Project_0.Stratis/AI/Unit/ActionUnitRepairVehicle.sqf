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
Class: ActionUnit.ActionUnitRepairVehicle
Makes a unit play the repair animation and repair a target vehicle. Doesn't make the unit move anywhere.

Parameters: "vehicle" - <Unit> object
*/

#define pr private

CLASS("ActionUnitRepairVehicle", "ActionUnit")
	
	VARIABLE("veh");
	//VARIABLE("timeActivated");
	
	// ------------ N E W ------------
	
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _veh = CALLSM2("Action", "getParameterValue", _parameters, "vehicle");
		T_SETV("veh", _veh);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		pr _hO = T_GETV("hO");
		pr _veh = T_GETV("veh");
		pr _hVeh = CALLM0(_veh, "getObjectHandle");
		
		_hO action ["repairVehicle", _hVeh];
		
		//T_SETV("timeActivated", time);
		
		// Check if the unit is not an actual engineer
		if (!(_hO getUnitTrait "engineer")) then {
			[CALLM0(_veh, "getObjectHandle")] call AI_misc_fnc_repairWithoutEngineer; // Will do partial repairs of vehicle
		};	
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
		
		// Return ACTIVE state
		ACTION_STATE_COMPLETED
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		//if (_state == ACTION_STATE_ACTIVE) then {
		//};
		
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	/*
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	*/
	
ENDCLASS;