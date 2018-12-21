#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\stimulusTypes.hpp"
#include "..\commonStructs.hpp"
#include "..\Stimulus\Stimulus.hpp"


/*
Sensor for a garrison to receive spotted enemies from its groups and relay them to other groups garrison.
Author: Sparker 21.12.2018
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 5

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
	} ENDMETHOD;
	
ENDCLASS;