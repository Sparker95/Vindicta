/*
Stimulus Manager class.

Stimulus manager is a common object which gathers stimulus from one source and distributes it to multiple sensing AI objects
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"

#define pr private

CLASS("StimulusManager", "MessageReceiverEx")

	VARIABLE("sensingAIs"); // Array of AI objects which will be sensing stimulus
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
		ASSERT_GLOBAL_OBJECT(gMessageLoopStimulusManager);
		
		SETV(_thisObject, "sensingAIs", []);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	METHOD("getMessageLoop") { //Derived classes must implement this method if they need to receive messages
		gMessageLoopStimulusManager
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            P R O C E S S
	// ----------------------------------------------------------------------
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            H A N D L E   S T I M U L U S
	// | Handles a stimulus when it is created
	// ----------------------------------------------------------------------
	
	METHOD("handleStimulus") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
		
		diag_log format ["[StimulusManager:handleStimulus] stimulus: %1", _stimulus];
		
		pr _AIs = GETV(_thisObject, "sensingAIs");
		pr _type = _stimulus select STIMULUS_ID_TYPE;
		pr _pos = _stimulus select STIMULUS_ID_POS;
		{
			// Check if this AI can respond to this stimulus
			pr _AI = _x;
			
			pr _distance = 666666;
			pr _canSense = call {
				scopeName "s";
				
				// Check stimulus type
				pr _stimTypes = GETV(_AI, "sensorStimulusTypes");
				if (! (_type in _stimTypes)) exitWith {false};
				
				// Check stimulus range
				if ((_pos select 0) != 0) then { // If the source position is [0, 0, 0] then it is ignored
					pr _agent = GETV(_AI, "agent");
					pr _agentPos = CALLM(_agent, "getPos", []);
					_distance = _pos distance _agentPos;
					if (_distance > (_stimulus select STIMULUS_ID_RANGE)) then {false breakOut "s";};
				};
				
				true
			};
			
			if (_canSense) then {
				diag_log format ["[StimulusManager:handleStimulus] can be sensed by AI: %1, distance: %2", _AI, _distance];
				// Make the AI handle the stimulus
				pr _args = ["handleStimulus", [+_stimulus]];
				CALLM(_AI, "postMethodAsync", _args); // We call the method asynchronously because it is in another thread
			};
		} forEach _AIs;
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                 A D D   /   R E M O V E   S E N S I N G   A I
	// | Adds/removes the AI to the list of AIs handles by this stimulus manager
	// ----------------------------------------------------------------------
	
	METHOD("addSensingAI") {
		params [["_thisObject", "", [""]], ["_AI", "ERROR_NO_AI", [""]] ];
		pr _sensingAIs = GETV(_thisObject, "sensingAIs");
		_SensingAIs pushBackUnique _AI;
	} ENDMETHOD;
	
	METHOD("removeSensingAI") {
		params [["_thisObject", "", [""]], ["_AI", "ERROR_NO_AI", [""]] ];
		pr _sensingAIs = GETV(_thisObject, "sensingAIs");
		_sensingAIs deleteAt (_sensingAIs find _AI);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E   M E S S A G E
	// | 
	// ----------------------------------------------------------------------
	
	METHOD("handleMessageEx") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		pr _msgType = _msg select MESSAGE_ID_TYPE;
		switch (_msgType) do {
			default {false}; // Message not handled
		};
	} ENDMETHOD;
	
	

ENDCLASS;