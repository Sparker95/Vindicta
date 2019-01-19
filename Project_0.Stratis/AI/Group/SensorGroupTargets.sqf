#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\stimulusTypes.hpp"
#include "..\commonStructs.hpp"
#include "..\Stimulus\Stimulus.hpp"


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

// ----- Debugging definitions -----

// Various debug outputs
//#define DEBUG

// Prints spotted enemies every update iteration, if the combat timer has reached treshold
//#define PRINT_SPOTTED_TARGETS

// Prints targets received through the stimulus
#define PRINT_RECEIVED_TARGETS

CLASS("SensorGroupTargets", "SensorGroupStimulatable")

	VARIABLE("comTime"); // Counter that shows how long the group has been in combat state
	VARIABLE("prevMsgID"); // Message ID of the previous receiveTargets message, so that we don't oversaturate the garrison AI thread

	METHOD("new") {
		params [["_thisObject", "", [""]]];
		SETV(_thisObject, "comTime", 0);
		SETV(_thisObject, "prevMsgID", -1); // First message ID is negative as it is always handled
	} ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		// Unpack the group handle
		pr _hG = GETV(_thisObject, "hG");
		
		#ifdef DEBUG
		diag_log format ["[SensorGroupTargets::Update] Info: %1", _thisObject];
		#endif
		
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
						if(_s != _side) then { //If target's side is enemy
							if ((_s in [EAST, WEST, INDEPENDENT, sideUnknown]) && (_age <= TARGET_AGE_TO_REVEAL)) then {
								// object handle, knows about, position, age
								_observedTargets pushBack TARGET_NEW(_o, _hG knowsAbout (_x select 1),  _x select 4, time-(_x select 5)+1); // Add 1 to age since its lowest value is -1
							};
						};
					} forEach _nt;
					
					// Have we spotted anyone??
					if (count _observedTargets > 0) then {
						#ifdef PRINT_SPOTTED_TARGETS
							diag_log format ["[SensorGroupTargets::Update] Info: GroupHandle: %1, targets: %2", _hg, _observedTargets];
						#endif
						// Send targets to garrison AI
						// this->AI->agent->garrison->AI WTF??
						pr _AI = GETV(_thisObject, "AI");
						pr _group = GETV(_AI, "agent");
						pr _gar = CALLM0(_group, "getGarrison");
						_AI = GETV(_gar, "AI");
						
						// Create a STIMULUS record
						pr _stim = STIMULUS_NEW();
						STIMULUS_SET_SOURCE(_stim, GETV(_thisObject, "group"));
						STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_TARGETS);
						STIMULUS_SET_VALUE(_stim, _observedTargets);
						
						// Broadcast data to all groups in this garrison
						/*
						// Now this data is being broadcasted from the garrison AI
						pr _groups = CALLM0(_gar, "getGroups");
						{
							// No sense to reveal your targets to yourself
							if (_x != _group) then {
								pr _groupAI = CALLM0(_x, "getAI");
								// Sanity check
								if (_groupAI != "") then {
									//diag_log format [" -- Revealing to: %1, %2", _x, GETV(_x, "data")];
									CALLM1(_groupAI, "handleStimulus", _stim);
								};
							};
						} forEach _groups;
						*/
						
						// Only send new data to the garrison if previous data has been processed
						pr _prevMsgID = GETV(_thisObject, "prevMsgID");
						if (CALLM1(_AI, "messageDone", _prevMsgID)) then {
							pr _msgID = CALLM3(_AI, "postMethodAsync", "handleStimulus", [_stim], true);
							SETV(_thisObject, "prevMsgID", _msgID);
						//} else {
						//	diag_log format [" ---- Previous stimulus has not been processed! MsgID: %1", _msgID];
						};
					};
				#ifdef DEBUG
				} else { // if (_comTime > TARGET_TIME_RELAY) then {
					diag_log format ["[SensorGroupTargets::Update] Info: Group %1 is in combat state but combat timer has not reached the threshold!", _hg];
				#endif
				};
				
				// Increment combat counter
				SETV(_thisObject, "comTime", _comTime + UPDATE_INTERVAL);
			} else {
				// Reset combat counter
				SETV(_thisObject, "comTime", 0);
			};
		#ifdef DEBUG
		} else {
			diag_log format ["--- Group: %1 is not alive! Group's units: %2, isNull: %3", _hG, units _hG, isNull _hG];
			pr _AI = GETV(_thisObject, "AI");
			pr _agent = GETV(_AI, "agent");
			diag_log format [" Group data: %1 %2", _agent, GETV(_agent, "data")];
		#endif
		};
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD("getUpdateInterval") {
		UPDATE_INTERVAL
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[STIMULUS_TYPE_TARGETS, STIMULUS_TYPE_FORGET_TARGETS]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD("handleStimulus") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
		
		switch (STIMULUS_GET_TYPE(_stimulus)) do {
			
			// Receive targets from someone
			case STIMULUS_TYPE_TARGETS: {
				#ifdef PRINT_RECEIVED_TARGETS
					diag_log format ["[SensorGroupTargets::handleStimulus] Info: %1 has received targets from %2: %3",
					GETV(_thisObject, "group"),
					STIMULUS_GET_SOURCE(_stimulus),
					STIMULUS_GET_VALUE(_stimulus)];
				#endif
				
				// Reveal targets to this group
				// Unpack data
				pr _data = STIMULUS_GET_VALUE(_stimulus);
				pr _hG = GETV(_thisObject, "hG");
				{ // foreach _data
					// _x is a target structure
					_hG reveal [_x select TARGET_ID_OBJECT_HANDLE, _x select TARGET_ID_KNOWS_ABOUT];
				} forEach _data;
			};
			
			// Forget about targets
			case STIMULUS_TYPE_FORGET_TARGETS: {
				pr _data = STIMULUS_GET_VALUE(_stimulus);
				
				#ifdef PRINT_RECEIVED_TARGETS
					diag_log format ["[SensorGroupTargets::handleStimulus] Info: %1 is forgetting targets: %2",
					GETV(_thisObject, "group"),
					_data];
				#endif
				
				pr _hG = GETV(_thisObject, "hG");
				{ // foreach _data
					// _x is a target structure
					_hG forgetTarget (_x select TARGET_ID_OBJECT_HANDLE);
				} forEach _data;
			};
		};
		

	} ENDMETHOD;
	
ENDCLASS;