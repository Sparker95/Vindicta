#include "common.hpp"

#define OOP_CLASS_NAME GoalUnitAmbientAnim
CLASS("GoalUnitAmbientAnim", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_AMBIENT_ANIM, [[], objNull]] ],	// Required parameters
			[ [TAG_DURATION_SECONDS, [0]], [TAG_ANIM, [""]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		// Goal is not relevant if the target is occupied
		private _target = GET_PARAMETER_VALUE(_parameters, TAG_TARGET_AMBIENT_ANIM);
		private _targetOccupied = _target getVariable ["vin_occupied", false];	// True if someone has occupied this object
		private _currentObject = GETV(_ai, "interactionObject");				// Object this bot is currently using
		private _occupiedByMe = _currentObject isEqualTo _target;				// True if this bot is using this object
		OOP_INFO_3("calculateRelevance: AI: %1, _occupiedByMe: %2, _targetOccupied: %3", _ai, _occupiedByMe, _targetOccupied);
		/*
		This is relevant in two cases:
		object is occupied and this bot uses this object
		object is not occupied and this bot is not using this object
		*/
		if (_target isEqualType objNull) then {
			if ( _occupiedByMe isEqualTo _targetOccupied) then {
				OOP_INFO_0("High relevance");
				GETSV(_thisClass, "relevance");
			} else {
				OOP_INFO_0("Target is occupied, goal is irrelevant");
				0;
			};
		} else {
			GETSV(_thisClass, "relevance");
		};
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_parameters")];

		// Mark this as occupied instantly
		private _target = GET_PARAMETER_VALUE(_parameters, TAG_TARGET_AMBIENT_ANIM);
		_target setVariable ["vin_preoccupied", true];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Specify move radius
		// We don't need it to be too precise
		_parameters pushBack [TAG_MOVE_RADIUS, 2.5];
	ENDMETHOD;

	public STATIC_METHOD(onGoalAdded)
		params ["_thisClass", P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		// Mark this as occupied instantly right when goal is added, so that group AI doesn't assign this place to many units
		private _target = GET_PARAMETER_VALUE(_parameters, TAG_TARGET_AMBIENT_ANIM);
		_target setVariable ["vin_preoccupied", true];
		
	ENDMETHOD;

	public STATIC_METHOD(onGoalDeleted)
		params ["_thisClass", P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _target = GET_PARAMETER_VALUE(_parameters, TAG_TARGET_AMBIENT_ANIM);
		_target setVariable ["vin_preoccupied", false];

	ENDMETHOD;

	// Must return a bool, true or false, if unit can talk while doing this goal
	// Default is false;
	STATIC_METHOD(canTalk)
		true;
	ENDMETHOD;

ENDCLASS;