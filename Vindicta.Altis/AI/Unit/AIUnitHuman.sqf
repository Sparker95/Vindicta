#include "common.hpp"

/*
Base class for human AI. Has vehicle assignment functionality.
*/

#define pr private

#define MRK_GOAL	"_goal"
#define MRK_ARROW	"_arrow"

#define OOP_CLASS_NAME AIUnitInfantry
CLASS("AIUnitHuman", "AIUnit")

	// Vehicle assignment variables
	VARIABLE("assignedVehicle");
	VARIABLE("assignedVehicleRole");
	VARIABLE("assignedCargoIndex");
	VARIABLE("assignedTurretPath");

	// Position assignment variables
	VARIABLE("moveTarget");
	VARIABLE("moveBuildingPosID");
	VARIABLE("moveRadius");	// Radius for movement completion

	#ifdef DEBUG_GOAL_MARKERS
	VARIABLE("markersEnabled");
	#endif

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent")];

		// Make sure arguments are of proper classes
		// Can be Civilian or Unit
		//ASSERT_OBJECT_CLASS(_agent, "Unit");

		// Make sure that the needed MessageLoop exists
		ASSERT_GLOBAL_OBJECT(gMessageLoopUnscheduled);

		// Create world state
		pr _ws = [WSP_UNIT_HUMAN_COUNT] call ws_new; // todo WorldState size must depend on the agent
		for "_i" from 0 to (WSP_UNIT_HUMAN_COUNT-1) do { // Init all WSPs to false
			WS_SET(_ws, _i, false);
		};
		T_SETV("worldState", _ws);

		#ifdef DEBUG_GOAL_MARKERS
		T_SETV("markersEnabled", false);
		#endif

		// Init target pos variables
		pr _targetPos = [0,0,0]; // Something completely not here
		T_SETV("moveTarget", _targetPos);
		T_SETV("moveRadius", -1);
		T_SETV("moveBuildingPosID", -1);


		//T_SETV("worldState", _ws);
	ENDMETHOD;
	
	METHOD(delete)
		params [P_THISOBJECT];
		
		OOP_INFO_1("DELETE %1", _thisObject);
		
		// Unassign this unit from its assigned vehicle
		T_CALLM0("unassignVehicle");

		#ifdef DEBUG_GOAL_MARKERS
		T_CALLM0("_disableDebugMarkers");
		#endif

		T_CALLM0("removeFromProcessCategory");
	ENDMETHOD;

	METHOD(process)
		params [P_THISOBJECT, P_BOOL("_spawning")];

		#ifdef DEBUG_GOAL_MARKERS
		if(T_GETV("markersEnabled")) then {
			pr _unused = "";
		};	
		#endif

		// === Update world state properties
		T_CALLM0("updateVehicleWSP");
		T_CALLM0("updatePositionWSP");

		CALL_CLASS_METHOD("AI_GOAP", _thisObject, "process", [_spawning]);

		#ifdef DEBUG_GOAL_MARKERS
		T_CALLM0("_updateDebugMarkers");
		#endif
	ENDMETHOD;
	FIX_LINE_NUMBERS()


	/* override */ METHOD(onGoalChosen)
		params [P_THISOBJECT, P_ARRAY("_goalParameters")];

		pr _moveTarget = 0;
		pr _newParameters = [];

		// Check goal parameters
		// Some parameters need to be converted to other parameter tags
		{
			_x params ["_tag", "_value"];
			if (_tag in [	TAG_TARGET_REPAIR,
							TAG_TARGET_ARREST,
							//TAG_TARGET_SALUTE,		// no we can salute from anywhere
							TAG_TARGET_SCARE_AWAY,
							TAG_TARGET_AMBIENT_ANIM
							//TAG_TARGET_SHOOT_RANGE,	// no we don't walk straight to shooting range target to shoot it
							//TAG_TARGET_SHOOT_LEG		// no we don't need to walk to someone to shoot him
							]) then {
				_newParameters pushBack [TAG_TARGET_OBJECT, _value];
				_moveTarget = _value;
			};

			// If goal implies some interaction,
			// reset 'has interacted' flag
			// so that planner chooses the interaction action
			if (_tag in [
					TAG_TARGET_REPAIR,
					TAG_TARGET_ARREST,
					TAG_TARGET_SALUTE,
					TAG_TARGET_SCARE_AWAY,
					TAG_TARGET_AMBIENT_ANIM,
					TAG_TARGET_SHOOT_RANGE,
					TAG_TARGET_SHOOT_LEG
			]) then {
				T_CALLM1("setHasInteractedWSP", false);
			};
		} forEach _goalParameters;

		// Append ned parameters to goal parameters
		_goalParameters append _newParameters;

		// Set move target if we have got it from parameters
		if (!(_moveTarget isEqualTo 0)) then {
			T_CALLM1("setMoveTarget", _moveTarget);
			
			// Provide move radius from goal if it exists
			pr _moveRadius = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_MOVE_RADIUS, -1);
			if (_moveRadius == -1) then {
				T_CALLM1("setMoveRadius", 2);	// Action can override it anyway
			} else {
				T_CALLM1("setMoveRadius", _moveRadius);
			};
			
			T_CALLM0("updatePositionWSP");
		};

	ENDMETHOD;
	

	/* override */ METHOD(start)
		params [P_THISOBJECT];
		T_CALLM1("addToProcessCategory", "MiscLowPriority");
	ENDMETHOD

	METHOD(_enableDebugMarkers)
		params [P_THISOBJECT];

		if(T_GETV("markersEnabled")) exitWith {
			// already enabled
		};

		pr _agent = T_GETV("agent");

		// Position
		pr _pos = [0, 0, 0];

		pr _garr = CALLM0(_agent, "getGarrison");

		// Main marker
		pr _color = [CALLM0(_garr, "getSide"), true] call BIS_fnc_sideColor;
		pr _name = _thisObject + MRK_GOAL;
		pr _mrk = createmarker [_name, _pos];
		_mrk setMarkerType "mil_dot";
		_mrk setMarkerColor _color;
		_mrk setMarkerAlpha 0;
		_mrk setMarkerText "group...";
		// Arrow marker (todo)
		
		// Arrow marker
		pr _name = _thisObject + MRK_ARROW;
		pr _mrk = createMarker [_name, [0, 0, 0]];
		_mrk setMarkerShape "RECTANGLE";
		_mrk setMarkerBrush "SolidFull";
		_mrk setMarkerSize [10, 10];
		_mrk setMarkerColor _color;
		_mrk setMarkerAlpha 0;

		T_SETV("markersEnabled", true);
	ENDMETHOD;

	METHOD(_disableDebugMarkers)
		params [P_THISOBJECT];
		
		if(!T_GETV("markersEnabled")) exitWith {
			// already disabled
		};

		deleteMarker (_thisObject + MRK_GOAL);
		deleteMarker (_thisObject + MRK_ARROW);

		T_SETV("markersEnabled", false);
	ENDMETHOD;

	METHOD(_updateDebugMarkers)
		params [P_THISOBJECT];

		pr _unit = T_GETV("agent");
		pr _grp = CALLM0(_unit, "getGroup");
		pr _grpAI = CALLM0(_grp, "getAI");
		pr _enabled = GETV(_grpAI, "unitMarkersEnabled") && GETV(_grpAI, "markersEnabled");
		pr _wasEnabled = T_GETV("markersEnabled");
		if(!_wasEnabled && _enabled) then {
			T_CALLM0("_enableDebugMarkers");
		};
		if(!_enabled) exitWith {
			if(_wasEnabled) then {
				T_CALLM0("_disableDebugMarkers");
			};
		};

		// Set pos
		pr _hO = T_GETV("hO");
		if(isNull _hO) exitWith {
			// unit invalid
		};

		pr _pos = position _hO;
		(_thisObject + MRK_GOAL) setMarkerAlpha 0;
		(_thisObject + MRK_ARROW) setMarkerAlpha 0;

		// Update the markers
		pr _mrk = _thisObject + MRK_GOAL;
		// Set text
		pr _action = T_GETV("currentAction");
		if (_action != NULL_OBJECT) then {
			_action = CALLM0(_action, "getFrontSubaction");
		};
		pr _state = if (_action != NULL_OBJECT) then {
			format ["(%1)", gDebugActionStateText select GETV(_action, "state")]
		} else {
			""
		};
		pr _text = format ["%1\%2\%3\%4%5", _unit, _thisObject, T_GETV("currentGoal"), _action, _state];
		_mrk setMarkerText _text;

		_mrk setMarkerPos _pos;
		_mrk setMarkerAlpha 0.75;

		// Update arrow marker
		pr _mrk = _thisObject + MRK_ARROW;
		pr _goalParameters = T_GETV("currentGoalParameters");
		// See if location or position is passed
		pr _pPos = CALLSM3("Action", "getParameterValue", _goalParameters, TAG_POS, 0);
		pr _pLoc = CALLSM3("Action", "getParameterValue", _goalParameters, TAG_LOCATION, 0);
		if (_pPos isEqualTo 0 && _pLoc isEqualTo 0) then {
			_mrk setMarkerAlpha 0; // Hide the marker
		} else {
			_mrk setMarkerAlpha 0.5; // Show the marker
			pr _posDest = [0, 0, 0];
			if (!(_pPos isEqualTo 0)) then {
				_posDest = +_pPos;
			};
			if (!(_pLoc isEqualTo 0)) then {
				if (_pLoc isEqualType "") then {
					_posDest = +CALLM0(_pLoc, "getPos");
				} else {
					_posDest = +_pLoc;
				};
			};
			if(count _posDest == 2) then { _posDest pushBack 0 };
			pr _mrkPos = (_posDest vectorAdd _pos) vectorMultiply 0.5;
			_mrk setMarkerPos _mrkPos;
			_mrk setMarkerSize [0.5*(_pos distance2D _posDest), 5];
			_mrk setMarkerDir ((_pos getDir _posDest) + 90);
		};

	ENDMETHOD;

	/*
	Method: unassignVehicle
	Unassigns unit from the vehicle it was assigned to
	
	Returns: nil
	*/
	METHOD(unassignVehicle)
		params [P_THISOBJECT];

		OOP_INFO_1("unassigning vehicle of %1", _thisObject);

		// Unassign this inf unit from its current vehicle
		pr _assignedVehicle = T_GETV("assignedVehicle");
		if (!isNil "_assignedVehicle") then {
			OOP_INFO_1("previously assigned vehicle: %1", _assignedVehicle);
			
			pr _assignedVehAI = CALLM0(_assignedVehicle, "getAI");
			if (_assignedVehAI != "") then { // sanity checks
				pr _unit = T_GETV("agent");
				CALLM1(_assignedVehAI, "unassignUnit", _unit);
			} else {
				OOP_WARNING_1("AI of assigned vehicle %1 doesn't exist", _assignedVehicle);
			};
			
			T_SETV("assignedVehicle", nil);
			T_SETV("assignedVehicleRole", VEHICLE_ROLE_NONE);
		};
		pr _hO = T_GETV("hO");
		moveOut _hO;
		unassignVehicle _hO;
		[_hO] allowGetIn false;
		//[_hO] orderGetIn false;
		//_hO action ["getOut", vehicle _hO];
	ENDMETHOD;
	
	/*
	Method: assignAsDriver
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: true if assignment was successful, false otherwise
	*/
	METHOD(assignAsDriver)
		params [P_THISOBJECT, P_OOP_OBJECT("_veh")];

		ASSERT_OBJECT_CLASS(_veh, "Unit");

		OOP_INFO_2("Assigning %1 as a DRIVER of %2", _thisObject, _veh);

		// Unassign this inf unit from its current vehicle
		pr _assignedVeh = T_GETV("assignedVehicle");
		if (isNil "_assignedVeh") then { _assignedVeh = NULL_OBJECT; };
		pr _assignedVehRole = T_GETV("assignedVehicleRole");
		if (isNil "_assignedVehRole") then { _assignedVehRole = VEHICLE_ROLE_NONE; };
		//pr _assignedCargoIndex = T_GETV("assignedCargoIndex");	if (isNil "_assignedCargoIndex") then {_assignedCargoIndex = -1; };
		//pr _assignedTurretPath = T_GETV("assignedTurretPath");	if (isNil "_assignedTurretPath") then {_assignedTurretPath = -1; };

		if (! (_assignedVeh == _veh && _assignedVehRole == VEHICLE_ROLE_DRIVER) ) then {
			T_CALLM0("unassignVehicle");
		};

		pr _vehAI = CALLM0(_veh, "getAI");
		// Check if someone else is assigned already
		pr _driver = CALLM0(_vehAI, "getAssignedDriver");
		pr _unit = T_GETV("agent");
		if (_driver != NULL_OBJECT && _driver != _unit) then {
			CALLM0(CALLM0(_driver, "getAI"), "unassignVehicle");
			//false
		};// else {
		if(_driver != _unit) then {
			SETV(_vehAI, "assignedDriver", _unit);
			T_SETV("assignedVehicle", _veh);
			T_SETV("assignedVehicleRole", VEHICLE_ROLE_DRIVER);
			T_SETV("assignedCargoIndex", nil);
			T_SETV("assignedTurretPath", nil);
		};
		true
		//};
	ENDMETHOD;
	
	/*
	Method: assignAsGunner
	Disabled for now! Use assignAsTurret instead.
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: nil
	*/
	/*
	METHOD(assignAsGunner)
		params [P_THISOBJECT, P_OOP_OBJECT("_veh") ];
		
		// Unassign this inf unit from its current vehicle
		T_CALLM0("unassignVehicle");
		
		pr _vehAI = CALLM0(_veh, "getAI");
		SETV(_vehAI, "assignedGunner", _thisObject);
		T_SETV("assignedVehicle", _veh);
		T_SETV("assignedVehicleRole", VEHICLE_ROLE_GUNNER);
		T_SETV("assignedCargoIndex", nil);
		T_SETV("assignedTurretPath", nil);
	ENDMETHOD;
	*/
	
	/*
	Method: assignAsTurret
	
	Parameters: _veh, _turretPath
	
	_veh - string, vehicle <Unit>
	_turretPath - array, turret path
	
	Returns: true if assignment was successful, false otherwise
	*/
	METHOD(assignAsTurret)
		params [P_THISOBJECT, P_OOP_OBJECT("_veh"), P_ARRAY("_turretPath")];
		
		OOP_INFO_3("Assigning %1 as a TURRET %2 of %3", _thisObject, _turretPath, _veh);

		ASSERT_OBJECT_CLASS(_veh, "Unit");
		
		// Unassign this inf unit from its current vehicle
		pr _assignedVeh = T_GETV("assignedVehicle");
		if (isNil "_assignedVeh") then {_assignedVeh = NULL_OBJECT; };
		pr _assignedVehRole = T_GETV("assignedVehicleRole");
		if (isNil "_assignedVehRole") then {_assignedVehRole = VEHICLE_ROLE_NONE; };
		//pr _assignedCargoIndex = T_GETV("assignedCargoIndex");	if (isNil "_assignedCargoIndex") then {_assignedCargoIndex = -1; };
		pr _assignedTurretPath = T_GETV("assignedTurretPath");
		if (isNil "_assignedTurretPath") then {_assignedTurretPath = -1; };

		if (! (_assignedVeh == _veh && _assignedVehRole == VEHICLE_ROLE_TURRET && _assignedTurretPath isEqualTo _turretPath) ) then {
			T_CALLM0("unassignVehicle");
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		pr _unit = T_GETV("agent");
		// Check if someone else is already assigned
		pr _turretOperator = CALLM1(_vehAI, "getAssignedTurret", _turretPath);
		if (_turretOperator != NULL_OBJECT && _turretOperator != _unit) then {
			CALLM0(CALLM0(_turretOperator, "getAI"), "unassignVehicle");
			//false
		}; //else {
		if(_turretOperator != _unit) then {
			pr _vehTurrets = GETV(_vehAI, "assignedTurrets");
			if (isNil "_vehTurrets") then { _vehTurrets = []; SETV(_vehAI, "assignedTurrets", _vehTurrets); };
			_vehTurrets pushBackUnique [_unit, _turretPath];
			T_SETV("assignedVehicle", _veh);
			T_SETV("assignedVehicleRole", VEHICLE_ROLE_TURRET);
			T_SETV("assignedCargoIndex", nil);
			T_SETV("assignedTurretPath", _turretPath);
		};
		true
		//};
	ENDMETHOD;
	
	/*
	Method: assignAsCargoIndex
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: true if assignment was successful, false otherwise
	*/
	METHOD(assignAsCargoIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_veh"), P_NUMBER("_cargoIndex")];
		
		ASSERT_OBJECT_CLASS(_veh, "Unit");
		
		OOP_INFO_3("Assigning %1 as CARGO INDEX %2 of %3", _thisObject, _cargoIndex, _veh);

		// Unassign this inf unit from its current vehicle
		pr _assignedVeh = T_GETV("assignedVehicle");
		if (isNil "_assignedVeh") then {_assignedVeh = NULL_OBJECT; };
		pr _assignedVehRole = T_GETV("assignedVehicleRole");
		if (isNil "_assignedVehRole") then {_assignedVehRole = VEHICLE_ROLE_NONE; };
		pr _assignedCargoIndex = T_GETV("assignedCargoIndex");
		if (isNil "_assignedCargoIndex") then {_assignedCargoIndex = -1; };
		//pr _assignedTurretPath = T_GETV("assignedTurretPath");	if (isNil "_assignedTurretPath") then {_assignedTurretPath = -1; };

		if (! (_assignedVeh == _veh && _assignedVehRole == VEHICLE_ROLE_TURRET && _assignedCargoIndex == _cargoIndex) ) then {
			T_CALLM0("unassignVehicle");
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		pr _unit = T_GETV("agent");
		// Check if someone else is already assigned
		pr _cargoPassenger = CALLM1(_vehAI, "getAssignedCargo", _cargoIndex);
		if (_cargoPassenger != NULL_OBJECT && _cargoPassenger != _unit) then {
			CALLM0(CALLM0(_cargoPassenger, "getAI"), "unassignVehicle");
			//false
		};
		// else {
		pr _vehCargo = GETV(_vehAI, "assignedCargo");
		if (isNil "_vehCargo") then { _vehCargo = []; SETV(_vehAI, "assignedCargo", _vehCargo); };
		_vehCargo pushBack [T_GETV("agent"), _cargoIndex];
		T_SETV("assignedVehicle", _veh);
		T_SETV("assignedVehicleRole", VEHICLE_ROLE_CARGO);
		T_SETV("assignedCargoIndex", _cargoIndex);
		T_SETV("assignedTurretPath", nil);
		true
		//};
	ENDMETHOD;

	/*
	Method: executeVehicleAssignment
	Runs ARMA assignAs* commands on this unit.
	
	Returns: nil
	*/
	METHOD(executeVehicleAssignment)
		params [P_THISOBJECT];
		pr _veh = T_GETV("assignedVehicle");
		if (!isNil "_veh") then {
			pr _vehRole = T_GETV("assignedVehicleRole");
			pr _hVeh = CALLM0(_veh, "getObjectHandle");
			pr _hO = T_GETV("hO"); // Object handle of this unit
			switch (_vehRole) do {
				case VEHICLE_ROLE_DRIVER: {
					_hO assignAsDriver _hVeh;
				};
				
				/*
				case VEHICLE_ROLE_GUNNER: {
					_hO assignAsGunner _hVeh;
				};
				*/
				
				case VEHICLE_ROLE_TURRET: {
					pr _turretPath = T_GETV("assignedTurretPath");
					_hO assignAsTurret [_hVeh, _turretPath];
				};
				
				case VEHICLE_ROLE_CARGO: {
					pr _cargoIndex = T_GETV("assignedCargoIndex");
					_hO assignAsCargoIndex [_hVeh, _cargoIndex];
				};
			};
		};
	ENDMETHOD;
	
	/*
	Method: moveInAssignedVehicle
	Instantly moves unit into assigned vehicle
	
	Returns: bool, true if the moveIn* command was executed
	*/
	
	METHOD(moveInAssignedVehicle)
		params [P_THISOBJECT];
		pr _veh = T_GETV("assignedVehicle");
		if (!isNil "_veh") then {
			pr _vehRole = T_GETV("assignedVehicleRole");
			pr _hVeh = CALLM0(_veh, "getObjectHandle");
			pr _hO = T_GETV("hO"); // Object handle of this unit
			[_hO] allowGetIn true;
			[_hO] orderGetIn true;
			switch (_vehRole) do {
				case VEHICLE_ROLE_DRIVER: {
					_hO setPosWorld (getPosWorld _hO);
					_hO moveInDriver _hVeh;
					true
				};
				
				/*
				case VEHICLE_ROLE_GUNNER: {
					_hO moveInGunner _hVeh;
					true
				};
				*/
				
				case VEHICLE_ROLE_TURRET: {
					pr _turretPath = T_GETV("assignedTurretPath");
					_hO setPosWorld (getPosWorld _hO);
					_hO moveInTurret [_hVeh, _turretPath];
					true
				};
				
				case VEHICLE_ROLE_CARGO: {
					pr _cargoIndex = T_GETV("assignedCargoIndex");
					_hO setPosWorld (getPosWorld _hO);
					_hO moveInCargo [_hVeh, _cargoIndex];
					true
				};
			};
		} else {
			false
		};
	ENDMETHOD;
	
	/*
	Method: getAssignedVehicleRole
	Returns assigned vehicle role of the unit
	
	Returns: "DRIVER", "TURRET", "CARGO" or "" if the unit is not assigned anywhere
	*/
	
	METHOD(getAssignedVehicleRole)
		params [P_THISOBJECT];
		
		pr _vehRole = T_GETV("assignedVehicleRole");
		
		// If nothing is assigned
		if (isNil "_vehRole") exitWith {""};
		
		switch (_vehRole) do {
			case VEHICLE_ROLE_DRIVER: {
				"DRIVER"
			};
			
			case VEHICLE_ROLE_TURRET: {
				"TURRET"
			};
			
			case VEHICLE_ROLE_CARGO: {
				"CARGO"
			};
			
			default {""};
		};
	ENDMETHOD;
	
		/*
	Method: getAssignedVehicle
	Returns assigned vehicle or "" if the unit is not assigned to a vehicle
	
	Returns: vehicle's <Unit> object or "" if the unit is not assigned anywhere
	*/
	
	METHOD(getAssignedVehicle)
		params [P_THISOBJECT];
		
		pr _veh = T_GETV("assignedVehicle");
		
		// If nothing is assigned
		if (isNil "_veh") exitWith { NULL_OBJECT };
		
		_veh
	ENDMETHOD;

	// Enables or disables vehicle usage world state property
	METHOD(setAllowVehicleWSP)
		params [P_THISOBJECT, P_BOOL("_value")];
		pr _ws = T_GETV("worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_VEHICLE_ALLOWED, _enable);
	ENDMETHOD;

	// Sets WSP_UNIT_HUMAN_HAS_INTERACTED to some value
	// Default value is true!
	METHOD(setHasInteractedWSP)
		params [P_THISOBJECT, ["_value", true, [true]]];
		pr _ws = T_GETV("worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_HAS_INTERACTED, true);
	ENDMETHOD;

	// Updates vehicle world state properties
	METHOD(updateVehicleWSP)
		params [P_THISOBJECT];

		pr _hO = T_GETV("hO");
		pr _ws = T_GETV("worldState");

		// In any vehicle
		pr _atAnyVehicle = ! ((vehicle _hO) isEqualTo _hO);
		WS_SET(_ws, WSP_UNIT_HUMAN_AT_VEHICLE, _atAnyVehicle);

		// Calculation below only makes sense if some vehicle is assigned
		if (T_GETV("assignedVehicleRole") != VEHICLE_ROLE_NONE) then {
			pr _atAssignedVehAndSeat = T_CALLM0("_isAtAssignedVehicleAndSeat");
			_atAssignedVehAndSeat params ["_atAssignedVehicle", "_atAssignedSeat"];
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE, _atAssignedVehicle);
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_SEAT, _atAssignedSeat);
		};
	ENDMETHOD;

	// Performs checks
	// Returns: [isAtAssignedVehicle, isAtAssignedSeat]
	METHOD(_isAtAssignedVehicleAndSeat)
		params [P_THISOBJECT];

		pr _assignedVehicleRole = T_GETV("assignedVehicleRole");
		pr _vehUnit = T_GETV("assignedVehicle");
		if (isNil "_vehUnit") exitWith {[false, false]};
		pr _hVeh = CALLM0(_vehUnit, "getObjectHandle");
		pr _hO = T_GETV("hO");

		// Bail if target vehicle is null (it might have despawned)
		if (isNull _hVeh) exitWith {[false, false]};
		
		// Check at assigned vehicle
		pr _atAssignedVehicle = (vehicle _hO) isEqualTo _hO;

		// Check at assigned vehicle seat
		pr _atAssignedSeat = switch (_assignedVehicleRole) do {

			// Doesn't seem to make much sense
			case VEHICLE_ROLE_NONE: {
				vehicle _hO == _hO
			};

			case VEHICLE_ROLE_DRIVER: {
				pr _driver = driver _hVeh;
				_driver isEqualTo _hO
			};

			case VEHICLE_ROLE_TURRET : {
				pr _turretPath = T_GETV("assignedTurretPath");
				pr _turretSeat = (fullCrew [_hVeh, "", true]) select {_x#3 isEqualTo _turretPath};
				pr _turretOperator = _turretSeat#0#0;
				
				_turretOperator isEqualTo _hO
			};

			case VEHICLE_ROLE_CARGO : {
				/* FulLCrew output: Array - format:
				0: <Object>unit
				1: <String>role
				2: <Number>cargoIndex (see note in description)
				3: <Array>turretPath
				4: <Boolean>personTurret */
				
				pr _assignedCargoIndex = T_GETV("assignedCargoIndex");
				if (_assignedCargoIndex isEqualType 0) then { // If it's a cargo index
					pr _cargoIndex = _assignedCargoIndex;
					pr _cargoSeat = (fullCrew [_hVeh, "cargo", true]) select {_x#2 isEqualTo _cargoIndex};
					pr _cargoOperator = _cargoSeat#0#0;
					
					_cargoOperator isEqualTo _hO
				} else { // If it's an FFV turret path
					pr _turretPath = _assignedCargoIndex;
					pr _turretSeat = (fullCrew [_hVeh, "Turret", true]) select {_x#3 isEqualTo _turretPath};
					pr _turretOperator = _turretSeat#0#0;
					
					_turretOperator isEqualTo _hO
				};
			}; // case cargo

			default {
				false
			};
		};

		[_atAssignedVehicle, _atAssignedSeat&&_atAssignedVehicle]; // AND them just to be sure
	ENDMETHOD;
	
	// Returns WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_SEAT world state property
	// It is true if unit both in assigned vehicle and at correct seat
	//
	METHOD(getAtAssignedVehicleAndSeat)
		params [P_THISOBJECT];
		pr _ws = T_GETV("worldState");
		WS_GET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_SEAT);
	ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                   Position world state property update
	// ----------------------------------------------------------------------

	METHOD(updatePositionWSP)
		params [P_THISOBJECT];

		pr _target = T_GETV("moveTarget");
		pr _ws = T_GETV("worldState");

		// Bail if nothing is assigned
		if (_target isEqualType 0) exitWith {
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, false);
		};

		if (_target isEqualType []) exitWith {
			pr _value = (T_GETV("hO") distance _target) <= T_GETV("moveRadius");
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, _value);
		};

		if (_target isEqualType objNull) exitWith {
			pr _buildingPosID = T_GETV("moveBuildingPosID");
			if (_buildingPosID == -1) then {	// If target is not building
				pr _value = (T_GETV("hO") distance _target) <= T_GETV("moveRadius");
				WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, _value);
			} else {
				pr _hO = T_GETV("hO");			// If target is building
				pr _actualPosition = _hO buildingPos _buildingPosID;
				pr _value = (_hO distance _actualPosition) <= T_GETV("moveRadius");
				WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, _value);
			};
		};

		if (_target isEqualType NULL_OBJECT) exitWith {
			if (IS_OOP_OBJECT(_target)) then {
				pr _targetObjHandle = CALLM0(_target, "getObjectHandle");
				if (isNull _targetObjHandle) then {
					WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, false);
				} else {
					pr _value = (T_GETV("hO") distance _targetObjHandle) <= T_GETV("moveRadius");
					WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, _value);
				};
			} else {
				WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, false);
			};
		};		
	ENDMETHOD;

	// Use either of these setTarget... methods below to specify the target for movement
	/*
	METHOD(setTargetPosAGL)
		params [P_THISOBJECT, P_POSITION("_pos")];
		T_SETV("moveTarget", _pos);
	ENDMETHOD;

	METHOD(setTargetObject)
		params [P_THISOBJECT, P_OBJECT("_obj")];
		T_SETV("moveTarget", _obj);
	ENDMETHOD;

	// Target is OOP object which has getObjectHandle method
	METHOD(setTargetUnit)
		params [P_THISOBJECT, P_OOP_OBJECT("_obj")];
		T_SETV("moveTarget", _obj);
	ENDMETHOD;*/

	// For object, unit, position
	METHOD(setMoveTarget)
		params [P_THISOBJECT, P_DYNAMIC("_target")];
		T_SETV("moveTarget", _target);
		T_SETV("moveBuildingPosID", -1);
	ENDMETHOD;

	// For building with building pos ID
	METHOD(setMoveTargetBuilding)
		params [P_THISOBJECT, P_OBJECT("_building"), P_NUMBER("_posid")];
		T_SETV("moveTarget", _building);
		T_SETV("moveBuildingPosID", _posID);
	ENDMETHOD;

	METHOD(setMoveTargetRadius)
		params [P_THISOBJECT];
		T_SETV("moveRadius", _radius);
	ENDMETHOD;

	// Resets target
	METHOD(resetMoveTarget)
		params [P_THISOBJECT];
		T_SETV("moveTarget", 0);
		T_SETV("moveRadius", -1);
	ENDMETHOD;

	// Returns AGL position of move target
	METHOD(getMoveTargetPosAGL)
		params [P_THISOBJECT];

		pr _target = T_GETV("moveTarget");

		// Bail if nothing is assigned
		if (_target isEqualType 0) exitWith {
			OOP_ERROR_0("Move target is not assigned!");
			[0,0,0];
		};

		if (_target isEqualType []) exitWith {
			getPos _target;
		};

		if (_target isEqualType objNull) exitWith {
			pr _buildingPosID = T_GETV("moveBuildingPosID");
			if (_buildingPosID == -1) then {	// If target is not building
				getPos _target;
			} else {
				pr _actualPosition = _hO buildingPos _buildingPosID;
				_actualPosition;
			};
		};

		if (_target isEqualType NULL_OBJECT) exitWith {
			if (IS_OOP_OBJECT(_target)) then {
				pr _targetObjHandle = CALLM0(_target, "getObjectHandle");
				if (isNull _targetObjHandle) then {
					OOP_ERROR_1("Object handle of OOP object %1 is null!", _target);
					[0,0,0]; // Error!
				} else {
					getPos _targetObjHandle;
				};
			} else {
				OOP_ERROR_1("Target is an invalid OOP object: %1", _target);
				[0,0,0]; // Error WTF!
			};
		};
	ENDMETHOD;

	// Teleports the unit to destination
	METHOD(instantMoveToTarget)
		params [P_THISOBJECT];

		pr _destPos = T_CALLM0(getMoveTargetPosAGL);
		pr _hO = T_GETV("hO");
		if (!(_destPos isEqualTo [0,0,0])) then {
			_hO setPos _destPos;
		};
	ENDMETHOD;

	METHOD(orderMoveToTarget)
		params [P_THISOBJECT];
		pr _destPos = T_CALLM0(getMoveTargetPosAGL);
		if (!(_destPos isEqualTo [0,0,0])) then {
			pr _hO = T_GETV("hO");
			if (GET_AGENT_FLAG(_hO)) then {
				_hO setDestination [_destPos,"LEADER PLANNED",true];
			} else {
				_hO doMove _destPos;
			};
		};
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The group AI resides in its own thread
	// ----------------------------------------------------------------------
	
	METHOD(getMessageLoop)
		gMessageLoopUnscheduled
	ENDMETHOD;

	// Common interface
	/* virtual */ METHOD(getCargoUnits)
		[]
	ENDMETHOD;

	/* override */ METHOD(setUrgentPriorityOnAddGoal)
		true
	ENDMETHOD;

	// Debug
	// Returns array of class-specific additional variable names to be transmitted to debug UI
	/* override */ METHOD(getDebugUIVariableNames)
		[
			"hO",
			"assignedVehicle",
			"assignedVehicleRole",
			"assignedCargoIndex",
			"assignedTurretPath",
			"moveTarget",
			"moveRadius"
		]
	ENDMETHOD;

ENDCLASS;