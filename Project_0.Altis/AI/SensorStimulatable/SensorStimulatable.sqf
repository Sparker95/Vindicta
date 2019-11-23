#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\stimulusTypes.hpp"

/*
Class: Sensor.SensorStimulatable
A stimulatable sensor class.

Author: Sparker 23.11.2018
*/

CLASS("SensorStimulatable", "Sensor")
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            S T I M U L A T E
	// ----------------------------------------------------------------------
	
	/* private */ METHOD("stimulate") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]] ];
		
		// Do sensor-specific complex check
		if (! (CALLM(_thisObject, "doComplexCheck", [_stimulus]))) exitWith {};
		
		// Create world fact
		CALLM(_thisObject, "handleStimulus", [_stimulus]);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD("handleStimulus") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD("doComplexCheck") {
		//params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
		// Return true by default
		true				
	} ENDMETHOD;

ENDCLASS;