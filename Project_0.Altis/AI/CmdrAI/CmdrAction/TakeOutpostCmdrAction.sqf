#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#include "..\OOP_Light\OOP_Light.h"

#include "Constants.h"

// TODO: refactor to a proper state machine of some kind?
// 
CLASS("TakeOutpostAction", "Action")
	VARIABLE("ourGarrId");
	VARIABLE("targetOutpostId");
	VARIABLE("detachedGarrId");
	VARIABLE("stage");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_ourGarrId"), P_NUMBER("_targetOutpostId")];
		T_SETV("ourGarrId", _ourGarrId);
		T_SETV("targetOutpostId", _targetOutpostId);
		T_SETV("detachedGarrId", -1);
		T_SETV("stage", "new");
	} ENDMETHOD;

	METHOD("getLabel") {
		params [P_THISOBJECT];
		T_PRVAR(targetOutpostId);
		T_PRVAR(stage);
		format ["take o%1 - %2", _targetOutpostId, _stage]
	} ENDMETHOD;

	METHOD("updateScore") {
		params [P_THISOBJECT, P_STRING("_state")];
		T_PRVAR(ourGarrId);
		T_PRVAR(targetOutpostId);

		private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
		private _targetOutpost = CALLM1(_state, "getOutpostById", _targetOutpostId);
		private _targetOutpostPos = CALLM0(_targetOutpost, "getPos");

		//private _targetGarr = CALLM1(_state, "getAttachedGarrison", _targetOutpost);

		// No particular priority here, could be weighted towards empty outposts?
		
		private _scorePriority = 1;

		//CALLM0(_targetGarr, "getStrength") * 0.1;

		private _availableComp = T_CALLM1("getDetachmentComp", _state);

		// // Resource is how much our garrison is *over* (required composition + required force), scaled by distance (further is lower)
		// //private _ourGarrOverComp = CALLM1(_state, "getOverDesiredComp", _ourGarr);
		// // Enemy garrison composition
		// private _garrSide = CALLM0(_ourGarr, "getSide");
		// // private _targetOutpostDesiredComp = CALLM2(_state, "getDesiredComp", _targetOutpostPos, _garrSide);

		// // What is the composition dictated by the target outpost?
		// private _targetComp = if(_targetGarr isEqualType "") then { 
		// 	// If it is occupied we want 1.5 times the occupying force at least to take it
		// 	CALLM0(_targetGarr, "getComp") apply { _x * 1.5 }
		// } else { 
		// 	// If it is unoccupied we want 0.5 times the desired force at least to take it
		// 	CALLM2(_state, "getDesiredComp", _targetOutpostPos, _garrSide) apply { _x * 0.5 }
		// };

		// // _targetComp = [
		// // 	(_targetComp#0 * 1.5) max _targetOutpostDesiredComp#0,
		// // 	(_targetComp#1 * 1.5) max _targetOutpostDesiredComp#1
		// // ];
		// private _ourComp = CALLM0(_ourGarr, "getComp");

		// // How much over desired comp our garrison is
		// // Make sure to leave some forces behind
		// // TODO:
		// //   Work out better how much force we need to leave behind.
		// //   Problems with working this out as we there is conflict between desired comp and 
		// //   detachment comp: if desired comp is set to include enough forces for a detachment
		// //   then how do we determine what we can leave behind?
		// //     Perhaps we have defensiveComp and offensiveComp?
		// private _availableComp = [
		// 	0 max floor (_ourComp#0 - MIN_COMP#0 - _desiredComp#0),
		// 	0 max floor (_ourComp#1 - MIN_COMP#1 - _desiredComp#1)
		// ];

		// TODO: refactor out compositions and strength calculations to a utility class
		// Base resource score is based on how much excess resource our garrison has.
		private _scoreResource = 0 max (
			// units
			_availableComp#0 * UNIT_STRENGTH +
			// vehicles
			_availableComp#1 * VEHICLE_STRENGTH);

		// OOP_INFO_4("_desiredComp = %1, _ourComp = %2, _availableComp = %3, _scoreResource = %4",
		// 	_desiredComp, _ourComp, _availableComp, _scoreResource);

		private _ourGarrPos = CALLM0(_ourGarr, "getPos");

		private _distCoeff = CALLSM2("Action", "calcDistanceFalloff", _ourGarrPos, _targetOutpostPos);

		// Scale base score by distance coefficient
		_scoreResource = _scoreResource * _distCoeff;

		T_SETV("scorePriority", _scorePriority);
		T_SETV("scoreResource", _scoreResource);
	} ENDMETHOD;

	METHOD("getDesiredDetatchmentComp") {
		params [P_THISOBJECT, P_STRING("_state")];
		T_PRVAR(targetOutpostId);
		private _targetOutpost = CALLM1(_state, "getOutpostById", _targetOutpostId);
		private _targetGarr = CALLM1(_state, "getAttachedGarrison", _targetOutpost);

		// What is the composition dictated by the target outpost?
		private _targetComp = if(_targetGarr isEqualType "") then { 
			// If it is occupied we want 1.5 times the occupying force at least to take it
			CALLM0(_targetGarr, "getComp") apply { _x * 1.5 }
		} else { 
			T_PRVAR(ourGarrId);
			// If it is unoccupied we want to send 1/2 our comp
			private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
			private _ourComp = CALLM0(_ourGarr, "getComp");
			[
				ceil (_ourComp#0 * 0.5),
				ceil (_ourComp#1 * 0.5)
			]
		};

		[
			MIN_COMP#0 max _targetComp#0,
			MIN_COMP#1 max _targetComp#1
		]
	} ENDMETHOD;
	
	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	METHOD("getDetachmentComp") {
		params [P_THISOBJECT, P_STRING("_state")];
		T_PRVAR(ourGarrId);
		//T_PRVAR(targetOutpostId);

		private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
		private _ourComp = CALLM0(_ourGarr, "getComp");
		private _desiredComp = T_CALLM1("getDesiredDetatchmentComp", _state);

		// TODO: many things should be done to improve this (and associated scoring).
		// Just some:
		//   -- Make sure we take an appropriate combination of units/vehicles
		//   -- If attacking an entrenched position scale appropriately (at least 3 times defenders)
		//   -- If area or route is dangerous increase force
		//OOP_INFO_2("_ourComp = %1, _desiredComp = %2", _ourComp, _desiredComp);

		// detach comp is clamp(0, ourComp - min comp, _targetComp)
		private _availableComp = [
			0 max round ((_ourComp#0 - MIN_COMP#0) min _desiredComp#0),
			0 max round ((_ourComp#1 - MIN_COMP#1) min _desiredComp#1)
		];
		
		// If we can provide minimum viable comp then return nothing
		if(_availableComp#0 < MIN_COMP#0 or _availableComp#1 < MIN_COMP#1) exitWith { [0,0] };

		_availableComp
	} ENDMETHOD;

	METHOD("applyToSim") {
		params [P_THISOBJECT, P_STRING("_state")];
		T_PRVAR(complete);
		if(_complete) exitWith {
			OOP_WARNING_0("applyToSim after action is complete");
		};
		T_PRVAR(ourGarrId);
		T_PRVAR(targetOutpostId);
		T_PRVAR(stage);

		private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
		private _ourSide = CALLM0(_ourGarr, "getSide");
		private _targetOutpost = CALLM1(_state, "getOutpostById", _targetOutpostId);
		//private _targetOutpostPos = CALLM0(_targetOutpost, "getPos");
		private _targetGarr = CALLM1(_state, "getAttachedGarrison", _targetOutpost);

		// Regardless of stage, we expect any target garrison to be killed
		if(_targetGarr isEqualType "" and {CALLM0(_targetGarr, "getSide") != _ourSide}) then {
			CALLM2(_targetGarr, "setComp", 0, 0);
		};

		// If we didn't start the action yet then we need to subtract from srcGarr
		switch(_stage) do {
			case "new": {
				private _detachedComp = T_CALLM1("getDetachmentComp", _state);
				if(_detachedComp#0 > 0 and _detachedComp#1 > 0) then {
					private _detachedGarr = CALLM1(_ourGarr, "splitGarrison", _detachedComp);
					CALLM1(_state, "addGarrison", _detachedGarr);
					CALLM2(_state, "attachGarrison", _detachedGarr, _targetOutpost);
				};
			};
			case "moving": {
				T_PRVAR(detachedGarrId);
				private _detachedGarr = CALLM1(_state, "getGarrisonById", _detachedGarrId);
				CALLM2(_state, "attachGarrison", _detachedGarr, _targetOutpost);
			};
		};
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_STRING("_state")];

		T_PRVAR(complete);
		if(_complete) exitWith {
			OOP_WARNING_0("applyToSim after action is complete");
		};

		T_PRVAR(ourGarrId);
		T_PRVAR(targetOutpostId);
		T_PRVAR(stage);

		private _ourGarr = CALLM1(_state, "getGarrisonById", _ourGarrId);
		private _ourSide = CALLM0(_ourGarr, "getSide");
		private _targetOutpost = CALLM1(_state, "getOutpostById", _targetOutpostId);

		T_PRVAR(stage);

		// Stages:
		// new - split off detachment from our garrison and send them to target outpost
		// moving - if detachment is at the target outpost then occupy it
		switch(_stage) do {
			case "new": {
				OOP_INFO_2("TakeOutpostAction g%1->o%2 starting", _ourGarrId, _targetOutpostId);

				if(CALLM0(_ourGarr, "isDead")) exitWith {
					T_SETV("complete", true);
					OOP_INFO_2("TakeOutpostAction g%1->o%2 failed: g%1 died before detachment was sent", _ourGarrId, _targetOutpostId);
				};

				// Create the detachment
				private _detachedComp = T_CALLM1("getDetachmentComp", _state);
				if(_detachedComp#0 == 0 and _detachedComp#1 == 0) exitWith {
					T_SETV("complete", true);
					// Shouldn't get here really..
					OOP_INFO_2("TakeOutpostAction g%1->o%2 failed: g%1 couldn't provide required detachment", _ourGarrId, _targetOutpostId);
				};
				private _detachedGarr = CALLM1(_ourGarr, "splitGarrison", _detachedComp);
				_detachedGarrId = CALLM1(_state, "addGarrison", _detachedGarr);
				T_SETV("detachedGarrId", _detachedGarrId);

				// Assign action to the split garrison.
				CALLM1(_detachedGarr, "setAction", _thisObject);

				// Give the move order to the detachment
				OOP_INFO_3("TakeOutpostAction g%1->g%3->o%2 moving g%3 to target", _ourGarrId, _targetOutpostId, _detachedGarrId);
				private _targetOutpostPos = CALLM0(_targetOutpost, "getPos");
				private _args = [format["g%1 taking o%2", _detachedGarrId, _targetOutpostId], _detachedGarrId, _targetOutpostPos];
				private _moveOrder = NEW("MoveOrder", _args);
				CALLM1(_detachedGarr, "giveOrder", _moveOrder);
				// Next stage
				T_SETV("stage", "moving");
			};

			case "moving": {
				T_PRVAR(detachedGarrId);
				private _detachedGarr = CALLM1(_state, "getGarrisonById", _detachedGarrId);
				if(CALLM0(_detachedGarr, "isDead")) exitWith {
					CALLM0(_detachedGarr, "clearAction");
					T_SETV("complete", true);
					OOP_INFO_3("TakeOutpostAction g%1->g%3->o%2 failed: detachment g%3 died", _ourGarrId, _targetOutpostId, _detachedGarrId);
				};

				if(CALLM0(_detachedGarr, "isOrderComplete")) then {
					private _targetGarr = CALLM1(_state, "getAttachedGarrison", _targetOutpost);

					if(!(_targetGarr isEqualType "") or {CALLM0(_targetGarr, "getSide") == _ourSide} or {CALLM0(_targetGarr, "isDead")}) then {
						// Occupying force is dead, and we arrived at target, so occupy it
						CALLM2(_state, "attachGarrison", _detachedGarr, _targetOutpost);
						CALLM0(_detachedGarr, "clearAction");
						T_SETV("complete", true);
						OOP_INFO_3("TakeOutpostAction g%1->g%3->o%2 completed: g%3 took outpost", _ourGarrId, _targetOutpostId, _detachedGarrId);
					};
				};
			};
		};
	} ENDMETHOD;
ENDCLASS;
