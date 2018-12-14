#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

// Supposed to check player's suspiciousness

// We create a thread for player's suspiciousness monitor here
gMsgLoopSuspiciousness = NEW("MessageLoop", []);
CALL_METHOD(gMsgLoopSuspiciousness, "setDebugName", ["Suspiciousness thread"]);

#define pr private

CLASS("suspiciousnessMonitor", "MessageReceiver")

	VARIABLE("unit"); // Unit for which this script is running (player)
	VARIABLE("timer"); // Timer which will send SMON_MESSAGE_PROCESS message every second or so
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_unit", objNull, [objNull]]];
		SETV(_thisObject, "unit", _unit);
		_unit setVariable ["suspiciousnessMonitor", _thisObject]; // Later when you find that a group spots this unit, they can send the messages here
		
		// Create a timer
		private _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_PROCESS);
		pr _updateInterval = 1.0; // !!! Change your timer interval here !!!
		private _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		private _timer = NEW("Timer", _args);
		SETV(_thisObject, "timer", _timer);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		// Delete the timer
		pr _timer = GETV(_thisObject, "timer");
		DELETE(_timer);
		
	} ENDMETHOD;
	
	METHOD("getMessageLoop") {
		gMsgLoopSuspiciousness
	} ENDMETHOD;
	
	
	// handleMessage
	
	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		
		// Unpack the message
		pr _msgType = _msg select MESSAGE_ID_TYPE;
		
		switch (_msgType) do {
		
			// This will be called every time interval to run calculations
			case SMON_MESSAGE_PROCESS: {
				pr _unit = GETV(_thisObject, "unit");
				systemChat format ["Hello from suspiciousness monitor of unit %1! Current time: %2", _unit, time];
				/*
				Run your code here...
				*/
			};
			
			// This will be called when a player is being spotted, it is send from the other thread/computer
			case SMON_MESSAGE_BEING_SPOTTED: {
				// Unpack data
				pr _msgData = _msg select MESSAGE_ID_DATA;
				systemChat format ["I feel like I am being spotted by group %1! Current time: %2", _msgData, time];
			};
		};
		
		false // message not handled
	} ENDMETHOD;

ENDCLASS;