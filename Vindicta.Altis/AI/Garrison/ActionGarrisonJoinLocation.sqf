#include "common.hpp"

/*
All crew of vehicles mounts assigned vehicles.
*/

#define pr private

// Duration of this action

#define OOP_CLASS_NAME ActionGarrisonJoinLocation
CLASS("ActionGarrisonJoinLocation", "ActionGarrison")

	VARIABLE("loc");
	VARIABLE("locPos");
	VARIABLE("radius");

	public override METHOD(getPossibleParameters)
		[
			// We allow only unit OOP objects as target
			[ [TAG_LOCATION, [NULL_OBJECT]] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _loc = CALLSM2("Action", "getParameterValue", _parameters, TAG_LOCATION);
		T_SETV("loc", _loc);
		pr _locPos = CALLM0(_loc, "getPos");
		T_SETV("locPos", _locPos);
		pr _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS, 50);
		T_SETV("radius", _radius);
	ENDMETHOD;
	
	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT];

		pr _gar = T_GETV("gar");
		//CALLSM1("Location", "getNearestLocation", _locPos) params ["_loc", "_dist"];
		if(T_GETV("locPos") distance2D CALLM0(_gar, "getPos") > T_GETV("radius")) exitWith {
			ACTION_STATE_FAILED
		};

		pr _loc = T_GETV("loc");
		//if (_dist < 0.5) then {
		pr _locGars = CALLM2(_loc, "getGarrisons", CALLM0(_gar, "getSide"), CALLM0(_gar, "getType"));
		if (count _locGars > 0) then {
			// All's good, need to merge two garrisons now
			pr _args = [_gar];
			CALLM2(_locGars select 0, "postMethodAsync", "addGarrison", _args); // The other garrison can be on another computer
		} else {
			// There is no friendly garrison here of the same type, just attach here then
			CALLM1(_gar, "setLocation", _loc);
		};
		ACTION_STATE_COMPLETED
		//} else {
		//	OOP_ERROR_1("There is no location at %1!", _locPos);
		//	// There is no location here any more, wtf
		//	ACTION_STATE_FAILED
		//};
	ENDMETHOD;
	
	// // logic to run each update-step
	// public override METHOD(process)
	// 	params [P_THISOBJECT];
		
	// 	pr _state = T_CALLM0("activateIfInactive");

	// 	// Return the current state
	// 	T_SETV("state", _state);
	// 	_state
	// ENDMETHOD;
	
	// // logic to run when the action is satisfied
	// METHOD(terminate)
	// 	params [P_THISOBJECT];
		
	// ENDMETHOD;

ENDCLASS;