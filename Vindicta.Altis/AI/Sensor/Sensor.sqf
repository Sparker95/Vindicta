#define PROFILER_COUNTERS_ENABLE
#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\stimulusTypes.hpp"

/*
Class: Sensor
It abstracts the abilities of an agent to receive information from the external world

Author: Sparker 08.11.2018
*/

#define pr private

#define OOP_CLASS_NAME Sensor
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
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		
		PROFILER_COUNTER_INC("Sensor");
		
		T_SETV("AI", _AI);
		T_SETV("timeNextUpdate", GAME_TIME+0.01); // Update this sensor ASAP, fix for sensors created at game start when GAME_TIME is zero
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD(delete)
		params [P_THISOBJECT];
		
		PROFILER_COUNTER_DEC("Sensor");
		
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(update)
		// Do nothing by default
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// | If it returns 0, the sensor will not be updated
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getUpdateInterval)
		//params [P_THISOBJECT];
		0
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getStimulusTypes)
		[]
	ENDMETHOD;
	
ENDCLASS;