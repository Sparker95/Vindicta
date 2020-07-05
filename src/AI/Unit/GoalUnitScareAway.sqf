#include "common.hpp"

/*
The goal of Warning someone with a shot

Author: Jeroen 11.12.2018
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitScareAway
CLASS("GoalUnitScareAway", "GoalUnit")
	
	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_SCARE_AWAY, [objNull]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
			
		// We want to scare away a unit if there is one near by
		pr _query = WF_NEW();
		[_query, WF_TYPE_UNIT_ANNOYED_BY] call wf_fnc_setType;

		pr _wf = CALLM(_AI, "findWorldFact", [_query]);
		
		// If noone is annoying then don't bother
		if (isNil "_wf") exitWith {
			0;
		};

		// Lets teach him some manners
		GETSV(_thisClass, "relevance");
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Find the unit to salute to from the world fact
		pr _target = objNull;
		pr _query = WF_NEW();
		[_query, WF_TYPE_UNIT_ANNOYED_BY] call wf_fnc_setType;
		pr _wf = CALLM(_AI, "findWorldFact", [_query]);
		if (!isNil "_wf") then {
			_target = WF_GET_SOURCE(_wf);
		};
		
		// Provide parameter for target
		_goalParameters pushBack [TAG_TARGET_SCARE_AWAY, _target];
	ENDMETHOD;

ENDCLASS;