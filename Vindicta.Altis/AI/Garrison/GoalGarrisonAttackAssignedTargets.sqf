#include "common.hpp"
/*
Goal for a garrison to go destroy some enemies
*/

#define pr private

#define OOP_CLASS_NAME GoalGarrisonAttackAssignedTargets
CLASS("GoalGarrisonAttackAssignedTargets", "Goal")

	public STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_POS_CLEAR_AREA, [[]]] ],	// Required parameters
			[ [TAG_CLEAR_RADIUS, [0]], [TAG_DURATION_SECONDS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;


	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// Return active relevance when we see assigned targets
		if (GETV(_AI, "awareOfAssignedTargets") && CALLM0(_AI, "isSpawned")) then {
			pr _intrinsicRelevance = GETSV(_thisClass, "relevance");
			 // Return relevance
			_intrinsicRelevance
		} else {
			0
		};
	ENDMETHOD;

	// Taken from GoalGarrisonClearArea
	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		pr _targetPos = GETV(_ai, "assignedTargetsPos");
		pr _assignedTargetsRadius = GETV(_ai, "assignedTargetsRadius");

		// The 'ClearArea' action will need these
		_goalParameters pushBack [TAG_POS_CLEAR_AREA, _targetPos];
		_goalParameters pushBack [TAG_CLEAR_RADIUS, _assignedTargetsRadius];

		pr _moveRadius = MAXIMUM(750, _assignedTargetsRadius + 500);

		// The 'Move' action will need these
		_goalParameters pushBack [TAG_MOVE_RADIUS, _moveRadius];
		_goalParameters pushBack [TAG_POS, _targetPos];

		CALLM1(_ai, "setMoveTargetPos", _targetPos);
		CALLM1(_ai, "setMoveTargetRadius", _moveRadius);
		CALLM0(_ai, "updatePositionWSP");

		// Reset 'has interacted' WSP
		pr _ws = GETV(_ai, "worldState");
		WS_SET(_ws, WSP_GAR_HAS_INTERACTED, false);

	ENDMETHOD;

ENDCLASS;