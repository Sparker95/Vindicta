#include "common.hpp"

/*
The goal of saluting to someone

Author: Sparker 24.11.2018
*/


#define pr private

#define OOP_CLASS_NAME GoalUnitSalute
CLASS("GoalUnitSalute", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_SALUTE, [objNull]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	/*
	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];
	ENDMETHOD;
	*/
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		0; // for now

		/*
		// We want to salute if there is a fact that we have been saluted by someone
		pr _query = WF_NEW();
		[_query, WF_TYPE_UNIT_SALUTED_BY] call wf_fnc_setType;
		pr _wf = CALLM(_AI, "findWorldFact", [_query]);
		if (isNil "_wf") exitWith {0};
		
		// We have found the world fact
		// Now check if it is relevant
		// After responding to this world fact, the action will mark the world fact as irrelevant
		if ((WF_GET_RELEVANCE(_wf)) == 0) exitWith {0};
		
		diag_log format ["[GoalUnitSalute] high relevance for AI: %1", _AI];
		GETSV("GoalUnitSalute", "relevance")
		*/
	ENDMETHOD;

	

ENDCLASS;