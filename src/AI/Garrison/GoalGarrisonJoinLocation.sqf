#include "common.hpp"

#define pr private

#define OOP_CLASS_NAME GoalGarrisonJoinLocation
CLASS("GoalGarrisonJoinLocation", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_LOCATION, [NULL_OBJECT]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		pr _targetLoc = GET_PARAMETER_VALUE(_goalParameters, TAG_LOCATION);
		pr _locPos = CALLM0(_targetLoc, "getPos");

		pr _border = CALLM0(_targetLoc, "getBorder");
		_border params ["_center", "_a", "_b"];

		// Estimate move radius
		pr _moveRadius = CALLSM1("GoalGarrisonMove", "getLocationMoveRadius", _targetLoc);

		// Set move pos and verify if we need to move there
		CALLM1(_ai, "setMoveTargetPos", _locPos);
		CALLM1(_ai, "setMoveTargetRadius", _moveRadius);
		CALLM0(_ai, "updatePositionWSP");

		// Reset 'at target location' WSP
		// We want to ensure the garrison joins the location regardless
		pr _ws = GETV(_ai, "worldState");
		WS_SET(_ws, WSP_GAR_AT_TARGET_LOCATION, false);

		// Add parameters to array
		_goalParameters pushBack [TAG_POS, _locPos];
		_goalParameters pushBack [TAG_MOVE_RADIUS, _moveRadius];

	ENDMETHOD;

ENDCLASS;