/*
A stimulatable sensor class.

Author: Sparker 23.11.2018
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\stimulusTypes.hpp"

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
	
	METHOD("stimulate") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]] ];
		
		// Check distance
		
		// Do sensor-specific complex check
		if (! (CALLM(_thisObject, "doComplexCheck", []))) exitWith {};
		
		// Create world fact
		CALLM(_thisObject, "createWorldFact", []);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           C R E A T E   W O R L D   F A C T
	// | Creates a world fact specific to this sensor
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD("createWorldFact") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD("doComplexCheck") {
		params [["_thisObject", "", [""]], ["_AI", "ERROR_NO_AI", [""]]];
		// Return true by default
		true				
	} ENDMETHOD;

ENDCLASS;