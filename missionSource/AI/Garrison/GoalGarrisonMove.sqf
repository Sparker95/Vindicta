#include "common.hpp"
/*
Goal for a garrison to move somewhere
*/

#define pr private

#define OOP_CLASS_NAME GoalGarrisonMove
CLASS("GoalGarrisonMove", "Goal")

	public STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_POS, [[]]] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]], [TAG_MAX_SPEED_KMH, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	public STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		pr _targetPos = GET_PARAMETER_VALUE(_goalParameters, TAG_POS);
		pr _moveRadius = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_MOVE_RADIUS, 200);

		// Set move pos and verify if we need to move there
		CALLM1(_ai, "setMoveTargetPos", _targetPos);
		CALLM1(_ai, "setMoveTargetRadius", _moveRadius);
		CALLM0(_ai, "updatePositionWSP");
	ENDMETHOD;

	// Must use this method to get the move radius if we are moving to a location
	public STATIC_METHOD(getLocationMoveRadius)
		params [P_THISCLASS, P_OOP_OBJECT("_loc")];

		pr _border = CALLM0(_loc, "getBorder"); // [center, a, b, angle, isRectangle, c]
		pr _minSize = (_border#1) min (_border#2);

		CLAMP(_minSize * 0.5, 50, 250) // Clamp it within some reasonable range
	ENDMETHOD;

ENDCLASS;