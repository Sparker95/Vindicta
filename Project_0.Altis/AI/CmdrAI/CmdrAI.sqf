#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_PROFILE

#include "common.hpp"

// Commander planning AI
CLASS("CmdrAI", "")
	VARIABLE("side");
	VARIABLE("activeActions");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_side")];
		T_SETV("side", _side);
		T_SETV("activeActions", []);
	} ENDMETHOD;

	// METHOD("isValidAttackTarget") {
	// 	params [P_THISOBJECT, P_STRING("_garrison")];
	// 	T_PRVAR(side);
	// 	!CALLM0(_garrison, "isDead") and CALLM0(_garrison, "getSide") != _side
	// } ENDMETHOD;

	// METHOD("isValidAttackSource") {
	// 	params [P_THISOBJECT, P_STRING("_garrison")];
	// 	T_PRVAR(side);
	// 	!CALLM0(_garrison, "isDead") and CALLM0(_garrison, "getSide") == _side
	// } ENDMETHOD;

	// METHOD("isValidTakeOutpostTarget") {
	// 	params [P_THISOBJECT, P_STRING("_outpost")];
	// 	T_PRVAR(side);
	// 	CALLM0(_outpost, "getSide") != _side
	// } ENDMETHOD;
	
	// fn_isValidAttackTarget = {
	// 	!CALLM0(_this, "isDead") and CALLM0(_this, "getSide") != _side
	// };

	// fn_isValidAttackSource = {
	// 	!CALLM0(_this, "isDead") and CALLM0(_this, "getSide") == _side
	// };

	// fn_isValidOutpostTarget = {
	// 	CALLM0(_this, "getSide") != _side
	// };

	METHOD("generateTakeOutpostActions") {
		params [P_THISOBJECT, P_STRING("_world")];
		T_PRVAR(activeActions);
		T_PRVAR(side);

		// Garrison must be alive
		private _garrisons = CALLM0(_world, "getAliveGarrisons") select { 
			// Must be on our side
			(CALLM0(_x, "getSide") == _side) and 
			// Must have at least a minimum strength
			{CALLM0(_x, "getStrength") > 10} and 
			// Must not be engaged in another action
			{ ! (GETV(_x, "currAction") isEqualType "") }
		};

		private _outposts = GETV(_world, "outposts") select {
			private _outpost = _x;
			// Only try to take empty or enemy outposts
			CALLM0(_outpost, "getSide") != _side and
			// Don't make duplicate take actions for the same outpost
			_activeActions findIf { 
				OBJECT_PARENT_CLASS_STR(_x) == "TakeOutpostAction" and 
				{ GETV(_x, "targetOutpostId") == GETV(_outpost, "id") }
			} == -1
		};

		private _actions = [];
		{
			private _garrisonId = GETV(_x, "id");
			{
				private _outpostId = GETV(_x, "id");
				private _params = [_garrisonId, GETV(_x, "id")];
				_actions pushBack NEW("TakeOutpostAction", _params);
			} forEach _outposts;
		} forEach _garrisons;

		_actions
	} ENDMETHOD;

	METHOD("generateAttackActions") {
		params [P_THISOBJECT, P_STRING("_world")];

		private _garrisons = GETV(_world, "garrisons");

		T_PRVAR(side);

		private _actions = [];

		// for "_i" from 0 to count _garrisons - 1 do {
		// 	private _enemyGarr = _garrisons select _i;
		// 	if(_enemyGarr call fn_isValidAttackTarget) then {
		// 		for "_j" from 0 to count _garrisons - 1 do {
		// 			private _ourGarr = _garrisons select _j;
		// 			if((_ourGarr call fn_isValidAttackSource) and (CALLM0(_ourGarr, "getStrength") > CALLM0(_enemyGarr, "getStrength"))) then {
		// 				private _params = [_j, _i];
		// 				_actions pushBack (NEW("AttackAction", _params));
		// 			};
		// 		};
		// 	};
		// };

		_actions
	} ENDMETHOD;

	// fn_isValidReinfGarr = {
	// 	if(CALLM0(_this, "isDead") or (CALLM0(_this, "getSide") != _side)) exitWith { false };
	// 	private _action = GETV(_this, "currAction");
	// 	if(!(_action isEqualType "")) exitWith { true };

	// 	OBJECT_PARENT_CLASS_STR(_action) != "ReinforceAction"
	// };

	METHOD("generateReinforceActions") {
		params [P_THISOBJECT, P_STRING("_world")];
		T_PRVAR(side);

		private _ourGarrisons = CALLM0(_world, "getAliveGarrisons") select { 
			// Must be on our side
			CALLM0(_x, "getSide") == _side and 
			// Not involved in another reinforce action
			{
				private _action = GETV(_x, "currAction");
				!(_action isEqualType "") or { OBJECT_PARENT_CLASS_STR(_action) != "ReinforceAction" }
			}
		};

		T_PRVAR(side);
		
		// Source garrisons must have a minimum strength
		private _srcGarrisons = _ourGarrisons select { 
			// Must have at least a minimum strength
			(CALLM0(_x, "getStrength") > 10) and 
			// Not involved in another action already
			{ !(GETV(_x, "currAction") isEqualType "") }
		};

		private _actions = [];
		{
			private _srcGarrison = _x;
			{
				private _tgtGarrison = _x;
				if(_srcGarrison != _tgtGarrison) then {
					private _params = [GETV(_srcGarrison, "id"), GETV(_tgtGarrison, "id")];
					_actions pushBack (NEW("ReinforceAction", _params));
				};
			} forEach _ourGarrisons;
		} forEach _srcGarrisons;

		_actions
	} ENDMETHOD;

	METHOD("generateRoadblockActions") {
		params [P_THISOBJECT, P_STRING("_world")];

		private _garrisons = GETV(_world, "garrisons");

		T_PRVAR(side);
		private _actions = [];

		_actions
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_STRING("_commander")];

		T_PRVAR(world);
		T_PRVAR(activeActions);
		
		// sync world
		private _realGarrisons = GETV(_commander, "garrisons");


		// Update actions in real world
		{ CALLM1(_x, "update", _world) } forEach _activeActions;

		// Remove complete actions
		private _completeActions = _activeActions select { GETV(_x, "complete") };

		// Unref completed actions
		{
			UNREF(_x);
		} forEach _completeActions;

		_activeActions = _activeActions - _completeActions;

		T_SETV("activeActions", _activeActions);
	} ENDMETHOD;

	METHOD("plan") {
		params [P_THISOBJECT];

		T_PRVAR(world);
		T_PRVAR(activeActions);

		OOP_DEBUG_0("Copying simworld ...");

		// Copy world to simworld
		private _simWorld = CALLM0(_world, "simCopy");

		OOP_DEBUG_0("Applying %1 active actions to simworld new actions ...");

		PROFILE_SCOPE_START(ApplyActive);
		// Apply active actions to the simworld
		{
			CALLM1(_x, "applyToSim", _simWorld);
		} forEach _activeActions;
		PROFILE_SCOPE_END(ApplyActive, 0.1);

		OOP_DEBUG_0("Generating new actions ...");

		PROFILE_SCOPE_START(GenerateActions);
		// Generate possible actions
		private _newActions = 
			  T_CALLM1("generateTakeOutpostActions", _simWorld) 
			//+ T_CALLM1("generateAttackActions", _simWorld) 
			+ T_CALLM1("generateReinforceActions", _simWorld) 
			//+ T_CALLM1("generateRoadblockActions", _simWorld)
			;
		PROFILE_SCOPE_END(GenerateActions, 0.1);

		PROFILE_SCOPE_START(PlanActions);
		// Plan new actions
		while { count _newActions > 0 } do {
			PROFILE_SCOPE_START(UpdateScores);
			{
				CALLM1(_x, "updateScore", _simWorld);
			} forEach _newActions;
			PROFILE_SCOPE_END(UpdateScores, 0.1);

			_newActions = [_newActions, [], { CALLM0(_x, "getFinalScore") }, "DECEND"] call BIS_fnc_sortBy;

			private _bestAction = _newActions deleteAt 0;
			private _bestActionScore = CALLM0(_bestAction, "getFinalScore");

			if(_bestActionScore <= 0.001) exitWith {};

			REF(_bestAction);
			_activeActions pushBack _bestAction;

			PROFILE_SCOPE_START(ApplyNewActionToSim);
			// Apply new action to simworld
			CALLM1(_bestAction, "applyToSim", _simWorld);
			PROFILE_SCOPE_END(ApplyNewActionToSim, 0.1);
		};
		PROFILE_SCOPE_END(PlanActions, 0.1);

		// Delete any remaining actions
		{
			DELETE(_x);
		} forEach _newActions;

		T_SETV("activeActions", _activeActions);
	} ENDMETHOD;

ENDCLASS;
