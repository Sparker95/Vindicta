#include "common.hpp"

/*
The goal of Warning someone with a shot

Author: Jeroen 11.12.2018
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitScareAway
CLASS("GoalUnitScareAway", "Goal")
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
			
		// We want to scare away a unit if there is one near by
		pr _query = WF_NEW();
		[_query, WF_TYPE_UNIT_ANNOYED_BY] call wf_fnc_setType;

		pr _wf = CALLM(_AI, "findWorldFact", [_query]);
		
		if (isNil "_wf") exitWith {GOAL_RELEVANCE_BIAS_LOWER};
		
		
		diag_log format ["[GoalUnitWarningShot] high relevance for AI: %1", _AI];
		GOAL_RELEVANCE_UNIT_SCAREAWAY;// * _relevance;
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// If this goal has doesn't support planner and supports a predefined plan, this method must
	// create an Action and return it.
	// Otherwise it must return ""
	
	STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		diag_log "createPredefinedAction";
		
		// Find the unit to salute to from the world fact
		pr _target = objNull;
		pr _query = WF_NEW();
		[_query, WF_TYPE_UNIT_ANNOYED_BY] call wf_fnc_setType;
		pr _wf = CALLM(_AI, "findWorldFact", [_query]);
		if (!isNil "_wf") then {
			_target = WF_GET_SOURCE(_wf);
		};
		pr _args = [_AI, [[TAG_TARGET, _target]]];
		pr _action = NEW("ActionUnitScareAway", _args);
		
		diag_log format ["[GoalWarningshot:createPredefinedAction] AI: %1, created action to warningShot to: %2", _AI, _target];
		
		// Return the created action
		_action
	ENDMETHOD;

ENDCLASS;