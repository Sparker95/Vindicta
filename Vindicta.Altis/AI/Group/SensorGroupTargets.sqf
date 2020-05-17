#include "common.hpp"
#include "..\..\Undercover\UndercoverMonitor.hpp"

/*
Sensor for a group to gather spotted enemies and relay them to the garrison.
*/

#define pr private

// Maximum age until target is going to be revealed
#define TARGET_AGE_TO_REVEAL 5

// Time until targets are relayed to garrison leader
#define TARGET_TIME_RELAY 5

// Update interval of this sensor
#define UPDATE_INTERVAL 4

// ----- Debugging definitions -----

// Various debug outputs
#ifndef RELEASE_BUILD
#define DEBUG_SENSOR_GROUP_TARGETS
#endif

// Prints spotted enemies every update iteration, if the combat timer has reached treshold
#define PRINT_SPOTTED_TARGETS

// Prints targets received through the stimulus
//#define PRINT_RECEIVED_TARGETS

#define OOP_CLASS_NAME SensorGroupTargets
CLASS("SensorGroupTargets", "SensorGroupStimulatable")

	VARIABLE("comTime"); // Counter that shows how long the group has been in combat state
	VARIABLE("prevMsgID"); // Message ID of the previous receiveTargets message, so that we don't oversaturate the garrison AI thread

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("comTime", 0);
		T_SETV("prevMsgID", -1); // First message ID is negative as it is always handled
	ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(update)
		params [P_THISOBJECT];
		
		// Unpack the group handle
		pr _hG = T_GETV("hG");
		
		#ifdef DEBUG_SENSOR_GROUP_TARGETS
		OOP_INFO_1("[SensorGroupTargets::Update] Info: %1", _thisObject);
		#endif
		
		pr _side = side _hG;
		pr _otherSides = [WEST, EAST, INDEPENDENT, CIVILIAN] - [_side];
		pr _allPlayers = allPlayers;
		
		if ({ alive _x } count units _hG > 0) then {
		
			// Check spotted targets
			pr _nt = leader _hG targetsQuery [objNull, sideUnknown, "", [], 0/*TARGET_AGE_TO_REVEAL*/];
			// Filter objects that are of different side and are currently being seen
			pr _currentlyObservedObjects = _nt select {
				//private _o = _x select 1;
				//private _s = side _o;
				//Target age is the time that has passed since the last time the group has actually seen the enemy unit.
				// Values lower than 0 mean that they see the enemy right now
				//private _age = _x select 5;
				side group (_x#1) in _otherSides && _x#5 <= TARGET_AGE_TO_REVEAL
			};
			
			#ifdef DEBUG_SENSOR_GROUP_TARGETS
			OOP_INFO_0("Observed targets:");
			{
				OOP_INFO_2(" %1: %2", _foreachindex, _x);
			} forEach _currentlyObservedObjects;
			#endif

			// Loop through potential targets and find players(also in vehicles) to send data to their UndercoverMonitor
			pr _exposedVehicleCrew = [];
			{
				pr _o = _x select 1;
				
				if (_o isKindOf "Man") then {
					// It's a Man
					if (UNDERCOVER_IS_UNIT_SUSPICIOUS(_o)) then {
						pr _AI = T_GETV("AI");
						SETV(_AI, "suspTarget", _o);
					};

					pr _args = [_o, _hG];
					REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitSpotted", _args, _o, false); //classNameStr, methodNameStr, extraParams, targets, JIP
				} else {
					// It's not a player
					// But might be a man or a vehicle
					if (!(_o isKindOf "Man")) then {
						// It's a vehicle \o/ ! Let's check it's crew if there are players hiding >)
						{
							if (_x in _allPlayers) then {
								if (UNDERCOVER_IS_UNIT_EXPOSED(_x)) then {
									// I can see you!
									pr _args = [_x, _hG];
									REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitSpotted", _args, _x, false);
									
									// Add the unit to the list of observed vehicle crew
									_exposedVehicleCrew pushBack [1, _x, side group _x, "Man", getPos _o, 0];
								};
							};
						} forEach (crew _o);
					};
				};
			} forEach _currentlyObservedObjects;
			
			// Add exposed vehicle crew to the array
			_currentlyObservedObjects append _exposedVehicleCrew;
		
			if (behaviour leader _hG isEqualTo "COMBAT") then {
				// Find new enemies
				/*
				0 accuracy: Number - a coefficient, which reflects how close the returned result to the query filter. Range: 0 - 1 (1 - best match)
				1 target: Object - the actual target object
				2 targetSide: Side - side of the target
				3 targetType: String - target typeOf
				4 targetPosition: Array - [x,y] of the target
				5 targetAge: Number - the actual target age in seconds (can be negative)
				*/
				pr _comTime = T_GETV("comTime");
				// Relay targets instantly if not attached to location
				pr _loc = CALLM0(CALLM0(T_GETV("group"), "getGarrison"), "getLocation");
				if (_comTime > TARGET_TIME_RELAY || _loc == "") then {

					pr _observedTargets = _currentlyObservedObjects select {
						pr _hO = _x select 1;
						//[side group  _hO, _side] call BIS_fnc_sideIsEnemy &&
						side group  _hO in _otherSides &&
						_hO getVariable [UNDERCOVER_WANTED, true] // If there is no variable, then this unit has no undercoverMonitor, so he is always wanted if spotted
					};
					// Have we spotted anyone??
					if (count _observedTargets > 0) then {
						pr _dateNumber = dateToNumber date;
						// Add 1 to age since its lowest value is -1};
						_observedTargets = _observedTargets apply {
							pr _hO = _x select 1;
							pr _unit = GET_UNIT_FROM_OBJECT_HANDLE(_hO);
							pr _eff = GET_UNIT_EFFICIENCY_FROM_OBJECT_HANDLE(_hO);
							if (IS_NULL_OBJECT(_unit)) then {
								_unit = format ["unknown %1", _hO];
								_eff = +(T_efficiency#T_INF#T_INF_rifleman);
							};
							TARGET_NEW(_unit, _hG knowsAbout _hO,  _x select 4, _dateNumber, +_eff)
						};
					
						#ifdef PRINT_SPOTTED_TARGETS
							OOP_INFO_2("[SensorGroupTargets::Update] Info: GroupHandle: %1, targets: %2", _hg, _observedTargets);
						#endif
						// Send targets to garrison AI
						// this->AI->agent->garrison->AI WTF??
						pr _AI = T_GETV("AI");
						pr _group = GETV(_AI, "agent");
						pr _gar = CALLM0(_group, "getGarrison");
						_garAI = GETV(_gar, "AI");
						
						// Create a STIMULUS record
						pr _stim = STIMULUS_NEW();
						STIMULUS_SET_SOURCE(_stim, T_GETV("group"));
						STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_TARGETS);
						STIMULUS_SET_VALUE(_stim, _observedTargets);
						
						// Broadcast data to all groups in this garrison
						/*
						// Now this data is being broadcasted from the garrison AI
						pr _groups = CALLM0(_gar, "getGroups");
						{
							// No sense to reveal your targets to yourself
							if (_x != _group) then {
								pr _groupAI = CALLM0(_x, "getAI");
								// Sanity check
								if (_groupAI != "") then {
									//diag_log format [" -- Revealing to: %1, %2", _x, GETV(_x, "data")];
									CALLM1(_groupAI, "handleStimulus", _stim);
								};
							};
						} forEach _groups;
						*/
						
						// Only send new data to the garrison if previous data has been processed
						pr _prevMsgID = T_GETV("prevMsgID");
						if (CALLM1(_garAI, "messageDone", _prevMsgID)) then {
							pr _msgID = CALLM3(_garAI, "postMethodAsync", "handleStimulus", [_stim], true);
							T_SETV("prevMsgID", _msgID);
							
							// If there is no location, poke the AIGarrison to do processing ASAP
							if (_loc == "" || _comTime < 20) then { // Send "process" to AIGarrison only when we have just switched into combat mode
								CALLM2(_garAI, "postMethodAsync", "process", []);
							};
						//} else {
						//	diag_log format [" ---- Previous stimulus has not been processed! MsgID: %1", _msgID];
						};
					};
				#ifdef DEBUG_SENSOR_GROUP_TARGETS
				} else { // if (_comTime > TARGET_TIME_RELAY) then {
					OOP_INFO_1("[SensorGroupTargets::Update] Info: Group %1 is in combat state but combat timer has not reached the threshold!", _hg);
				#endif
				};
				
				// Increment combat counter
				T_SETV("comTime", _comTime + UPDATE_INTERVAL);
			} else {
				// Reset combat counter
				T_SETV("comTime", 0);
			};
		#ifdef DEBUG_SENSOR_GROUP_TARGETS
		} else {
			OOP_INFO_3("--- Group: %1 is not alive! Group's units: %2, isNull: %3", _hG, units _hG, isNull _hG);
			pr _AI = T_GETV("AI");
			pr _agent = GETV(_AI, "agent");
			OOP_INFO_2(" Group data: %1 %2", _agent, GETV(_agent, "data"));
		#endif
		};
		
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD(getUpdateInterval)
		UPDATE_INTERVAL
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getStimulusTypes)
		[STIMULUS_TYPE_TARGETS, STIMULUS_TYPE_FORGET_TARGETS]
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		
		switch (STIMULUS_GET_TYPE(_stimulus)) do {
			
			// Receive targets from someone
			case STIMULUS_TYPE_TARGETS: {
				#ifdef PRINT_RECEIVED_TARGETS
					OOP_INFO_3("[SensorGroupTargets::handleStimulus] Info: %1 has received targets from %2: %3", T_GETV("group"), STIMULUS_GET_SOURCE(_stimulus), STIMULUS_GET_VALUE(_stimulus));
				#endif
				
				// Reveal targets to this group
				// Unpack data
				pr _data = STIMULUS_GET_VALUE(_stimulus);
				pr _hG = T_GETV("hG");
				{ // foreach _data
					// _x is a target structure
					pr _unit = _x select TARGET_ID_UNIT;
					CRITICAL_SECTION {
						if (IS_OOP_OBJECT(_unit)) then {
							pr _hO = CALLM0(_unit, "getObjectHandle");
							if (alive _hO) then {
								_hG reveal [_hO, _x select TARGET_ID_KNOWS_ABOUT];
							};
						};
					};
				} forEach _data;
			};
			
			// Forget about targets
			case STIMULUS_TYPE_FORGET_TARGETS: {
				pr _data = STIMULUS_GET_VALUE(_stimulus);
				
				#ifdef PRINT_RECEIVED_TARGETS
					OOP_INFO_2("[SensorGroupTargets::handleStimulus] Info: %1 is forgetting targets: %2", T_GETV("group"), _data);
				#endif
				
				pr _hG = T_GETV("hG");
				//pr _thisSide = side _hG;
				{ // foreach _data
					CRITICAL_SECTION {
						if (IS_OOP_OBJECT(_x)) then {
							pr _hO = CALLM0(_x, "getObjectHandle");
							_hG forgetTarget _hO;
						};
					};
				} forEach _data;
			};
		};
		

	ENDMETHOD;
	
ENDCLASS;