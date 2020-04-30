#include "common.hpp"

/*
This sensor gets stimulated when someone salutes to this unit
*/

#define pr private

#define OOP_CLASS_NAME SensorUnitSalute
CLASS("SensorUnitSalute", "SensorStimulatable")

	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD(doComplexCheck)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		pr _AI = T_GETV("AI");
		pr _agent = GETV(_AI, "agent");
		pr _oh = CALLM0(_agent, "getObjectHandle");
		
		// Make sure we are not in combat
		if(behaviour _oh == "COMBAT") exitWith {false};
		
		// Make sure we have not been saluted by an enemy
		pr _src = STIMULUS_GET_SOURCE(_stimulus);
		if (!(side _src isEqualTo side _oh)) exitWith {false};
		
		true
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           C R E A T E   W O R L D   F A C T
	// | Creates a world fact specific to this sensor
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD(handleStimulus)
		params [P_THISOBJECT];
		pr _AI = T_GETV("AI");
		
		// Don't create a new fact if there is one already
		pr _wf = WF_NEW();
		[_wf, WF_TYPE_UNIT_SALUTED_BY] call wf_fnc_setType;
		pr _wfFound = CALLM(_AI, "findWorldFact", [_wf]);
		if (isNil "_wfFound") then {
			diag_log format ["[SensorUnitSalute:handleStimulus] Sensor: %1, created world fact", _thisObject];
			
			// Create a world fact
			[_wf, STIMULUS_GET_SOURCE(_stimulus)] call wf_fnc_setSource;
			[_wf, 3] call wf_fnc_setLifetime;
			[_wf, 1] call wf_fnc_setRelevance;
			CALLM(_AI, "addWorldFact", [_wf]);
		};
		
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getStimulusTypes)
		[STIMULUS_TYPE_UNIT_SALUTE]
	ENDMETHOD;

ENDCLASS;