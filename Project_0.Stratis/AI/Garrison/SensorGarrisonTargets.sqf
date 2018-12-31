#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\stimulusTypes.hpp"
#include "..\commonStructs.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "garrisonWorldStateProperties.hpp"


/*
Sensor for a garrison to receive spotted enemies from its groups and relay them to other groups garrison.
Author: Sparker 21.12.2018
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 5

// Maximum age of target before it is deleted
#define TARGET_MAX_AGE 15

// ---- Debugging defines ----

// Will print to the RPT targets received from groups
//#define PRINT_RECEIVED_TARGETS

CLASS("SensorGarrisonTargets", "SensorGarrisonStimulatable")

	METHOD("new") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		// Loop throgh known targets and remove those who are older than some threshold
		pr _AI = GETV(_thisObject, "AI");
		pr _knownTargets = GETV(_AI, "targets");
		pr _targetsToForget = [];
		if (count _knownTargets > 0) then {
			pr _i = 0;
			pr _t = time;
			_targetsToForget = _knownTargets select {(_t - (_x select TARGET_ID_TIME)) > TARGET_MAX_AGE};
			_knownTargets = _knownTargets - _targetsToForget;
			SETV(_AI, "targets", _knownTargets);
		};
		
		diag_log format ["[SensorGarrisonTargets::update] Info: forgetting targets: %1", _targetsToForget];
		// Force groups to forget about old targets
		if (count _targetsToForget > 0) then {
			diag_log format ["--- --- [SensorGarrisonTargets::update] Info: forgetting targets: %1", _targetsToForget];
			// Create a new stimulus record
			pr _stim = STIMULUS_NEW();
			STIMULUS_SET_SOURCE(_stim, GETV(_thisObject, "gar"));
			STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_FORGET_TARGETS);
			STIMULUS_SET_VALUE(_stim, _targetsToForget);
			
			// Broadcast this stimulus to all groups in this garrison
			pr _gar = GETV(_thisObject, "gar");
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
		
			diag_log "Garrison is in combat now!";
		
			// Set property value
			[_ws, WSP_GAR_AWARE_OF_ENEMY, true] call ws_setPropertyValue;
			
			// Play the alarm sound
			pr _gar = GETV(_AI, "agent");
			pr _loc = CALLM0(_gar, "getLocation");
			pr _pos = CALLM0(_loc, "getPos");
			playSound3D ["A3\Sounds_F\sfx\alarm.wss", objNull, false, (AGLTOASL _pos) vectorAdd [0, 0, 5], 20, 1, 1000];
			
			
		} else {
			[_ws, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;
		};

	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD("getUpdateInterval") {
		UPDATE_INTERVAL
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[STIMULUS_TYPE_TARGETS]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD("handleStimulus") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
		
		#ifdef PRINT_RECEIVED_TARGETS
		diag_log format ["[SensorGarrisonTargets::handleStimulus] Info: %1 received targets from %2: %3",
			GETV(_thisObject, "gar"),
			STIMULUS_GET_SOURCE(_stimulus),
			STIMULUS_GET_VALUE(_stimulus)];
		#endif
		
		// Filter spotted enemies
		pr _AI = GETV(_thisObject, "AI");
		pr _knownTargets = GETV(_AI, "targets");
		{ // forEach (STIMULUS_GET_VALUE(_stimulus));
			// Check if the target is already known
			pr _hO = _x select TARGET_ID_OBJECT_HANDLE;
			pr _index = _knownTargets findIf {(_x select TARGET_ID_OBJECT_HANDLE) isEqualTo _hO};
			if (_index == -1) then {
				// Didn't find an existing entry
				
				// Add it to the array
				_knownTargets pushBack _x;
			} else {
				// Found an existing entry
				pr _targetExisting = _knownTargets select _index;
				
				// Check time the target was previously spotted
				pr _timeNew = _x select TARGET_ID_TIME;
				pr _timePrev = _targetExisting select TARGET_ID_TIME;
				// Is the new report newer than the old record?
				if (_timeNew > _timePrev) then {
					_targetExisting set [TARGET_ID_POS, _x select TARGET_ID_POS];
					_targetExisting set [TARGET_ID_TIME, _timeNew];
					_targetExisting set [TARGET_ID_KNOWS_ABOUT, TARGET_ID_KNOWS_ABOUT];
				};
			};
		} forEach (STIMULUS_GET_VALUE(_stimulus));
		
		//diag_log format [" - - - - - - Garrison: %1 Known targets: %2", _thisObject, _knownTargets];
		
		// Broadcast the stimulus to groups different from source group
		pr _groupSource = STIMULUS_GET_SOURCE(_stimulus); // The group that sent this stimulus
		pr _gar = GETV(_thisObject, "gar");
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
	} ENDMETHOD;
	
ENDCLASS;