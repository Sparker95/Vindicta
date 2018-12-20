#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\stimulusTypes.hpp"
#include "..\Garrison\AIGarrison.hpp"

/*
Sensor for a group to gather spotted enemies and relay them to the garrison.
*/

#define pr private

// Maximum age until target is going to be revealed
#define TARGET_AGE_TO_REVEAL 5

// Time until targets are relayed to garrison leader
#define TARGET_TIME_RELAY 4

// Update interval of this sensor
#define UPDATE_INTERVAL 5

CLASS("SensorGroupEnemy", "SensorGroup")

	VARIABLE("comTime"); // Counter that shows how long the group has been in combat state
	VARIABLE("lastMsgID"); // Message ID of the previous receiveTargets message, so that we don't oversaturate the garrison AI thread

	METHOD("new") {
		params [["_thisObject", "", [""]]];
		SETV(_thisObject, "comTime", 0);
	} ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		// Unpack the group handle
		pr _hG = GETV(_thisObject, "hG");
		
		diag_log "---- Update";
		
		pr _side = side _hG;
		if (({alive _x} count (units _hG)) > 0) then {
			if ((behaviour (leader _hG)) isEqualTo "COMBAT") then {
				// Find new enemies
				/*
				0 accuracy: Number - a coefficient, which reflects how close the returned result to the query filter. Range: 0 - 1 (1 - best match)
				1 target: Object - the actual target object
				2 targetSide: Side - side of the target
				3 targetType: String - target typeOf
				4 targetPosition: Array - [x,y] of the target
				5 targetAge: Number - the actual target age in seconds (can be negative)
				*/
				pr _observedTargets = [];
				pr _comTime = GETV(_thisObject, "comTime");
				if (_comTime > TARGET_TIME_RELAY) then {
					_nt = (leader _hG) targetsQuery [objNull, sideUnknown, "", [], 0/*TARGET_AGE_TO_REVEAL*/];
					{ //forEach _nt
						//private _s = _x select 2; //Perceived Side of the target						
						private _o = _x select 1;
						private _s = side _o;
						private _age = _x select 5; //Target age is the time that has passed since the last time the group has actually seen the enemy unit. Values lower than 0 mean that they see the enemy right now
						//diag_log format ["Age of target %1: %2", _x select 1, _age];
						if(_s != _side && (_s in [EAST, WEST, INDEPENDENT, sideUnknown]) && (_age <= TARGET_AGE_TO_REVEAL)) then { //If target's side is enemy
							// object handle, knows about, position, age
							_observedTargets pushBack TARGET_RECORD_NEW(_o, _hG knowsAbout (_x select 1),  _x select 4, _x select 5);
						};
					} forEach _nt;
					
					// Have we spotted anyone??
					if (count _observedTargets > 0) then {
						diag_log format ["---- Group: %1, targets: %2", _hg, _observedTargets];
						// Send targets to garrison AI
						// this->AI->agent->garrison->AI WTF??
						pr _AI = GETV(_thisObject, "AI");
						pr _agent = GETV(_AI, "agent");
						pr _gar = CALLM0(_agent, "getGarrison");
						_AI = GETV(_gar, "AI");
						
						// Only send new data if previous data has been processed
						if (CALLM1(_AI, "messageDone", _msgID)) then {
							pr _msgID = CALLM3(_AI, "postMethodAsync", "receiveTargets", _observedTargets, true);
							SETV(_thisObject, "msgID", _msgID);
						};
					};
				};
				
				// Increment combat counter
				SETV(_thisObject, "comTime", _comTime + UPDATE_INTERVAL);
			} else {
				// Reset combat counter
				SETV(_thisObject, "comTime", 0);
			};
		} else {
			diag_log format ["--- Group: %1 is not alive! Group's units: %2, isNull: %3", _hG, units _hG, isNull _hG];
			pr _AI = GETV(_thisObject, "AI");
			pr _agent = GETV(_AI, "agent");
			diag_log format [" Group data: %1 %2", _agent, GETV(_agent, "data")];
		};
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD("getUpdateInterval") {
		UPDATE_INTERVAL
	} ENDMETHOD;
	
ENDCLASS;