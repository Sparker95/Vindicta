#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\stimulusTypes.hpp"

/*
Class: Sensor.SensorStimulatable
A stimulatable sensor class.

Author: Sparker 23.11.2018
*/

#define OOP_CLASS_NAME SensorStimulatable
CLASS("SensorStimulatable", "Sensor")
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD(new)
		params [P_THISOBJECT];
		
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD(delete)
		params [P_THISOBJECT];
		
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            S T I M U L A T E
	// ----------------------------------------------------------------------
	
	/* private */ METHOD(stimulate)
		params [P_THISOBJECT, P_ARRAY("_stimulus") ];
		
		// Do sensor-specific complex check
		if (! (T_CALLM("doComplexCheck", [_stimulus]))) exitWith {};
		
		// Create world fact
		T_CALLM("handleStimulus", [_stimulus]);
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getStimulusTypes)
		[]
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD(doComplexCheck)
		//params [P_THISOBJECT, P_ARRAY("_stimulus")];
		// Return true by default
		true				
	ENDMETHOD;

ENDCLASS;