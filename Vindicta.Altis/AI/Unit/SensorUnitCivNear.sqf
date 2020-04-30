#include "common.hpp"

/*
This sensor gets stimulated when someone salutes to this unit
*/

#define pr private

#define OOP_CLASS_NAME SensorUnitCivNear
CLASS("SensorUnitCivNear", "SensorStimulatable")

	VARIABLE("timeAnnoyed");

	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD(doComplexCheck)
		params [P_THISOBJECT, P_ARRAY("_stimulus") ];
		
		
		//pr _AI = T_GETV("AI");
		//pr _agent = GETV(_AI, "agent");
		//pr _oh = CALLM0(_agent, "getObjectHandle");
		
		// Make sure we are not in combat
		//if(behaviour _oh == "COMBAT") exitWith {false}; //TODO check if we need to filter out some things here
		
		// Make sure its not a friendly, NOT needed as we check this already when we create the stimulus
		//pr _src = STIMULUS_GET_SOURCE(_stimulus);
		//if ((side _src isEqualTo side _oh)) exitWith {false};
		
		true
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Creates a world fact specific to this sensor
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD(handleStimulus)
		params [P_THISOBJECT,["_stimulus",[],[[]] ] ];
		pr _AI = T_GETV("AI");
		pr _value = STIMULUS_GET_VALUE(_stimulus);
		diag_log "handleStimulus";
		// Don't create a new fact if there is one already
		pr _wf = WF_NEW();
		[_wf, WF_TYPE_UNIT_ANNOYED_BY] call wf_fnc_setType;
		
		pr _wfFound = CALLM(_AI, "findWorldFact", [_wf]);
		if (isNil "_wfFound") then {
			diag_log format ["[SensorUnitCivNear:handleStimulus] Sensor: %1, created world fact", _thisObject];
			
			T_SETV("timeAnnoyed",0); //reset timer
			
			// Create a world fact
			[_wf, 3] call wf_fnc_setLifetime;
			[_wf, player] call wf_fnc_setSource;
			[_wf, _value] call wf_fnc_setRelevance;
			CALLM(_AI, "addWorldFact", [_wf]);
			
		}else{
			pr _timeAnnoyed = GETV(_thisObject,"timeAnnoyed") + 0.05; //reset timer
			T_SETV("timeAnnoyed",_timeAnnoyed);
			
			//update relevance
			[_wfFound,_timeAnnoyed +  _value]call wf_fnc_setRelevance;
			diag_log "wf_fnc_resetLastUpdateTime";
			//reset timer because civ didnt walk away
			[_wfFound] call wf_fnc_resetLastUpdateTime;
		};

		
		
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getStimulusTypes)
		[STIMULUS_TYPE_UNIT_CIV_NEAR]
	ENDMETHOD;

ENDCLASS;