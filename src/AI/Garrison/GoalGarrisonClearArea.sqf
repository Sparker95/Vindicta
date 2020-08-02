#include "common.hpp"
/*
Goal for a garrison to go destroy some enemies
*/

#define pr private

#define OOP_CLASS_NAME GoalGarrisonClearArea
CLASS("GoalGarrisonClearArea", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_POS_CLEAR_AREA, [[]]] ],	// Required parameters
			[ [TAG_CLEAR_RADIUS, [0]], [TAG_DURATION_SECONDS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	// Gets called when an external goal of this class is added to AI
	public STATIC_METHOD(onGoalAdded)
		params ["_thisClass", P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		// Set variables in AI object so that garrison can identify targets associated with this goal
		// [[TAG_G_POS, _pos], [TAG_MOVE_RADIUS, _moveRadius], [TAG_CLEAR_RADIUS, _clearRadius], [TAG_DURATION_SECONDS, _timeOutSeconds]];
		pr _pos = GET_PARAMETER_VALUE(_parameters, TAG_POS_CLEAR_AREA);
		pr _radius = GET_PARAMETER_VALUE_DEFAULT(_parameters, TAG_CLEAR_RADIUS, 300);
		SETV(_AI, "assignedTargetsPos", _pos);
		SETV(_AI, "assignedTargetsRadius", _radius);
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		pr _targetPos = GET_PARAMETER_VALUE(_goalParameters, TAG_POS_CLEAR_AREA);
		pr _clearRadius = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_CLEAR_RADIUS, 100);

		pr _moveRadius = (_clearRadius + 250) min 400;
		_goalParameters pushBack [TAG_MOVE_RADIUS, _moveRadius];
		_goalParameters pushBack [TAG_POS, _targetPos];

		CALLM1(_ai, "setMoveTargetPos", _targetPos);
		CALLM1(_ai, "setMoveTargetRadius", _moveRadius);
		CALLM0(_ai, "updatePositionWSP");

		// Reset 'has interacted' WSP
		pr _ws = GETV(_ai, "worldState");
		WS_SET(_ws, WSP_GAR_HAS_INTERACTED, false);

	ENDMETHOD;

	// Gets called when an external goal of this class is removed from an AI
	public STATIC_METHOD(onGoalDeleted)
		params ["_thisClass", P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		SETV(_AI, "assignedTargetsPos", [0 ARG 0 ARG 0]);
		SETV(_AI, "assignedTargetsRadius", 0);
	ENDMETHOD;

ENDCLASS;