#include "common.hpp"

/*
This sensor receives data from SensorGarrisonCasualties.
On receiving data, it tries to match killer to an existing target in the target cluster database, and adds the 'score' to the target cluster.
*/

#define pr private

// 0 means that it is never updated
#define UPDATE_INTERVAL 0

CLASS("SensorCommanderCasualties", "SensorStimulatable")

	/*
	METHOD("new") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	*/
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	METHOD("handleStimulus") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
		
		pr _AI = T_GETV("AI");
		pr _targetClusters = GETV(_AI, "targetClusters");
		
		// Try to match killers of all destroyed units to clusters
		pr _value = STIMULUS_GET_VALUE(_stimulus);
		pr _src = STIMULUS_GET_SOURCE(_stimulus);
		
		OOP_INFO_2("Received casualties: %1, from: %2", _value, _src);
		
		{ // for each casualties
			_x params ["_catID", "_subcatID", "_hOKiller"];
			if (!isNull _hOKiller) then {
				pr _eff = T_efficiency select _catID select _subcatID;
				{ // for each target clusters
					pr _TC = _x;
					pr _targets = _TC select TARGET_CLUSTER_ID_CLUSTER select CLUSTER_ID_OBJECTS; // Array with TARGET_COMMANDER structures
					// If the target was found in this cluster
					if ( _targets findIf {_hOKiller isEqualTo (_x select TARGET_COMMANDER_ID_OBJECT_HANDLE)} != -1 ) exitWith {
						// The damage caused by this cluster gets increased by _eff
						pr _dmg = _TC select TARGET_CLUSTER_ID_CAUSED_DAMAGE;
						_TC set [TARGET_CLUSTER_ID_CAUSED_DAMAGE, VECTOR_ADD_9(_dmg, _eff)];
						
						OOP_INFO_0("Killer was found in target cluster");
					};
				} forEach _targetClusters;
			};
		} forEach _value;
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[STIMULUS_TYPE_UNITS_DESTROYED]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// | If it returns 0, the sensor will not be updated
	// ----------------------------------------------------------------------
	
	METHOD("getUpdateInterval") {
		UPDATE_INTERVAL
	} ENDMETHOD;

ENDCLASS;