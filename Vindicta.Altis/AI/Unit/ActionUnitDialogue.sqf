#include "common.hpp"

/*
When active, bot will stand still and rotate towards the object he is talking to.
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitDialogue
CLASS("ActionUnitDialogue", "ActionUnit")

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_DIALOGUE, [objNull]] ],	// Required parameters
			[  ]	// Optional parameters
		]
	ENDMETHOD;

	VARIABLE("target");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _target = GET_PARAMETER_VALUE(_parameters, TAG_TARGET_DIALOGUE);
		T_SETV("target", _target);
	ENDMETHOD;

	protected override METHOD(activate)
		params [P_THISOBJECT];

		pr _AI = T_GETV("ai");
		CALLM0(_AI, "stopMoveToTarget");

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE;
	ENDMETHOD;

	// This action is always active.
	// When dialogue is deleted, the whole goal will change, and thus this action wil lterminate.
	public override METHOD(process)
		params [P_THISOBJECT];

		T_CALLM0("activateIfInactive");

		// Look at target
		pr _target = T_GETV("target");
		pr _hO = T_GETV("hO");
		_hO doWatch (ASLtoAGL eyepos _target);

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE;
	ENDMETHOD;

	public override METHOD(terminate)
		params [P_THISOBJECT];

		// Order unit to not look at dialogue target any more
		pr _hO = T_GETV("hO");
		_hO doWatch objNull;
	ENDMETHOD;

ENDCLASS;
