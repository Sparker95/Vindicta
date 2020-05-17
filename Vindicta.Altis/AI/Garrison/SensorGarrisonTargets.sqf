#include "common.hpp"

/*
Sensor for a garrison to receive spotted enemies from its groups and relay them to other groups of this garrison.
Author: Sparker 21.12.2018
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 5

// Maximum age of target before it is deleted
// note that it must be lower than 60 !
#define TARGET_MAX_AGE_MINUTES 2

// ---- Debugging defines ----

// Will print to the RPT targets received from groups
//#define PRINT_RECEIVED_TARGETS

#define OOP_CLASS_NAME SensorGarrisonTargets
CLASS("SensorGarrisonTargets", "SensorGarrisonStimulatable")

	METHOD(new)
		params [P_THISOBJECT];
	ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ 
	METHOD(update)
		params [P_THISOBJECT];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		// Loop through known targets and remove those who are older than some threshold or not alive any more
		pr _AI = T_GETV("AI");
		pr _knownTargets = GETV(_AI, "targets");
		pr _targetsToForget = [];
		if (count _knownTargets > 0) then {
			pr _i = 0;
			pr _dateNumber = dateToNumber date;
			pr _dateNumberThreshold = dateToNumber [date#0,1,1,0,TARGET_MAX_AGE_MINUTES];
			while {_i < count _knownTargets} do {
				pr _target = _knownTargets select _i;
				if ( ((_dateNumber - (_target select TARGET_ID_DATE_NUMBER)) > _dateNumberThreshold) // || 
						/* (!alive (_target select TARGET_ID_UNIT) */ )   then { // todo need to solve how to make us forget destroyed targets
					_knownTargets deleteAt _i;
					_targetsToForget pushBack _target;
				} else {
					_i = _i + 1;
				};
			};
		};
		
		// Force groups to forget about old targets
		if (count _targetsToForget > 0) then {
			//diag_log format ["--- --- [SensorGarrisonTargets::update] Info: forgetting targets: %1", _targetsToForget];
			// Create a new stimulus record
			pr _stim = STIMULUS_NEW();
			STIMULUS_SET_SOURCE(_stim, T_GETV("gar"));
			STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_FORGET_TARGETS);
			STIMULUS_SET_VALUE(_stim, _targetsToForget apply {_x select TARGET_ID_UNIT});
			
			// Broadcast this stimulus to all groups in this garrison
			pr _gar = T_GETV("gar");
			pr _groups = CALLM0(_gar, "getGroups");
			{
				pr _groupAI = CALLM0(_x, "getAI");
				if (_groupAI != "") then {
					CALLM2(_groupAI, "postMethodAsync", "handleStimulus", [_stim]);
				}
			} forEach _groups;
		};


		
		// Set the world state property
		// Are we aware of any targets?
		pr _ws = GETV(_AI, "worldState");
		if (count _knownTargets > 0) then {
		
			//diag_log "Garrison is in combat now!";
		
			// Set property value
			[_ws, WSP_GAR_AWARE_OF_ENEMY, true] call ws_setPropertyValue;
			
			// Play the alarm sound
			pr _gar = GETV(_AI, "agent");
			pr _loc = CALLM0(_gar, "getLocation");
			// alarm goes for 6 seconds (3 cycles) every 18 seconds
			if (_loc != NULL_OBJECT && {!CALLM0(_loc, "isAlarmDisabled")} && { ((GAME_TIME / 2) % 5) < 1 }) then {
				pr _pos = CALLM0(_loc, "getPos");
				playSound3D ["A3\Sounds_F\sfx\Alarm_OPFOR.wss", objNull, false, (AGLTOASL _pos) vectorAdd [0, 0, 5], 0.5, 0.8, 800];
			};
		} else {
			[_ws, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;
		};
		
		// Send targets to commander
		if (count _knownTargets > 0) then {
			pr _gar = T_GETV("gar");
			pr _side = CALLM0(_gar, "getSide");
			pr _commanderAI = CALL_STATIC_METHOD("AICommander", "getAICommander", [_side]);
			// Create stimulus
			pr _stim = STIMULUS_NEW();
			STIMULUS_SET_SOURCE(_stim, _gar);
			STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_TARGETS);
			STIMULUS_SET_VALUE(_stim, +_knownTargets);
			CALLM2(_commanderAI, "postMethodAsync", "handleStimulus", [_stim]);
		};

		// Check if we can see any of the assigned targets
		pr _assignedTargetsRadius = GETV(_AI, "assignedTargetsRadius");
		// pr _assignedTargetsPos = GETV(_AI, "assignedTargetsPos");
		if (//count _knownTargets > 0 || 
			_assignedTargetsRadius != 0 && 
			{ GETV(_AI, "assignedTargetsPos") distance2D CALLM0(_AI, "getPos") < MAXIMUM(750, _assignedTargetsRadius + 500) }
		/*&& (count _knownTargets) > 0*/) then {
			/*
			pr _assignedTargetsPos = GETV(_AI, "assignedTargetsPos");
			pr _targetsInRadius = _knownTargets select {
				pr _hO = _x select TARGET_ID_UNIT;
				(_hO distance2D _assignedTargetsPos) < _assignedTargetsRadius
			};
			SETV(_AI, "assignedTargets", _targetsInRadius);
			SETV(_AI, "awareOfAssignedTargets", count _targetsInRadius > 0);
			*/
			SETV(_AI, "awareOfAssignedTargets", true);
		} else {
			SETV(_AI, "awareOfAssignedTargets", false);
		};
		
		// Update the array of buildings with targets
		pr _buildings = [];
		{ // forEach _knownTargets
			pr _pos = +(_x#TARGET_ID_POS);
			_pos resize 3;
			_pos set [2, 0];
			pr _posASL = AGLToASL _pos;
			pr _posASLStart = _posASL vectorAdd [0, 0, 100];
			pr _posASLEnd = _posASL vectorAdd [0, 0, -100];
			pr _objs = (lineIntersectsObjs [_posASLStart, _posASLEnd, objNull, objNull, false, 16 + 32]) select {
				(_x isKindOf "House") && (! ( (_x buildingPos 0) isEqualTo [0, 0, 0] ) )
			}; // We need only enterable houses
			_buildings append _objs;
		} forEach _knownTargets;
		_buildings = _buildings arrayIntersect _buildings;
		SETV(_AI, "buildingsWithTargets", _buildings);

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
	
	/* virtual */ 
	METHOD(getStimulusTypes)
		[STIMULUS_TYPE_TARGETS]
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	/*virtual*/ 
	METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		
		pr _type = STIMULUS_GET_TYPE(_stimulus);
		
		#ifdef PRINT_RECEIVED_TARGETS
		diag_log format ["[SensorGarrisonTargets::handleStimulus] Info: %1 received targets from %2: %3",
			T_GETV("gar"),
			STIMULUS_GET_SOURCE(_stimulus),
			STIMULUS_GET_VALUE(_stimulus)];
		#endif
		
		// Filter spotted enemies
		pr _AI = T_GETV("AI");
		pr _knownTargets = GETV(_AI, "targets");
		{ // forEach (STIMULUS_GET_VALUE(_stimulus));
			// Check if the target is already known
			pr _unit = _x select TARGET_ID_UNIT;
			//if (!IS_NULL_OBJECT(_unit))) then {
				pr _index = _knownTargets findIf {(_x select TARGET_ID_UNIT) isEqualTo _unit};
				if (_index == -1) then {
					// Didn't find an existing entry
					
					// Add it to the array
					_knownTargets pushBack _x;
				} else {
					// Found an existing entry
					pr _targetExisting = _knownTargets select _index;
					
					// Check time the target was previously spotted
					pr _dateNumberNew = _x select TARGET_ID_DATE_NUMBER;
					pr _dateNumberPrev = _targetExisting select TARGET_ID_DATE_NUMBER;
					// Is the new report newer than the old record?
					if (_dateNumberNew > _dateNumberPrev) then {
						_targetExisting set [TARGET_ID_POS, _x select TARGET_ID_POS];
						_targetExisting set [TARGET_ID_DATE_NUMBER, _dateNumberNew];
						_targetExisting set [TARGET_ID_KNOWS_ABOUT, TARGET_ID_KNOWS_ABOUT];
					};
				};
			//};
		} forEach (STIMULUS_GET_VALUE(_stimulus));
		
		//diag_log format [" - - - - - - Garrison: %1 Known targets: %2", _thisObject, _knownTargets];
		
		// Broadcast the stimulus to groups different from source group
		pr _groupSource = STIMULUS_GET_SOURCE(_stimulus); // The group (or other sensor!) that sent this stimulus
		pr _gar = T_GETV("gar");
		pr _groups = CALLM0(_gar, "getGroups");
		//ade_dumpCallstack;
		{
			pr _groupAI = CALLM0(_x, "getAI");
			if (_groupAI != "") then {
				CALLM2(_groupAI, "postMethodAsync", "handleStimulus", [_stimulus]);
			}
		} forEach (_groups - [_groupSource]);
		
		// Set the world state property
		// This garrison is now aware of enemies
		pr _ws = GETV(_AI, "worldState");
		[_ws, WSP_GAR_AWARE_OF_ENEMY, true] call ws_setPropertyValue;
		
	ENDMETHOD;
	
ENDCLASS;
