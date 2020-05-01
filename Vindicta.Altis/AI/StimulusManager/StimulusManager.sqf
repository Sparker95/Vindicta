#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "ai.rpt"
#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\Stimulus\Stimulus.hpp"

/*
Class: StimulusManager

Stimulus manager is a common object which gathers stimulus from one source and distributes it to multiple sensing AI objects
*/

#define pr private

#define OOP_CLASS_NAME StimulusManager
CLASS("StimulusManager", "MessageReceiverEx")

	VARIABLE("sensingAIs"); // Array of AI objects which will be sensing stimulus
	VARIABLE("msgLoop");
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_msgLoop")];
	
		T_SETV("msgLoop", _msgLoop);
		T_SETV("sensingAIs", []);
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD(delete)
		params [P_THISOBJECT];
		
	ENDMETHOD;
	
	METHOD(getMessageLoop) //Derived classes must implement this method if they need to receive messages
		T_GETV("msgLoop");
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            P R O C E S S
	// ----------------------------------------------------------------------
	
	METHOD(process)
		params [P_THISOBJECT];
		
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            H A N D L E   S T I M U L U S
	// | Handles a stimulus when it is created
	// ----------------------------------------------------------------------
	
	METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		
		OOP_INFO_1("Handle stimulus: %1", _stimulus);
		
		pr _AIs = T_GETV("sensingAIs");
		pr _type = _stimulus select STIMULUS_ID_TYPE;
		pr _pos = _stimulus select STIMULUS_ID_POS;
		pr _sidesInclude = _stimulus select STIMULUS_ID_SIDES_INCLUDE;
		{
			// Check if this AI can respond to this stimulus
			pr _AI = _x;
			
			pr _distance = 666666;
			pr _canSense = call {
				scopeName "sCheck";
				
				pr _agent = GETV(_AI, "agent");

				// Check stimulus type
				pr _stimTypes = GETV(_AI, "sensorStimulusTypes");
				if (! (_type in _stimTypes)) exitWith {false};
				
				// Check stimulus range
				if ((_pos select 0) != 0) then { // If the source position is [0, 0, 0] then it is ignored
					pr _agentPos = CALLM0(_agent, "getPos");
					_distance = _pos distance _agentPos;
					if (_distance > (_stimulus select STIMULUS_ID_RANGE)) then {false breakOut "sCheck";};
				};

				// Check agent's side
				if (count _sidesInclude > 0) then { // If an empty array, ignore it
					pr _agentSide = CALLM0(_agent, "getSide");
					if (!(_agentSide in _sidesInclude)) then {false breakOut "sCheck";};
				};
				
				true
			};
			
			if (_canSense) then {
				OOP_INFO_2("[StimulusManager:handleStimulus] can be sensed by AI: %1, distance: %2", _AI, _distance);
				// Make the AI handle the stimulus
				//CALLM2(_AI, "postMethodAsync", "handleStimulus", [_stimulus]); // We call the method asynchronously because it is in another thread
				CALLM1(_AI, "handleStimulus", _stimulus);
			};
		} forEach _AIs;
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                 A D D   /   R E M O V E   S E N S I N G   A I
	// | Adds/removes the AI to the list of AIs handles by this stimulus manager
	// ----------------------------------------------------------------------
	
	METHOD(addSensingAI)
		params [P_THISOBJECT, ["_AI", "ERROR_NO_AI", [""]] ];
		pr _sensingAIs = T_GETV("sensingAIs");
		_SensingAIs pushBackUnique _AI;
	ENDMETHOD;
	
	METHOD(removeSensingAI)
		params [P_THISOBJECT, ["_AI", "ERROR_NO_AI", [""]] ];
		pr _sensingAIs = T_GETV("sensingAIs");
		pr _ID = _sensingAIs find _AI;
		if (_ID != -1) then {
			_sensingAIs deleteAt _ID;
		};
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E   M E S S A G E
	// | 
	// ----------------------------------------------------------------------
	
	METHOD(handleMessageEx) //Derived classes must implement this method
		params [P_THISOBJECT, P_ARRAY("_msg") ];
		pr _msgType = _msg select MESSAGE_ID_TYPE;
		switch (_msgType) do {
			default {false}; // Message not handled
		};
	ENDMETHOD;
	
	

ENDCLASS;