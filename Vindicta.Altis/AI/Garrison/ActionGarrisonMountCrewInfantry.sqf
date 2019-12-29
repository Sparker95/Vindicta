#include "common.hpp"

#define pr private

// Crew and infantry will mount at the same time
// This action doesn't take parameters

CLASS("ActionGarrisonMountCrewInfantry", "ActionCompositeParallelGarrison")

	METHOD("new") {
		params ["_thisObject", ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _args = [_AI, [[TAG_MOUNT, true]]];
		pr _a0 = NEW("ActionGarrisonMountCrew", _args);
		pr _args = [_AI, [[TAG_MOUNT, true]]];
		pr _a1 = NEW("ActionGarrisonMountInfantry", _args);
		{
			CALLM1(_thisObject, "addSubactionToFront", _x);
		} forEach [_a0, _a1];
	} ENDMETHOD;

ENDCLASS;