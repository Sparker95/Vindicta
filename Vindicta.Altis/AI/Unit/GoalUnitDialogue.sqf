#include "common.hpp"

#define pr private

#define OOP_CLASS_NAME GoalUnitDialogue
CLASS("GoalUnitDialogue", "GoalUnit")

	// Must return a bool, true or false, if unit can talk while doing this goal
	// Default is false;
	STATIC_METHOD(canTalk)
		true;
	ENDMETHOD;

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_DIALOGUE, [objNull]] ],	// Required parameters
			[ ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _hO = GETV(_AI, "hO");

		// Check if a dialogue is running
		// If it's not running, then this goal is irrelevant
		pr _dlg = GETV(_AI, "dialogue");
		if (IS_NULL_OBJECT(_dlg) || {isNull GETV(_AI, "talkObject")}) exitWith {0;};

		// Check if current goal is sitting on a bench or something similar
		// If it is so, we don't need to actiate this goal
		// Because we can most likely already talk while doing the animation
		if (GETV(_ai, "currentGoal") == "GoalUnitAmbientAnim") exitWith {0;};

		// Perform generic checks
		pr _canTalk = CALLM0(_AI, "canTalk");
		if (!_canTalk) exitWith {0};

		pr _relevance = GETSV(_thisClass, "relevance");

		_relevance;
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

		// We must push this parameter tag for planner to choose appropriate action
		pr _target = GETV(_ai, "talkObject");
		_goalParameters pushBack [TAG_TARGET_DIALOGUE, _target];

		CALLM1(_ai, "setMoveTargetRadius", 3);
		_goalParameters pushBack [TAG_MOVE_RADIUS, 3];
		_goalParameters pushBack [TAG_MOVE_TARGET, _target];
	ENDMETHOD;

ENDCLASS;