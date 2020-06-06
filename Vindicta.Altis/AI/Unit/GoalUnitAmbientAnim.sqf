#include "common.hpp"

#define OOP_CLASS_NAME GoalUnitAmbientAnim
CLASS("GoalUnitAmbientAnim", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_AMBIENT_ANIM, [[], objNull]] ],	// Required parameters
			[ [TAG_DURATION_SECONDS, [0]], [TAG_ANIM, [""]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		


	ENDMETHOD;

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		// Goal is not relevant if the target is occupied
		private _target = GET_PARAMETER_VALUE(_parameters, TAG_TARGET_AMBIENT_ANIM);
		private _targetOccupied = _target getVariable ["vin_occupied", false];
		private _currentObject = GETV(_ai, "interactionObject");
		if (_target isEqualType objNull) then {
			if (	_currentObject isEqualTo _target || !_targetOccupied) then {
				GETSV(_thisClass, "relevance");
			} else {
				0;
			};
		} else {
			GETSV(_thisClass, "relevance");
		};
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);
	ENDMETHOD;

ENDCLASS;