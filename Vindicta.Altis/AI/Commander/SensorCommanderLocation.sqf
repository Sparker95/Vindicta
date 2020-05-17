#include "common.hpp"

/*
Sensor for commander that receives data about composition of a location.
Author: Sparker 01.02.2019
*/

#define pr private

// Update interval of this sensor
// 0 means it is never updated
#define UPDATE_INTERVAL 0

#define OOP_CLASS_NAME SensorCommanderLocation
CLASS("SensorCommanderLocation", "SensorStimulatable")

	METHOD(new)
		params [P_THISOBJECT];
	ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(update)
		params [P_THISOBJECT];
		
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
	
	METHOD(getStimulusTypes)
		[STIMULUS_TYPE_LOCATION]
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		
		OOP_INFO_1("Received location data: %1", _stimulus);
		pr _AI = T_GETV("AI");
		CALLM2(_AI, "updateLocationData", _stimulus select STIMULUS_ID_VALUE, CLD_UPDATE_LEVEL_UNITS); // stimulus value is location
	ENDMETHOD;
	
ENDCLASS;