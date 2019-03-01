#define PROFILER_COUNTERS_ENABLE
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\stimulusTypes.hpp"

/*
Class: Sensor
It abstracts the abilities of an agent to receive information from the external world

Author: Sparker 08.11.2018
*/

#define pr private

CLASS("Sensor", "")

	VARIABLE("AI"); // Pointer to the unit which holds this AI object
	//STATIC_VARIABLE("stimulusType"); // Holds the type of the stimulus this sensor can be stimulated by
	VARIABLE("timeNextUpdate");
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	/*
	Method: new
	
	Parameters: _AI
	
	_AI - <AI> - derived object this sensor is attached to
	*/
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]]];
		
		PROFILER_COUNTER_INC("Sensor");
		
		SETV(_thisObject, "AI", _AI);
		SETV(_thisObject, "timeNextUpdate", time+0.01); // Update this sensor ASAP, fir for sensors created at time start
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		PROFILER_COUNTER_DEC("Sensor");
		
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		// Do nothing by default
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// | If it returns 0, the sensor will not be updated
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getUpdateInterval") {
		//params [ ["_thisObject", "", [""]]];
		0
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[]
	} ENDMETHOD;	
	
ENDCLASS;