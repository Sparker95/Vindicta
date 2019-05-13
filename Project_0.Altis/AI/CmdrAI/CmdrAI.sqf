#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
// #define OOP_PROFILE

#include "common.hpp"

#define REINF_MAX_DIST 4000

// Commander planning AI
CLASS("CmdrAI", "")
	VARIABLE("side");
	VARIABLE("activeActions");

	METHOD("new") {
		params [P_THISOBJECT, P_SIDE("_side")];
		T_SETV("side", _side);
		T_SETV("activeActions", []);
	} ENDMETHOD;

	METHOD("generateTakeOutpostActions") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		T_PRVAR(activeActions);
		T_PRVAR(side);

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", []) select { 
			private _potentialSrcGarr = _x;
			// Must be our garrison (only ours actually exist here so this is redundant!)
			// Must be not already busy
			// Must be at a location
			// Must not be source of another inprogress take location mission
			if ((GETV(_potentialSrcGarr, "side") != _side) or 
				{ CALLM(_potentialSrcGarr, "isBusy", []) } or 
				{ IS_NULL_OBJECT(CALLM(_potentialSrcGarr, "getLocation", [])) } or 
				{ 
					T_PRVAR(activeActions);
					_activeActions findIf {
						GET_OBJECT_CLASS(_x) == "TakeLocationCmdrAction" and
						{ GETV(_x, "srcGarrId") == GETV(_potentialSrcGarr, "id") }
					} != NOT_FOUND
				}
				) then {
				false
			} else {
				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_potentialSrcGarr]);
				// Must have at least a minimum available eff
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			}
		};

		// Take tgt locations from future, so we take into account all in progress actions.
		private _tgtLocations = CALLM(_worldFuture, "getLocations", []) select { 
			// Must not have any of our garrisons already present (or this would be reinforcement action)
			IS_NULL_OBJECT(CALLM(_x, "getGarrison", [_side]))
		};

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			{
				private _tgtId = GETV(_x, "id");
				private _params = [_srcId, _tgtId];
				_actions pushBack (NEW("TakeLocationCmdrAction", _params));
			} forEach _tgtLocations;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 TakeOutpost actions from %2 garrisons to %3 locations", [count _actions ARG count _srcGarrisons ARG count _tgtLocations]);

		_actions
	} ENDMETHOD;

	METHOD("generateAttackActions") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		T_PRVAR(side);
		
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", []) select { 
			// Must be on our side and not involved in another action
			// TODO: We should be able to redirect for QRFs. Perhaps it 
			if((GETV(_x, "side") != _side) or { CALLM(_x, "isBusy", []) }) then {
				false
			} else {
				// Not involved in another reinforce action
				//private _action = CALLM(_x, "getAction", []);
				//if(!IS_NULL_OBJECT(_action) and { OBJECT_PARENT_CLASS_STR(_action) == "ReinforceCmdrAction" }) exitWith {false};

				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);

				// Must have at least a minimum strength of twice min efficiency
				//private _eff = GETV(_x, "efficiency");
				// !CALLM(_x, "isDepleted", []) and 
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			}
		};


		// Candidates are clusters that are still alive in the future.
		private _tgtClusters = CALLM(_worldFuture, "getAliveClusters", []);

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			{
				private _params = [_srcId, GETV(_x, "id")];
				_actions pushBack (NEW("QRFCmdrAction", _params));
			} forEach _tgtClusters;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 QRF actions from %2 garrisons to %3 clusters", [count _actions ARG count _srcGarrisons ARG count _tgtClusters]);

		_actions
	} ENDMETHOD;

	METHOD("generateReinforceActions") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		T_PRVAR(side);

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", []) select { 
			// Must be on our side and not involved in another action
			if((GETV(_x, "side") != _side) or { CALLM(_x, "isBusy", []) }) then {
				false
			} else {
				// Not involved in another reinforce action
				//private _action = CALLM(_x, "getAction", []);
				//if(!IS_NULL_OBJECT(_action) and { OBJECT_PARENT_CLASS_STR(_action) == "ReinforceCmdrAction" }) exitWith {false};

				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);

				// Must have at least a minimum strength of twice min efficiency
				//private _eff = GETV(_x, "efficiency");
				// !CALLM(_x, "isDepleted", []) and 
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			}
		};

		// Take tgt garrisons from future, so we take into account all in progress reinforcement actions.
		private _tgtGarrisons = CALLM(_worldFuture, "getAliveGarrisons", []) select { 
			// Must be on our side
			if(GETV(_x, "side") != _side) then {
				false
			} else {
				// Not involved in another reinforce action
				private _action = CALLM(_x, "getAction", []);
				if(!IS_NULL_OBJECT(_action) and { OBJECT_PARENT_CLASS_STR(_action) == "ReinforceCmdrAction" }) then {
					false
				} else {
					// Must be under desired efficiency by at least min reinforcement size
					// private _eff = GETV(_x, "efficiency");
					private _overDesiredEff = CALLM(_worldFuture, "getOverDesiredEff", [_x]);
					!EFF_GT(_overDesiredEff, EFF_MUL_SCALAR(EFF_MIN_EFF, -1))
				}
			}
		};

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			//private _srcPos = GETV(_x, "pos");
			{
				private _tgtId = GETV(_x, "id");
				//private _tgtPos = GETV(_x, "pos");
				if(_srcId != _tgtId 
					// and {_srcPos distance _tgtPos < REINF_MAX_DIST}
					) then {
					private _params = [_srcId, _tgtId];
					_actions pushBack (NEW("ReinforceCmdrAction", _params));
				};
			} forEach _tgtGarrisons;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 Reinforce actions from %2 garrisons to %3 garrisons", [count _actions ARG count _srcGarrisons ARG count _tgtGarrisons]);

		_actions
	} ENDMETHOD;

	METHOD("generateRoadblockActions") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];

		private _garrisons = GETV(_world, "garrisons");

		T_PRVAR(side);
		private _actions = [];

		// TODO: generate roadblock actions

		_actions
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_STRING("_world")];

		//T_PRVAR(world);
		T_PRVAR(activeActions);

		OOP_DEBUG_MSG("[c %1 w %2] - - - - - U P D A T I N G - - - - -   on %3 active actions", [_thisObject ARG _world ARG count _activeActions]);

		// Update actions in real world
		{ 
			OOP_DEBUG_MSG("[c %1 w %2] Updating action %3", [_thisObject ARG _world ARG _x]);
			CALLM(_x, "update", [_world]);
		} forEach _activeActions;

		// Remove complete actions
		{ 
			OOP_DEBUG_MSG("[c %1 w %2] Completed action %3, removing", [_thisObject ARG _world ARG _x]);
			_activeActions deleteAt (_activeActions find _x);
			UNREF(_x);
		} forEach (_activeActions select { CALLM(_x, "isComplete", []) });

		OOP_DEBUG_MSG("[c %1 w %2] - - - - - U P D A T I N G   D O N E - - - - -", [_thisObject ARG _world]);
	} ENDMETHOD;

	STATIC_METHOD("getActionGlobalPriority") {
		params [P_THISCLASS, P_OOP_OBJECT("_action")];
		private _class = GET_OBJECT_CLASS(_action);
		switch(GET_OBJECT_CLASS(_action)) do {
			case "QRFCmdrAction": { 100 };
			case "ReinforceCmdrAction": { 10 };
			default { 1 };
		}
	} ENDMETHOD;
	
	METHOD("plan") {
		params [P_THISOBJECT, P_STRING("_world")];

		OOP_DEBUG_MSG("[c %1 w %2] - - - - - P L A N N I N G - - - - -", [_thisObject ARG _world]);

		//T_PRVAR(world);
		T_PRVAR(activeActions);

		OOP_DEBUG_MSG("[c %1 w %2] Creating new simworlds from %2", [_thisObject ARG _world]);

		// Copy world to simworld, now and future
		private _simWorldNow = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_NOW]);
		private _simWorldFuture = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);

		OOP_DEBUG_MSG("[c %1 w %2] Applying %3 active actions to simworlds", [_thisObject ARG _world ARG count _activeActions]);

		PROFILE_SCOPE_START(ApplyActive);
		// Apply effects of active actions to the simworld
		{
			CALLM(_x, "applyToSim", [_simWorldNow]);
			CALLM(_x, "applyToSim", [_simWorldFuture]);
		} forEach _activeActions;
		PROFILE_SCOPE_END(ApplyActive, 0.1);

		OOP_DEBUG_MSG("[c %1 w %2] Generating new actions", [_thisObject ARG _world]);

		PROFILE_SCOPE_START(GenerateActions);
		// Generate possible new actions based on the simworld
		// (i.e. taking into account expected outcomes of currently active actions)
		private _newActions = 
			  T_CALLM("generateTakeOutpostActions", [_simWorldNow ARG _simWorldFuture])
			// TODO: general attack actions (QRF)
			+ T_CALLM("generateAttackActions", [_simWorldNow ARG _simWorldFuture])
			+ T_CALLM("generateReinforceActions", [_simWorldNow ARG _simWorldFuture]) 
			// TODO: roadblocks/outposts etc. Maybe this is up to garrison AI itself?
			//+ T_CALLM1("generateRoadblockActions", _simWorldNow)
			;
		PROFILE_SCOPE_END(GenerateActions, 0.1);

		OOP_DEBUG_MSG("[c %1 w %2] Generated %3 new actions, updating plan", [_thisObject ARG _world ARG count _newActions]);

		PROFILE_SCOPE_START(PlanActions);

		private _newActionsCount = 0;

		// Plan new actions
		while { count _newActions > 0 and _newActionsCount < 1 } do {
			OOP_DEBUG_MSG("[c %1 w %2]     Updating scoring for %3 remaining new actions", [_thisObject ARG _world ARG count _newActions]);

			CALLM(_simWorldNow, "resetScoringCache", []);
			CALLM(_simWorldFuture, "resetScoringCache", []);

			PROFILE_SCOPE_START(UpdateScores);
			// Update scores of potential actions against the simworld state
			{
				CALLM(_x, "updateScore", [_simWorldNow ARG _simWorldFuture]);
			} forEach _newActions;
			PROFILE_SCOPE_END(UpdateScores, 0.1);

			// Sort the actions by their scores
			private _scoresAndActions = _newActions apply { [CALLM(_x, "getFinalScore", []) * CALLSM("CmdrAI", "getActionGlobalPriority", [_x]), _x] };
			_scoresAndActions sort DESCENDING;

			// _newActions = [_newActions, [], { CALLM(_x, "getFinalScore", []) }, "DECEND"] call BIS_fnc_sortBy;

			// Get the best scoring action
			(_scoresAndActions select 0) params ["_bestActionScore", "_bestAction"];

			// private _bestActionScore = // CALLM(_bestAction, "getFinalScore", []);

			// Some sort of cut off needed here, probably needs tweaking, or should be strategy based?
			if(_bestActionScore <= 0.001) exitWith {
				OOP_DEBUG_MSG("[c %1 w %2]     Best new action %3 (score %4), score below threshold of 0.001, terminating planning", [_thisObject ARG _world ARG _bestAction ARG _bestActionScore]);
			};

			OOP_DEBUG_MSG("[c %1 w %2]     Selected new action %3 (score %4), applying it to the simworlds", [_thisObject ARG _world ARG _bestAction ARG _bestActionScore]);

			// Add the best action to our active actions list
			REF(_bestAction);
			_activeActions pushBack _bestAction;
			// Remove it from the possible actions list
			_newActions deleteAt (_newActions find _bestAction);

			PROFILE_SCOPE_START(ApplyNewActionToSim);

			// Apply the new action effects to simworld, so next loop scores update appropriately
			// (e.g. if we just accepted a new reinforce action, we should update the source and target garrison
			// models in the sim so that other reinforce actions will take it into account in their scoring.
			// Probably other reinforce actions with the same source or target would have lower scores now).
			CALLM(_bestAction, "applyToSim", [_simWorldNow]);
			CALLM(_bestAction, "applyToSim", [_simWorldFuture]);

			PROFILE_SCOPE_END(ApplyNewActionToSim, 0.1);

			_newActionsCount = _newActionsCount + 1;
		};
		PROFILE_SCOPE_END(PlanActions, 0.1);

		OOP_DEBUG_MSG("[c %1 w %2] Done updating plan, added %3 new actions, cleaning up %4 unused new actions", [_thisObject ARG _world ARG _newActionsCount ARG count _newActions]);

		// Delete any remaining discarded actions
		{
			DELETE(_x);
		} forEach _newActions;

		DELETE(_simWorldNow);
		DELETE(_simWorldFuture);

		OOP_DEBUG_MSG("[c %1 w %2] - - - - - P L A N N I N G   D O N E - - - - -", [_thisObject ARG _world]);
	} ENDMETHOD;
	
	// METHOD("clustersSplit") {
	// 	params [P_THISOBJECT, P_ARRAY("origCluster"), P_ARRAY("newClusters")];
		
	// } ENDMETHOD;
	
ENDCLASS;
