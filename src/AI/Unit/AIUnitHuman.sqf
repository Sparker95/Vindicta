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
	VARIABLE("orderedToMove");
	VARIABLE("prevPos");
	VARIABLE("stuckDuration");
	VARIABLE("timeLastProcess");

	// Current object we are interacting with, set by varius interaction actions
	VARIABLE("interactionObject");

	// Object this bot is currently talking to, or objNull if he isn't
	VARIABLE("talkObject");
	// Ref to dialogue this unit is currently hosting, or NULL_OBJECT
	VARIABLE("dialogue");

	// Current object or position which represents danger
	// IF there is no danger source, this is nil
	VARIABLE("dangerSource");
	VARIABLE("dangerTimeEnd");	// Time when the duration of this danger ends
	VARIABLE("dangerLevel");	// Number, current danger level
	VARIABLE("dangerRadius");	// Radius we must be away from this danger src

	// Bool, true when arrested
	VARIABLE("arrested");

	#ifdef DEBUG_GOAL_MARKERS
	VARIABLE("markersEnabled");
	#endif
	FIX_LINE_NUMBERS()

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
		T_SETV("stuckDuration", 0);
		pr _hO = T_GETV("hO");
		T_SETV("prevPos", getPos _hO);
		T_SETV("orderedToMove", false);
		T_SETV("timeLastProcess", time);

		T_SETV("interactionObject", objNull);

		// Dialogue
		T_SETV("talkObject", objNull);
		T_SETV("dialogue", NULL_OBJECT);

		// Danger source
		T_SETV("dangerSource", nil);
		T_SETV("dangerLevel", 0);
		T_SETV("dangerTimeEnd", 0);
		T_SETV("dangerRadius", 0);

		// Arrested
		T_SETV("arrested", false);

	ENDMETHOD;
	
	METHOD(delete)
		params [P_THISOBJECT];
		
		OOP_INFO_1("DELETE %1", _thisObject);
		
		// Unassign this unit from its assigned vehicle
		T_CALLM0("unassignVehicle");

		// Delete dialogue if it exists
		pr _dlg = T_GETV("dialogue");
		if (!IS_NULL_OBJECT(_dlg)) then {
			DELETE(_dlg);
		};

		#ifdef DEBUG_GOAL_MARKERS
		T_CALLM0("_disableDebugMarkers");
		#endif
		FIX_LINE_NUMBERS()

		T_CALLM0("removeFromProcessCategory");
	ENDMETHOD;

	public override METHOD(process)
		params [P_THISOBJECT, P_BOOL("_spawning")];

		// Assert threading
		ASSERT_UNSCHEDULED(_thisObject);

		#ifdef DEBUG_GOAL_MARKERS
		if(T_GETV("markersEnabled")) then {
			pr _unused = "";
		};	
		#endif

		pr _hO = T_GETV("hO");
		pr _deltaTime = time - T_GETV("timeLastProcess");

		// === Update world state properties
		T_CALLM0("updateVehicleWSP");
		T_CALLM0("updatePositionWSP");

		// Stuck detector
		if (T_GETV("orderedToMove")) then {
			pr _prevPos = T_GETV("prevPos");
			pr _hO = T_GETV("hO");
			if (_hO distance _prevPos < 3) then {
				pr _stuckTimer = T_GETV("stuckDuration");
				T_SETV("stuckDuration", _stuckTimer + _deltaTime);
			} else {
				T_SETV("stuckDuration", 0);
				T_SETV("prevPos", ASLtoAGL (getPosASL _hO));
			};
		};

		// Process the dialogue if we have it
		pr _dlg = T_GETV("dialogue");
		if (!IS_NULL_OBJECT(_dlg)) then {
			CALLM0(_dlg, "process");
			// If dialogue has ended, delete it
			if (CALLM0(_dlg, "hasEnded")) then {
				DELETE(_dlg);
				T_SETV("dialogue", NULL_OBJECT);
				T_SETV("talkObject", objNull);
			} else {
				// Check if we can talk
				// If we can't any more, end this dialogue
				pr _canTalk = T_CALLM0("canTalk");
				if (!_canTalk) then {
					DELETE(_dlg);
					T_SETV("dialogue", NULL_OBJECT);
					T_SETV("talkObject", objNull);

					// Say a phrase why we can't talk any longer
					pr _text = selectRandom g_phrasesCantTalkAnyMore;
					CALLSM3("Dialogue", "objectSaySentence", NULL_OBJECT, _hO, _text);
				};
			};
		};

		// Process danger
		if (!isNil {T_GETV("dangerSource")}) then {
			if (time > T_GETV("dangerTimeEnd")) then {
				T_SETV("dangerSource", nil);
				T_SETV("dangerLevel", 0);
			};
		};

		CALLCM("AI_GOAP", _thisObject, "process", [_spawning]);

		T_SETV("timeLastProcess", time);

		#ifdef DEBUG_GOAL_MARKERS
		T_CALLM0("_updateDebugMarkers");
		#endif
	ENDMETHOD;
	FIX_LINE_NUMBERS()


	public override METHOD(onGoalChosen)
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
							TAG_TARGET_AMBIENT_ANIM,
							TAG_TARGET_STAND_IDLE,
							TAG_TARGET_VEHICLE_UNIT,
							TAG_TARGET_DIALOGUE
							//TAG_TARGET_SHOOT_RANGE,	// no we don't walk straight to shooting range target to shoot it
							//TAG_TARGET_SHOOT_LEG		// no we don't need to walk to someone to shoot him
							]) then {
				_newParameters pushBack [TAG_MOVE_TARGET, _value];
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
					TAG_TARGET_SHOOT_LEG,
					TAG_TARGET_STAND_IDLE,
					TAG_TARGET_DIALOGUE
			]) then {
				T_CALLM1("setHasInteractedWSP", false);
			};
		} forEach _goalParameters;

		// Set move target if we have got it from parameters
		if (!(_moveTarget isEqualTo 0)) then {
			T_CALLM1("setMoveTarget", _moveTarget);
			
			// Provide move radius from goal if it exists
			pr _moveRadius = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_MOVE_RADIUS, -1);
			if (_moveRadius == -1) then {
				T_CALLM1("setMoveTargetRadius", 2.2);	// Action can override it anyway
			} else {
				T_CALLM1("setMoveTargetRadius", _moveRadius);
			};
			
			T_CALLM0("updatePositionWSP");
		};

		// Append ned parameters to goal parameters
		_goalParameters append _newParameters;

	ENDMETHOD;
	

	public override METHOD(start)
		params [P_THISOBJECT];
		T_CALLM1("addToProcessCategory", "MiscLowPriority");
	ENDMETHOD;

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
		pr _enabled = if(_grp != NULL_OBJECT) then {
			pr _grpAI = CALLM0(_grp, "getAI");
			// This shouldn't be possible once AI start is synchronized between group and units
			if(isNil "_grpAI" || {_grpAI == NULL_OBJECT} || {!IS_OOP_OBJECT(_grpAI)}) then {
				false
			} else {
				GETV(_grpAI, "unitMarkersEnabled") && GETV(_grpAI, "markersEnabled")
			};
		} else {
			false
		};
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
	public METHOD(unassignVehicle)
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
	public METHOD(assignAsDriver)
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
	Method: assignAsTurret
	
	Parameters: _veh, _turretPath
	
	_veh - string, vehicle <Unit>
	_turretPath - array, turret path
	
	Returns: true if assignment was successful, false otherwise
	*/
	public METHOD(assignAsTurret)
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
	public METHOD(assignAsCargoIndex)
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
	Method: assignVehicle
	Description
	
	Access: private, used by unit actions and goals.
	
	Returns: bool
	*/
	METHOD(_assignVehicle)
		params [P_THISOBJECT, P_STRING("_vehRole"), P_ARRAY("_turretPath"), P_OOP_OBJECT("_unitVeh")];
		
		OOP_INFO_2("Assigning vehicle: %1, role: %2", _unitVeh, _vehRole);

		pr _hVeh = CALLM0(_unitVeh, "getObjectHandle");
		pr _hO = T_GETV("hO");
		pr _vehAI = CALLM0(_unitVeh, "getAI");
		pr _unit = T_GETV("agent");

		switch (_vehRole) do {	
		/*
		[[hemttD,"driver",-1,[],false],
		[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[B Alpha 1-1:2,"Turret",7,[0],true],[B Alpha 1-1:3,"Turret",15,[1],true]]
		
		[[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[<NULL-object>,"cargo",3,[],false],[<NULL-object>,"cargo",4,[],false],[<NULL-object>,"cargo",5,[],false],[<NULL-object>,"cargo",6,[],false],[<NULL-object>,"cargo",8,[],false],[<NULL-object>,"cargo",9,[],false],[<NULL-object>,"cargo",10,[],false],[<NULL-object>,"cargo",11,[],false],[<NULL-object>,"cargo",12,[],false],[<NULL-object>,"cargo",13,[],false],[<NULL-object>,"cargo",14,[],false],[<NULL-object>,"cargo",16,[],false]]
		
		[[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[<NULL-object>,"cargo",3,[],false],[<NULL-object>,"cargo",4,[],false],[<NULL-object>,"cargo",5,[],false],[<NULL-object>,"cargo",6,[],false],[<NULL-object>,"cargo",8,[],false],[<NULL-object>,"cargo",9,[],false],[<NULL-object>,"cargo",10,[],false],[<NULL-object>,"cargo",11,[],false],[<NULL-object>,"cargo",12,[],false],[<NULL-object>,"cargo",13,[],false],[<NULL-object>,"cargo",14,[],false],[<NULL-object>,"cargo",16,[],false]]
		*/
			case "DRIVER": {
				pr _success = CALLM1(_AI, "assignAsDriver", _unitVeh);
				
				// Return
				_success
			};
			case "TURRET" : {
				pr _success = T_CALLM2("assignAsTurret", _unitVeh, _turretPath);
				
				// Return
				_success
			};
			case "CARGO" : {
				/* FulLCrew output: Array - format:
				0: <Object>unit
				1: <String>role
				2: <Number>cargoIndex (see note in description)
				3: <Array>turretPath
				4: <Boolean>personTurret */
				
				pr _freeCargoSeats = (fullCrew [_hVeh, "cargo", true]) select {
					pr _assignedPassenger = CALLM1(_vehAI, "getAssignedCargo", _x select 2);
					( (!alive (_x select 0)) ||
					  ((_x select 0) isEqualTo _hO) ) &&
					  ( _assignedPassenger == "" || _assignedPassenger == _unit)
				};
				
				pr _freeFFVSeats = (fullCrew [_hVeh, "Turret", true]) select {
					pr _assignedTurret = CALLM1(_vehAI, "getAssignedTurret", _x select 3);
					( (!alive (_x select 0)) || ((_x select 0) isEqualTo _hO)) && (_x select 4) && (_assignedTurret == "" || _assignedTurret == _unit)
				}; // empty and person turret
				
				pr _freeSeats = _freeCargoSeats + _freeFFVSeats;
				
				// Choose a new cargo seat
				if (count _freeSeats == 0) then {
					// No room for this soldier in the vehicle
					// Mission failed
					// We are dooomed!
					// https://www.youtube.com/watch?v=5vSUV1nii5k
					// Return
					false
				} else { // if count free seats == 0
					pr _chosenSeat = selectRandom _freeSeats;
					_chosenSeat params ["_seatUnit", "_seatRole", "_seatCargoIndex", "_seatTurretPath"]; //, "_seatPersonTurret"];
					if (_seatRole == "cargo") then {
						pr _success = CALLM2(_AI, "assignAsCargoIndex", _unitVeh, _seatCargoIndex);
						
						// Return
						_success
					} else {
						pr _success = CALLM2(_AI, "assignAsTurret", _unitVeh, _seatTurretPath);
						
						// Return
						_success
					};
				}; // else
			}; // case
		}; // switch
		
	ENDMETHOD;

	/*
	Method: executeVehicleAssignment
	Runs ARMA assignAs* commands on this unit.
	
	Returns: nil
	*/
	public METHOD(executeVehicleAssignment)
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
	
	public METHOD(moveInAssignedVehicle)
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
	
	public METHOD(getAssignedVehicleRole)
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
	
	public METHOD(getAssignedVehicle)
		params [P_THISOBJECT];
		
		pr _veh = T_GETV("assignedVehicle");
		
		// If nothing is assigned
		if (isNil "_veh") exitWith { NULL_OBJECT };
		
		_veh
	ENDMETHOD;

	/*
	Returns vehicle, vehicle role, cargo index, turret path
	
	Returns: [_cargoIndex, _turretPath]
	_cargoIndex - index or -1
	_turretPath - turret path or []
	*/
	METHOD(getAssignedVehicleParameters)
		params [P_THISOBJECT];
		pr _vehRole = T_CALLM0("getAssignedVehicleRole");
		pr _cargoIndex = T_GETV("assignedCargoIndex");
		if (isNil "_cargoIndex") then {_cargoIndex = -1;};
		pr _turretPath = T_GETV("assignedTurretPath");
		if (isNil "_turretPath") then {_turretPath = [];};

		return [_cargoIndex, _turretPath];
	ENDMETHOD;

	// Enables or disables vehicle usage world state property
	public METHOD(setAllowVehicleWSP)
		params [P_THISOBJECT, P_BOOL("_value")];
		pr _ws = T_GETV("worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_VEHICLE_ALLOWED, _value);
	ENDMETHOD;

	// Sets WSP_UNIT_HUMAN_HAS_INTERACTED to some value
	// Default value is true!
	public METHOD(setHasInteractedWSP)
		params [P_THISOBJECT, ["_value", true, [true]]];
		pr _ws = T_GETV("worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_HAS_INTERACTED, _value);
	ENDMETHOD;

	// Sets WSP_UNIT_HUMAN_IN_DANGER
	// Default value is true!
	public virtual METHOD(setInDangerWSP)
		params [P_THISOBJECT, ["_value", true, [true]]];
		pr _ws = T_GETV("worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_IN_DANGER, _value);
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
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE, _atAssignedSeat);
		} else {
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE, false);
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE, false);
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
		pr _atAssignedVehicle = (vehicle _hO) isEqualTo _hVeh;

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
	
	// Returns WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE world state property
	// It is true if unit both in assigned vehicle and at correct seat
	//
	METHOD(getAtAssignedVehicleAndSeat)
		params [P_THISOBJECT];
		pr _ws = T_GETV("worldState");
		WS_GET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE);
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
				pr _actualPosition = _target buildingPos _buildingPosID;
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
		params [P_THISOBJECT, P_NUMBER("_radius")];
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
			[0,0,0];  // fucking return statement
		};

		if (_target isEqualType []) exitWith {
			OOP_INFO_1("getMoveTargetPosAGL returning array: %1", _target);
			_target; // fucking return statement
		};

		if (_target isEqualType objNull) exitWith {
			pr _buildingPosID = T_GETV("moveBuildingPosID");
			pr _return = if (_buildingPosID == -1) then {	// If target is not building
				OOP_INFO_1("getMoveTargetPosAGL returning object pos: %1", getPos _target);
				ASLtoAGL (getPosASL _target);
			} else {
				pr _actualPosition = _target buildingPos _buildingPosID;
				OOP_INFO_1("getMoveTargetPosAGL returning building pos: %1", _actualPosition);
				_actualPosition;
			};
			OOP_INFO_1("getMoveTargetPosAGL returning object pos or building pos: %1", _return);

			_return; // fucking return statement
		};

		if (_target isEqualType NULL_OBJECT) exitWith {
			pr _return = if (IS_OOP_OBJECT(_target)) then {
				pr _targetObjHandle = CALLM0(_target, "getObjectHandle");
				if (isNull _targetObjHandle) then {
					OOP_ERROR_1("Object handle of OOP object %1 is null!", _target);
					[0,0,0]; // Error!
				} else {
					OOP_INFO_1("getMoveTargetPosAGL returning pos of unit object handle: %1", getPos _targetObjHandle);
					getPos _targetObjHandle;
				};
			} else {
				OOP_ERROR_1("Target is an invalid OOP object: %1", _target);
				[0,0,0]; // Error WTF!
			};

			_return; // fucking return statement
		};

		[0,0,0];  // fucking return statement if we didn't hit any other fucking exitwith
	ENDMETHOD;

	FIX_LINE_NUMBERS()
	// Teleports the unit to destination
	METHOD(instantMoveToTarget)
		params [P_THISOBJECT];

		pr _destPos = T_CALLM0("getMoveTargetPosAGL");
		OOP_INFO_1("instantMoveToTarget: %1", _destPos);
		pr _hO = T_GETV("hO");
		if (!(_destPos isEqualTo [0,0,0])) then {
			_hO setPos _destPos;
			OOP_INFO_0(" setPos executed");
		};
	ENDMETHOD;
	FIX_LINE_NUMBERS()

	METHOD(orderMoveToTarget)
		params [P_THISOBJECT];
		FIX_LINE_NUMBERS()
		pr _destPos = T_CALLM0("getMoveTargetPosAGL");

		#ifdef DEBUG_GOAP
		if (isNil "_destPos") then {
			//DUMP_CALLSTACK;
			OOP_ERROR_0("getMoveTargetPosAGL returned nil!");
		};
		#endif

		OOP_INFO_1("orderMoveToTarget: %1", _destPos);
		if (!(_destPos isEqualTo [0,0,0])) then {
			pr _hO = T_GETV("hO");
			if (GET_AGENT_FLAG(_hO)) then {
				_hO setDestination [_destPos, "FORMATION PLANNED" ,true]; // "FORMATION PLANNED" seems to be give good results.
			} else {
				_hO doMove _destPos;
			};
			T_SETV("orderedToMove", true);
			T_SETV("stuckDuration", 0); // Reset stuck timer	
			OOP_INFO_0("  move order executed");
		};
	ENDMETHOD;

	METHOD(stopMoveToTarget)
		params [P_THISOBJECT];
		pr _hO = T_GETV("hO");
		if (GET_AGENT_FLAG(_hO)) then {
			_hO setDestination [ getPos _hO,"LEADER DIRECT",true]; // Doesn't want to stop otherwise sometimes
		};
		doStop _hO;
		T_SETV("orderedToMove", false);
		T_SETV("stuckDuration", 0); // Reset stuck timer

		// Set world state property
		// After this is issued, we are no longer following leader
		pr _ws = T_GETV("worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false);
	ENDMETHOD;

	public override METHOD(getMessageLoop)
		gMessageLoopUnscheduled;
	ENDMETHOD;

	// Common interface
	public virtual METHOD(getCargoUnits)
		[]
	ENDMETHOD;

	public override METHOD(setUrgentPriorityOnAddGoal)
		true
	ENDMETHOD;

	// Performs genetic checks if a bot can talk (behaviour, alive, vehicle, ...)
	METHOD(canTalk)
		params [P_THISOBJECT];

		pr _hO = T_GETV("hO");

		// Check if we are on foot
		#define __CAN_TALK_ON_FOOT ((vehicle _hO) isEqualTo _hO)

		// Check behaviour
		#define __CAN_TALK_BEHAVIOUR ((behaviour _hO) in ["CARELESS", "SAFE", "AWARE"])

		// Check danger world state property
		#define __CAN_TALK_DANGER !WS_GET(T_GETV("worldState"), WSP_UNIT_HUMAN_IN_DANGER)

		// Check life state
		#define __CAN_TALK_LIFE_STATE (lifeState _hO != "INCAPACITATED")

		OOP_INFO_4("canTalk: alive: %1, onFoot: %2, behaviour: %3, danger: %4", alive _hO, __CAN_TALK_ON_FOOT, __CAN_TALK_BEHAVIOUR, __CAN_TALK_DANGER);

		(alive _hO) && {__CAN_TALK_LIFE_STATE} && {__CAN_TALK_ON_FOOT} && {__CAN_TALK_BEHAVIOUR} && {__CAN_TALK_DANGER};
	ENDMETHOD;

	/*
	Can be overriden in derived classes.
	Here we can resolve more specific situations if the unit can talk or not,
	for instance danger and other conditions.
	Returning true will cause standard dialogue handling to run.
	Returning false will cause the dialogue to be not created.
	*/
	protected virtual METHOD(handleStartNewDialogue)
		//params [P_THISOBJECT, P_OBJECT("_unitTalkTo"), P_NUMBER("_remoteClientID"), P_STRING("_dlgClassName")];
		true;
	ENDMETHOD;

	/*
	Virtual method which must be overriden in derived classes to return the class name of dialogue
	which this unit will host when player tries to talk to him.
	*/
	protected virtual METHOD(getDialogueClassName)
		params [P_THISOBJECT];
		"DialogueTest";
	ENDMETHOD;

	/*
	Returns true/false whether the unit can start a new conversation
	*/
	public METHOD(canStartNewDialogue)
		params [P_THISOBJECT];

		OOP_INFO_0("canStartNewDialogue");

		pr _hO = T_GETV("hO");

		pr _canTalk = T_CALLM0("canTalk");

		// Check if current goal allows talking
		pr _canTalkGoal = true; // If we have no goal then we can talk
		pr _currentGoal = T_GETV("currentGoal");
		if (_currentGoal != "") then {
			_canTalkGoal = CALLSM0(_currentGoal, "canTalk");
			OOP_INFO_1("  can talk goal: %1", _canTalkGoal);
		};

		pr _talkObj = T_GETV("talkObject");
		pr _dlg = T_GETV("dialogue");
		// We can start a new conversation if we can talk in general
		// and if we are not talking to anyone right now
		pr _return = (isNull _talkObj) &&  {IS_NULL_OBJECT(_dlg)} && {_canTalkGoal} && {_canTalk};

		OOP_INFO_1("  return: %1", _return);

		_return;
	ENDMETHOD;

	// Starts a new conversation
	public METHOD(startNewDialogue)
		params [P_THISOBJECT, P_OBJECT("_unitTalkTo"), P_NUMBER("_remoteClientID")];

		OOP_INFO_1("startNewDialogue: %1", _this);

		pr _hO = T_GETV("hO");

		// Bail if not alive
		if (!alive _hO) exitWith {
			OOP_INFO_0("  NPC is not alive");
		};

		// Resolve dialogue class name
		pr _dlgClassName = T_CALLM0("getDialogueClassName");

		// Call class-specific dialogue handling
		pr _stdDlgHandling = T_CALLM3("handleStartNewDialogue", _unitTalkTo, _remoteClientID, _dlgClassName);
		if (!_stdDlgHandling) exitWith {false};

		if (T_CALLM0("canStartNewDialogue")) then {

			OOP_INFO_0("  NPC can start dialogue");

			// If another dialogue exists already, delete it
			// Although it shouldn't happen, it's better to ensure it
			pr _dlg = T_GETV("dialogue");
			if (!IS_NULL_OBJECT(_dlg)) then {
				OOP_INFO_1("  deleting old dialogue: %1", _dlg);
				DELETE(_dlg);
			};

			pr _args = [_hO, _unitTalkTo, _remoteClientID];
			pr _newDlg = NEW(_dlgClassName, _args);
			CALLM0(_newDlg, "startProcessing");
			OOP_INFO_1("  created dialogue: %1", _newDlg);
			T_SETV("dialogue", _newDlg);
			T_SETV("talkObject", _unitTalkTo);

			// Call process to accelerate response
			T_CALLM0("process");
		} else {
			// If the bot can't talk, he will say a phrase
			OOP_INFO_0("  NPC is busy");
			pr _text = selectRandom g_phrasesCantTalkBusy;
			CALLSM3("Dialogue", "objectSaySentence", NULL_OBJECT, _hO, _text);
		};
	ENDMETHOD;

	// Adds danger source
	// In fact the bot can process only one at a time
	// If passed danger level is below the current danger level, it wil lbe ignored
	METHOD(addDangerSource)
		params [P_THISOBJECT, P_DYNAMIC("_dangerSrc"), P_NUMBER("_radius"), P_NUMBER("_duration"), P_NUMBER("_dangerLevel")];

		OOP_INFO_1("addDangerSource: %1", _this);

		// Ignore if the new danger level is below the current one
		// Ignore if we are already out of danger radius
		if (_dangerLevel > T_GETV("dangerLevel") &&
			{(T_GETV("hO") distance _dangerSrc) < _radius}
			) then {
			OOP_INFO_0("  added");
			T_SETV("dangerSource", _dangerSrc);
			T_SETV("dangerTimeEnd", time + _duration);
			T_SETV("dangerLevel", _dangerLevel);
			T_SETV("dangerRadius", _radius);
		};
	ENDMETHOD;

	// Adds car horn danger source
	STATIC_METHOD(addCarCollisionDanger)
		params [P_THISCLASS, P_OBJECT("_car"), P_ARRAY("_units"), ["_radius", 15]];

		if (isNull _car) exitWith {};
		
		{
			pr _ai = GET_AI_FROM_OBJECT_HANDLE(_x);
			if (!IS_NULL_OBJECT(_ai)) then {
				// params [P_THISOBJECT, P_DYNAMIC("_dangerSrc"), P_NUMBER("_radius"), P_NUMBER("_duration"), P_NUMBER("_dangerLevel")];
				CALLM4(_ai, "addDangerSource", _car, _radius, 5, 10);
				CALLM0(_ai, "setUrgentPriority"); // Will cause this bot to be processed ASAP
			};
		} forEach _units;
	ENDMETHOD;



	// Perform arrest of this human, or let him free
	public METHOD(setArrest)
		params [P_THISOBJECT, P_BOOL("_arrested")];
		pr _hO = T_GETV("hO");
		if (_arrested) then {		
			_hO playMoveNow "acts_aidlpsitmstpssurwnondnon01";
			_hO disableAI "MOVE"; // Disable AI Movement
			_hO disableAI "AUTOTARGET"; // Disable AI Autotarget
			_hO disableAI "ANIM"; // Disable AI Behavioural Scripts
			_hO allowFleeing 0; // Disable AI Fleeing
			SET_ARRESTED_FLAG(_hO);
			T_SETV("arrested", true);
		} else {
			_hO enableAI "ALL";
			_hO switchMove "acts_aidlpsitmstpssurwnondnon_out"; // Stand up
			RESET_ARRESTED_FLAG(_hO);
			T_SETV("arrested", false);
		};
	ENDMETHOD;

	// Debug
	// Returns array of class-specific additional variable names to be transmitted to debug UI
	public override METHOD(getDebugUIVariableNames)
		[
			"hO",
			"dangerSource",
			"dangerTimeEnd",
			"dangerLevel",
			"dangerRadius",
			"assignedVehicle",
			"assignedVehicleRole",
			"assignedCargoIndex",
			"assignedTurretPath",
			"moveTarget",
			"moveBuildingPosID",
			"moveRadius",	// Radius for movement completion
			"orderedToMove",
			"prevPos",
			"stuckDuration",
			"timeLastProcess",
			"interactionObject"
		]
	ENDMETHOD;

ENDCLASS;