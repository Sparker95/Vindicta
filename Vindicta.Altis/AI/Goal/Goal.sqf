#define OFSTREAM_FILE "AI.rpt"
#include "..\..\common.h"
#include "..\WorldState\WorldState.hpp"
#include "..\parameterTags.hpp"

/*
Class: Goal
Every goal is static, that is, not instantiated.
*/

#define pr private

#define OOP_CLASS_NAME Goal
CLASS("Goal", "")

	STATIC_VARIABLE("effects"); // Effects world state
	STATIC_VARIABLE("predefinedAction"); // A single action which clearly satisfies this goal, if A* usage is not intended for this goal
	STATIC_VARIABLE("relevance");

	// We don't need NEW and DELETE because goals don't need to be instantiated

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD(new)
		params [P_THISOBJECT];
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------

	METHOD(delete)
		params [P_THISOBJECT];
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |          G E T   P O S S I B L E   P A R A M E T E R S             |
	// ----------------------------------------------------------------------
	/*
	Method: getPossibleParameters

	Other classes must override that to declare parameters passed to goal! 

	Returns array [requiredParameters, optionalParameters]
	requiredParameters and optionalParameters are arrays of: [tag, type]
		tag - string
		type - some value against which isEqualType will be used
	*/
	STATIC_METHOD(getPossibleParameters)
		[
			[],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	/*
	Method: getCommonParameters

	Other classes must override that to declare parameters passed to action.
	Typically some base class of multiple actions can have some common parameters.

	Returns array [requiredParameters, optionalParameters]
	requiredParameters and optionalParameters are arrays of: [tag, type]
		tag - string
		type - some value against which isEqualType will be used
	*/
	STATIC_METHOD(getCommonParameters)
		[
			[],	// Required parameters
			[ [TAG_INSTANT, [false]] ]	// Optional parameters
		]
	ENDMETHOD;

	// Verifies parameters
	STATIC_METHOD(verifyParameters)
		params [P_THISCLASS, P_ARRAY("_parameters")];

		pr _allGood = true;
		pr _pPossible = CALLSM0(_thisClass, "getPossibleParameters");
		_pPossible params ["_pRequired", "_pOptional"];
		pr _pCommon = CALLSM0(_thisClass, "getCommonParameters");
		_pCommon params ["_pCommonRequired", "_pCommonOptional"];
		_pAllowed = _pRequired + _pOptional + _pCommonRequired + _pCommonOptional; // Instant is always allowed
		
		// Verify that no illegal parameters are passed
		{
			pr _tag = _x#0;
			pr _value = _x#1;
			pr _found = _pAllowed findIf {(_x#0) == _tag};
			if (isNil "_value") then {
				OOP_ERROR_1("Value of parameter %1 is nil!", _tag);
			};
			if (_found == -1) then {
				// Goals might extend their parameters
				// So there are in fact no forbidden parameters
				//OOP_ERROR_3("%1: Illegal parameter: %2, allowed parameters: %3", _thisClass, _tag, _pAllowed);
				//_allGood = false;
			} else {
				// Verify type
				pr _types = _pAllowed#_found#1;
				pr _foundType = _types findIf {_value isEqualType _x};
				if (_foundType == -1) then {
					OOP_ERROR_4("%1: Wrong parameter type for %2: %3, expected: %4", _thisClass, _tag, typeName (_x#1), _types apply {typeName _x});
					_allGood = false;
				};
			};
		} forEach _parameters;

		// Verify that all required parameters are passed
		{
			pr _tag = _x#0;
			pr _found = _parameters findIf {(_x#0) == _tag};
			if (_found == -1) then {
				OOP_ERROR_3("%1: Required parameter not found: %2, passed parameters: %3", _thisClass, _tag, _parameters);
				_allGood = false;
			};
		} forEach (_pRequired + _pCommonRequired);

		_allGood;
	ENDMETHOD;


	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	// By default returns instrinsic goal relevance

	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		pr _intrinsicRelevance = GETSV(_thisClass, "relevance");
		#ifdef DEBUG_GOAP
		if (isNil "_intrinsicRelevance") then {
			OOP_ERROR_1("Relevance of goal %1 is nil!", _thisClass);
		};
		#endif
		 // Return relevance
		_intrinsicRelevance
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters

	public STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		// Return predefined action from the database
		pr _actionClass = GETSV(_thisClass, "predefinedAction");
		if (!(isNil "_actionClass")) then {
			if (!(_actionClass == "")) then {
				// Also pass the parameter from the goal to the action
				pr _args = [_AI, _parameters];
				pr _action = NEW(_actionClass, _args);
				_action
			} else {
				// Return no action
				""
			};
		} else {
			// Return no action
			""
		};
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                      G E T   E F F E C T S
	// ----------------------------------------------------------------------
	// This method is only needed for goals without predefined actions, because they must use A* planner instead
	// By default this method returns the value from the database
	// This method must be redefined for goals that return effects which are not static and are not dependant on goal parameter
	// Example: "Move" goal can return world state with 'position' property equal to parameter thus does not need to reimplement this method
	// "HealYourself" goal can return a standard world state effect from database, thus doesn't need to reimplement this method
	// "GoToNearestCover" can't derive its effect from parameter and is not static, but is supplied by internal logic, therefore this goal must implement this method

	public STATIC_METHOD(getEffects)
		pr _paramsGood = params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		if (!_paramsGood) then {
			DUMP_CALLSTACK;
		};

		// Return effects from the database
		pr _effects = GETSV(_thisClass, "effects");
		_effects = +_effects;

		// If the parameters were specified, try to apply them to the effects
		if ((count _parameters) > 0) then {
			pr _success = [_effects, _parameters] call ws_applyParametersToGoalEffects;

			// If parameter could not be matched to a world state property, print an error
			if (!_success) then {
				diag_log format ["[%1::getEffects] Error: Parameter was supplied but could not be applied to goal effect! WS: %2,  parameters: %3",
					_thisClass, [_effects] call ws_toString, _parameters];

				// Clear all properties
				pr _size = [_effects] call ws_getSize;
				for "_i" from 0 to (_size - 1) do {
					[_effects, _i] call ws_clearProperty;
				};
				_effects
			} else {
				_effects;
			};
		} else {
			_effects
		};
	ENDMETHOD;

	/*
	Updates current world state as perceived by this goal.
	Does nothing by default.
	You can override it and modify the passed _ws world state.
	*/
	STATIC_METHOD(onGoalChosen)
		//params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];
	ENDMETHOD;

	// Gets called when an external goal of this class is added to AI
	public STATIC_METHOD(onGoalAdded)
		params ["_thisClass", P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;

	// Gets called when an external goal of this class is removed from an AI
	public STATIC_METHOD(onGoalDeleted)
		params ["_thisClass", P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;

	// Gets called if plan generation is failed
	STATIC_METHOD(onPlanFailed)
		//params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;

	// Called when this goal was reached (action has returned ACTION_STATE_COMPLETED)
	STATIC_METHOD(onGoalCompleted)
		// params [P_THISCLASS, P_OOP_OBJECT("_AI")];
	ENDMETHOD;

	// Called when this goal was failed (action has returned ACTION_STATE_FAILED)
	STATIC_METHOD(onGoalFailed)
		// params [P_THISCLASS, P_OOP_OBJECT("_AI")];
	ENDMETHOD;

ENDCLASS;

SETSV("Goal", "effects", []);
