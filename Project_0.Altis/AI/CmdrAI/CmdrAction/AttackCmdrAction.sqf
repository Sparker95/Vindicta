#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#include "..\OOP_Light\OOP_Light.h"

#include "Constants.h"

// TODO: refactor to a proper state machine of some kind?
// 
CLASS("AttackAction", "Action")
	VARIABLE("ourGarrId");
	VARIABLE("theirGarrId");
	VARIABLE("splitGarrId");
	VARIABLE("targetOutpostId");
	VARIABLE("stage");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_ourGarrId"), P_NUMBER("_theirGarrId")];
		OOP_INFO_2("New AttackAction created %1->%2", _ourGarrId, _theirGarrId);
		T_SETV("ourGarrId", _ourGarrId);
		T_SETV("theirGarrId", _theirGarrId);
		T_SETV("splitGarrId", -1);
		T_SETV("stage", "new");
	} ENDMETHOD;

	METHOD("updateScore") {
		params [P_THISOBJECT, P_STRING("_state")];
		T_PRVAR(ourGarrId);
		T_PRVAR(theirGarrId);

		private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
		private _theirGarr = CALLM1(_state, "getGarrisonById", _theirGarrId);

		// Threat is just their strength scaled somewhat
		// TODO: is scaling here necessary? should we apply a non-linear function?
		private _scorePriority = CALLM0(_theirGarr, "getStrength") * 0.1;

		// Resource is how much our garrison is *over* (required composition + required force), scaled by distance (further is lower)
		private _ourGarrOverComp = CALLM1(_state, "getOverDesiredComp", _ourGarr);
		// Enemy garrison composition
		private _theirComp = CALLM0(_theirGarr, "getComp");
		// How much over (required composition + required force) our garrison is
		private _ourGarrOverForceComp = [
			_ourGarrOverComp#0 - _theirComp#0,
			_ourGarrOverComp#1 - _theirComp#1
		];

		// TODO: refactor out compositions and strength calculations to a utility class
		// Base resource score is based on over forcein fa
		private _scoreResource =
			// units
			(0 max _ourGarrOverForceComp#0) * UNIT_STRENGTH +
			// vehicles
			(0 max _ourGarrOverForceComp#1) * VEHICLE_STRENGTH;

		private _ourGarrPos = CALLM0(_ourGarr, "getPos");
		private _theirGarrPos = CALLM0(_theirGarr, "getPos");

		private _distCoeff = CALLSM2("ReinforceAction", "calcDistanceFalloff", _ourGarrPos, _theirGarrPos);

		// Scale base score by distance coefficient
		_scoreResource = _scoreResource * _distCoeff;

		T_SETV("scorePriority", _scorePriority);
		T_SETV("scoreResource", _scoreResource);
	} ENDMETHOD;

	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	METHOD("getAttackComp") {
		params [P_THISOBJECT, P_STRING("_state")];
		T_PRVAR(ourGarrId);
		T_PRVAR(theirGarrId);

		private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
		private _theirGarr = CALLM1(_state, "getGarrisonById", _theirGarrId);

		// Enemy garrison composition
		private _ourComp = CALLM0(_ourGarr, "getComp");
		// Enemy garrison composition
		private _theirComp = CALLM0(_theirGarr, "getComp");

		// TODO: many things should be done to improve this (and associated scoring).
		// Just some:
		//   -- Make sure we take an appropriate combination of units/vehicles
		//   -- If attacking an entrenched position scale appropriately (at least 3 times defenders)
		//   -- If area or route is dangerous increase force

		// Attack comp is min(ourComp, theirComp * 1.5)
		[
			_ourComp#0 min floor (_theirComp#0 * 1.5),
			_ourComp#1 min floor (_theirComp#1 * 1.5)
		]
	} ENDMETHOD;

	METHOD("applyToSim") {
		params [P_THISOBJECT, P_STRING("_state")];
		T_PRVAR(ourGarrId);
		T_PRVAR(theirGarrId);
		private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
		private _theirGarr = CALLM1(_state, "getGarrisonById", _theirGarrId);

		T_PRVAR(stage);
		
		// If we didn't start the action yet then we need to subtract from srcGarr
		switch(_stage) do {
			case "new": {
				private _splitComp = T_CALLM1("getAttackComp", _state);
				private _negSentComp = _splitComp apply { _x * -1 };
				// TODO: better simulation!
				CALLM1(_theirGarr, "modComp", _negSentComp);
				// while { !CALLM0(_splitGarr, "isDead") and !CALLM0(_theirGarr, "isDead") } do {
				// 	CALLM1(_splitGarr, "fightUpdate", _theirGarr);
				// };
			};
			case "moving": {
				T_PRVAR(splitGarrId);
				private _splitGarr = CALLM1(_state, "getGarrisonById", _splitGarrId);
				private _splitComp = CALLM0(_splitGarr, "getComp");
				private _negSentComp = _splitComp apply { _x * -1 };
				// TODO: better simulation!
				CALLM1(_theirGarr, "modComp", _negSentComp);
			};
			case "take": {
				T_PRVAR(splitGarrId);
				T_PRVAR(targetOutpostId);
				private _splitGarr = CALLM1(_state, "getGarrisonById", _splitGarrId);
				private _outpost = CALLM1(_state, "getOutpostById", _targetOutpostId);
				CALLM2(_state, "attachGarrison", _splitGarr, _outpost);
			};
		};

	} ENDMETHOD;


	METHOD("update") {
		params [P_THISOBJECT, P_STRING("_state")];
		T_PRVAR(ourGarrId);
		T_PRVAR(theirGarrId);
		T_PRVAR(splitGarrId);

		private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
		private _theirGarr = CALLM1(_state, "getGarrisonById", _theirGarrId);

		// TODO: more interesting behaviour.
		// State machine/steps:
		//   Send to last known location.
		//   Once there investigate.
		//   Respond to updated position of target, or abort and come home if we can't find them.

		// If the enemy are dead then this action is complete.
		// TODO: use actual intel to determine if/when target is dead.

		T_PRVAR(stage);

		switch(_stage) do {
			case "new": {
				OOP_INFO_2("AttackAction %1->%2 starting", _ourGarrId, _theirGarrId);

				if(CALLM0(_ourGarr, "isDead")) exitWith {
					T_SETV("complete", true);
					OOP_INFO_2("AttackAction %1->%2 completed: %1 died", _ourGarrId, _theirGarrId);
				};

				// We didn't split the source garrison yet, so do it now.
				private _splitComp = T_CALLM1("getAttackComp", _state);
				//private _splitComp = T_CALLM1("getReinfComp", _state);
				private _splitGarr = CALLM1(_ourGarr, "splitGarrison", _splitComp);
				_splitGarrId = CALLM1(_state, "addGarrison", _splitGarr);
				T_SETV("splitGarrId", _splitGarrId);

				// Assign action to the split garrison.
				SETV_REF(_splitGarr, "currAction", _thisObject);

				// Next stage
				T_SETV("stage", "moving");

				OOP_INFO_4("AttackAction %1->%2 sending %3 %4", _ourGarrId, _theirGarrId, _splitGarrId, _splitComp);
			};

			case "moving": {
				private _splitGarr = CALLM1(_state, "getGarrisonById", _splitGarrId);
				private _splitPos = CALLM0(_splitGarr, "getPos");
				if(CALLM0(_splitGarr, "isDead")) exitWith {
					T_SETV("complete", true);
					OOP_INFO_3("AttackAction %1->%3->%2 completed: %3 died", _ourGarrId, _theirGarrId, _splitGarrId);
				};

				if(CALLM0(_theirGarr, "isDead")) then {
					// If enemy is dead we will move to the nearest non enemy outpost (probably the one we just vacated by killing the enemy).
					private _ourSide = CALLM0(_splitGarr, "getSide");
					private _outposts = CALLM2(_state, "getNearestOutposts", _splitPos, 10000) 
						select {
							_x params ["_dist", "_outpost"];
							(_dist < 250) or (CALLM0(_outpost, "getSide") == _ourSide)
						};

					if(count _outposts > 0) then {
						private _outpost = _outposts#0#1;
						private _outpostId = GETV(_outpost, "id");
						T_SETV("targetOutpostId", _outpostId);
						// Next stage
						T_SETV("stage", "take");
						OOP_INFO_3("AttackAction %1->%3->%2 is taking outpost: %2 died", _ourGarrId, _theirGarrId, _splitGarrId);
						private _outpostPos = CALLM0(_outpost, "getPos");
						// Give move order to the target outpost.
						private _args = [ format["%1 moving to outpost %2", _splitGarrId, _outpostId], _splitGarrId, _outpostPos];
						private _moveOrder = NEW("MoveOrder", _args);
						CALLM1(_splitGarr, "giveOrder", _moveOrder);
					} else {
						// No outpost? I guess this is our life now.
						OOP_INFO_3("AttackAction %1->%3->%2 is done: no outpost to take", _ourGarrId, _theirGarrId, _splitGarrId);
						T_SETV("complete", true);
					};
				} else {
					if(CALLM0(_splitGarr, "isOrderComplete")) then {
						OOP_INFO_3("AttackAction %1->%3->%2 move order completed", _ourGarrId, _theirGarrId, _splitGarrId);
						
						private _targetPos = CALLM0(_theirGarr, "getPos");
						private _dist = _splitPos distance _targetPos;
						OOP_INFO_4("AttackAction %1->%3->%2 dist: %4", _ourGarrId, _theirGarrId, _splitGarrId, _dist);
						// If we reached the target then merge the garrisons
						if(_dist < 100) then {
							OOP_INFO_3("AttackAction %1->%3->%2 merging %3 to target", _ourGarrId, _theirGarrId, _splitGarrId);
							CALLM1(_theirGarr, "mergeGarrison", _splitGarr);
							T_SETV("complete", true);
						} else {
							OOP_INFO_3("AttackAction %1->%3->%2 moving %3 to target", _ourGarrId, _theirGarrId, _splitGarrId);

							// Give another move order as we didn't reach target yet.
							private _args = [ format["%1 attacking %2", _splitGarrId, _theirGarrId], _splitGarrId, _targetPos];
							private _moveOrder = NEW("MoveOrder", _args);
							CALLM1(_splitGarr, "giveOrder", _moveOrder);
						};
					};
				};
			};

			case "take": {
				T_PRVAR(targetOutpostId);

				private _splitGarr = CALLM1(_state, "getGarrisonById", _splitGarrId);
				if(CALLM0(_splitGarr, "isDead")) exitWith {
					T_SETV("complete", true);
					OOP_INFO_3("AttackAction %1->%3->%2 completed: %3 died", _ourGarrId, _theirGarrId, _splitGarrId);
				};
				if(CALLM0(_splitGarr, "isOrderComplete")) then {
					//private _ourSide = CALLM0(_splitGarr, "getSide");
					private _outpost = CALLM1(_state, "getOutpostById", _targetOutpostId);
					CALLM2(_state, "attachGarrison", _splitGarr, _outpost);

					// CALLM1(_outpost, "setSide", _ourSide);
					// private _outpostPos = CALLM0(_outpost, "getPos");
					// // Get nearby garrisons who are not doing anything, we will join the closest one
					// private _nearGarrisons = CALLM3(_state, "getNearestGarrisons", _ourSide, _outpostPos, 50) 
					// 	select { CALLM0(_x, "isOrderComplete") };
					// if (count _nearGarrisons > 0) then {
					// 	private _nearestGarrison = _nearGarrisons#1;
					// 	OOP_INFO_4("AttackAction %1->%3->%2: merged to %4", _ourGarrId, _theirGarrId, _splitGarrId, _nearestGarrison);
					// 	CALLM1(_nearestGarrison, "mergeGarrison", _splitGarr);
					// };

					T_SETV("complete", true);
					OOP_INFO_3("AttackAction %1->%3->%2 completed: %3 arrived at outpost", _ourGarrId, _theirGarrId, _splitGarrId);
				};

				// private _splitPos = CALLM0(_splitGarr, "getPos");
				// private _outpost = CALLM1(_state, "getOutpostById", _outpostId);
				// private _outpostPos = CALLM0(_outpost, "getPos");


			};
		};

		// // For now just add move orders to target until we catch them, they die or we die.
		// if(CALLM0(_ourGarr, "isOrderComplete")) then {
		// 	OOP_INFO_2("AttackAction %1->%2 updating move order of %1", _ourGarrId, _theirGarrId);

		// 	// Give our garrison move order to target garrison position
		// 	SETV(_ourGarr, "currAction", _thisObject);

		// 	private _targetPos = CALLM0(_theirGarr, "getPos");
		// 	private _args = [format ["%1 attacking %2", _ourGarrId, _targetPos], _ourGarrId, _targetPos];
		// 	private _moveOrder = NEW("MoveOrder", _args);
		// 	CALLM1(_ourGarr, "giveOrder", _moveOrder);
		// };

	} ENDMETHOD;
ENDCLASS;
