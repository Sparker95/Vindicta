#include "common.hpp"

/*
Group will investigate some some point of interest from its memory.
Position is taken from AIGroup.pointsOfInterest array
*/

#define pr private

#define OOP_CLASS_NAME GoalGroupInvestigatePointOfInterest
CLASS("GoalGroupInvestigatePointOfInterest", "GoalGroup")

	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		// This goal is relevant when we have some point of interest active
		pr _poi = GETV(_ai, "pointsOfInterest");
		if (count _poi == 0) exitWith {0};

		GETSV("GoalGroupInvestigatePointOfInterest", "relevance");
	ENDMETHOD;
	
	public STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		private _actionSerial = NEW("ActionCompositeSerial", [_AI]);

		pr _posInvestigate = +(GETV(_AI, "pointsOfInterest") select 0);
		OOP_INFO_1("Investigating position: %1", _posInvestigate);
		pr _actionParams = [[TAG_POS, _posInvestigate], [TAG_MOVE_RADIUS, 30]];
		private _actionMove = NEW("ActionGroupMove", [_AI ARG _actionParams]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionMove);
		_actionSerial
	ENDMETHOD;

	// Called when this goal was reached (action has returned ACTION_STATE_COMPLETED)
	public STATIC_METHOD(onGoalCompleted)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		OOP_INFO_0("On goal completed");

		// Remove front most point of interest
		pr _poi = GETV(_ai, "pointsOfInterest");
		if (count _poi > 0) then {
			OOP_INFO_0("Deleted POI");
			_poi deleteAt 0;
		};
	ENDMETHOD;

	// Called when this goal was failed (action has returned ACTION_STATE_FAILED)
	public STATIC_METHOD(onGoalFailed)
		// params [P_THISCLASS, P_OOP_OBJECT("_AI")];
	ENDMETHOD;

ENDCLASS;