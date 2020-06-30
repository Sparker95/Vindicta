#include "common.hpp"

#define OOP_CLASS_NAME ActionUnitIdle
CLASS("ActionUnitIdle", "ActionUnit")

	VARIABLE("timeToComplete");

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_DURATION_SECONDS, [0]] ],	// Required parameters
			[  ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _duration = CALLSM2("Action", "getParameterValue", _parameters, TAG_DURATION_SECONDS);

		T_SETV("timeToComplete", GAME_TIME + _duration);
	ENDMETHOD;

	public override METHOD(process)
		params [P_THISOBJECT];
		if(GAME_TIME > T_GETV("timeToComplete")) then {
			ACTION_STATE_COMPLETED
		} else {
			ACTION_STATE_ACTIVE
		};
	ENDMETHOD;
ENDCLASS;