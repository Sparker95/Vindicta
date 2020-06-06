#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMove
Action for infantry movement.
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitInfantryMove
CLASS("ActionUnitInfantryMove", "ActionUnit")

	VARIABLE("targetPos");		// Last known position where to move
	VARIABLE("moveRadius");
	VARIABLE("teleport"); // If true, unit will be teleported if ETA is exceeded
	VARIABLE("distRemaining"); // Remaining distance to go

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_MOVE_TARGET, [objNull, NULL_OBJECT, []] ] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]], [TAG_TELEPORT, [false]], [TAG_BUILDING_POS_ID, [0]]  ]	// Optional parameters
		]
	ENDMETHOD;

	// ------------ N E W ------------
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _ai = T_GETV("ai");

		private _teleport = CALLSM3("Action", "getParameterValue", _parameters, TAG_TELEPORT, false);
		T_SETV("teleport", _teleport);

		private _moveTarget = GET_PARAMETER_VALUE(_parameters, TAG_MOVE_TARGET);
		private _buildingPosID = GET_PARAMETER_VALUE_DEFAULT(_parameters, TAG_BUILDING_POS_ID, -1);
		if (_buildingPosID == -1) then {
			CALLM1(_ai, "setMoveTarget", _moveTarget);
		} else {
			CALLM2(_ai, "setMoveTargetBuilding", _moveTarget, _buildingPosID);

			// Mark the position occupied
			private _occupied = _moveTarget getVariable ["vin_occupied_positions", []];
			_occupied pushBackUnique _buildingPosID;
			_moveTarget setVariable ["vin_occupied_positions", _occupied];
		};

		FIX_LINE_NUMBERS()
		// Resolve movement radius, if it wasn't provided
		private _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS);
		if (isNil "_radius") then {
			if ((_moveTarget isEqualType objNull) || (_moveTarget isEqualType NULL_OBJECT)) then {
				if (_buildingPosID == -1) then {
					// -- Moving to object or unit, radius not provided
					pr _objHandle = _moveTarget;

					// If it's unit, resolve object handle
					if (_moveTarget isEqualType NULL_OBJECT) then {
						_objHandle = CALLM0(_moveTarget, "getObjectHandle");
					};

					// Set tolerance from bounding box size
					pr _a = (boundingBoxReal _objHandle) select 0;
					_a set [2, 0]; // Erase the vertical component
					_radius = (vectorMagnitude _a) + 1.5;
				} else {
					// -- Moving to building pos, radius not provided
					_radius = 1.5;
				};
			} else {
				// -- Moving to position, radius not provided
				_radius = 2;
			};
		};
		CALLM1(_ai, "setMoveTargetRadius", _radius);
		T_SETV("moveRadius", _radius);
		FIX_LINE_NUMBERS()
		

		// Update world state property related to movement
		// Because we will be using it to check if we have arrived
		CALLM0(_ai, "updatePositionWSP");

		pr _posTarget = CALLM0(_ai, "getMoveTargetPosAGL");
		T_SETV("targetPos", _posTarget);

		T_SETV("distRemaining", 9000);
	ENDMETHOD;

	// Returns bool: true if target pos has moved beyond moveRadius
	METHOD(updateTargetPos)
		params [P_THISOBJECT];
		pr _targetPos = T_GETV("targetPos");
		pr _ai = T_GETV("ai");
		pr _actualTargetPos = CALLM0(_ai, "getMoveTargetPosAGL");
		if ((_actualTargetPos distance _targetPos) > T_GETV("moveRadius")) then {
			T_SETV("targetPos", _actualTargetPos);
			true;
		} else {
			false;
		};
	ENDMETHOD;

	FIX_LINE_NUMBERS()
	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		// We are not in formation any more
		// Reset world state property
		pr _ws = GETV(T_GETV("ai"), "worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false);

		// Handle AI just spawned state
		private _AI = T_GETV("AI");
		if (_instant) then {
			// Teleport the unit to where it needs to be
			private _hO = T_GETV("hO");
			pr _ai = T_GETV("ai");
			CALLM0(_ai, "instantMoveToTarget");
			doStop _hO;

			// Set state
			pr _ws = GETV(_ai, "worldState");
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, true);
			T_SETV("state", ACTION_STATE_COMPLETED);

			// Return completed state
			ACTION_STATE_COMPLETED
		} else {
			// Order to move
			private _ai = T_GETV("ai");
			CALLM0(_ai, "orderMoveToTarget");

			// Set state
			T_SETV("state", ACTION_STATE_ACTIVE);

			// Return ACTIVE state
			ACTION_STATE_ACTIVE
		};
	ENDMETHOD;
	FIX_LINE_NUMBERS()
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		private _state = T_CALLM0("activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			// Check if we have arrived
			private _hO = T_GETV("hO");
			private _pos = T_GETV("targetPos");

			private _dist = _hO distance _pos;
			private _ai = T_GETV("ai");
			private _ws = GETV(_ai, "worldState");
			private _atTargetPos = WS_GET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS);
			T_SETV("distRemaining", _dist);

			// Check if target pos has changed
			pr _targetPosChanged = T_CALLM0("updateTargetPos");
			pr _targetPos = T_GETV("targetPos");

			// Bail if target is invalid (wtf?)
			if (_targetPos isEqualTo [0,0,0]) exitWith {
				// Target is invalid!
				T_SETV("state", ACTION_STATE_FAILED);
				_state = ACTION_STATE_FAILED;
				ACTION_STATE_FAILED;
			};

			// Order to move to new pos if pos has changed much
			if (_targetPosChanged) then {
				T_CALLM0("activate"); // Reactivate
				_state = ACTION_STATE_ACTIVE;
			} else {
				// We have arrived
				if (_atTargetPos) then {
					// If duration is < 0 then we never complete this action
					CALLM0(_ai, "stopMoveToTarget"); // Does doStop
					_state = ACTION_STATE_COMPLETED;
				} else {
					// Check stuck timer
					pr _stuckDuration = GETV(_ai, "stuckDuration");
					if (_stuckDuration > 15) then {
						pr _actualTargetPos = CALLM0(_ai, "getMoveTargetPosAGL");
						pr _currentPos = getPos _hO;
						
						OOP_WARNING_2("Unit stuck for longer than 15 seconds. Position: %1, destination: %2", _currentPos, _actualTargetPos);
						OOP_WARNING_0("Moving unit by 1 meter");

						// Try to move unit towards its target
						pr _vectorDiff = _actualTargetPos vectorDiff _currentPos;
						pr _distRemaining = _hO distance _actualTargetPos;
						pr _pushDistance = _distRemaining min 1.0;	// If we are closer than one meter, don't move by one meter
						// todo detection if in building or destination is building
						pr _vectorDiffNorm = vectorNormalized _vectorDiff;
						_vectorDiffNorm set [2, 0.1]; 				// Discard vertical difference
						pr _vectorPush = _vectorDiffNorm vectorMultiply _pushDistance;
						_hO setPos (_currentPos vectorAdd _vectorPush);

						// Order move to target again
						CALLM0(_ai, "orderMoveToTarget");
					};
				};
			};
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];

		pr _ai = T_GETV("ai");
		CALLM0(_ai, "stopMoveToTarget"); // Does doStop

		// Mark the building position not occupied
		pr _buildingPosID = GETV(_ai, "moveBuildingPosID");
		if (_buildingPosID != -1) then {
			pr _moveTarget = GETV(_ai, "moveTarget");
			private _occupied = _moveTarget getVariable ["vin_occupied_positions", []];
			_occupied deleteAt (_occupied find _buildingPosID);
		};
	ENDMETHOD;

	public override METHOD(getDebugUIVariableNames)
			[	"targetPos",
				"moveRadius",
				"teleport",
				"distRemaining"]
	ENDMETHOD;

ENDCLASS;