#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

// Supposed to check groups that see player

// We create a thread for player's undercover monitor here
gMsgLoopGroupMonitor = NEW("MessageLoop", []);
CALL_METHOD(gMsgLoopGroupMonitor, "setDebugName", ["Group monitor thread"]);

#define pr private

CLASS("groupMonitor", "MessageReceiver")

	VARIABLE("side"); // We store the side here
	VARIABLE("timer"); // Timer which will send a message every second or so
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]]];
		SETV(_thisObject, "side", _side);
		
		// Create a timer
		private _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, GROUP_MONITOR_MESSAGE_PROCESS);
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
		gMsgLoopGroupMonitor
	} ENDMETHOD;
	
	
	// handleMessage
	
	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		
		// Unpack the message
		pr _msgType = _msg select MESSAGE_ID_TYPE;
		
		switch (_msgType) do {
		
			// This will be called every time interval to run calculations
			case GROUP_MONITOR_MESSAGE_PROCESS: {								
				/*
				Run your code here...
				*/
				pr _side = GETV(_thisObject, "side");
				//systemChat format ["This is the group monitor of %1 side! Current time: %2", _side, time];
				
				// Run basic checks...
				pr _groups = allGroups select {(side _x) == _side};
				
				{ // foreach allPlayers
					pr _playerUnit = _x;
					_groups = _groups select {((leader _x) distance _playerUnit) < 1200};
					pr _found = _groups findIf {(_x knowsAbout _playerUnit) > 0.5};	// Returns -1 if nothing found
					pr _foundVeh = _groups findIf {(_x knowsAbout vehicle _playerUnit) > 0.5};

					if (_found != -1 or _foundVeh != -1) then {
						// Send a message to the player
						pr _msg = MESSAGE_NEW();

						if (_foundVeh != -1) then {
						MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_BEING_SPOTTED);
						MESSAGE_SET_DATA(_msg, _groups select _foundVeh); // You can pass any data you like }
						};
						
						if (_found != -1) then {
						MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_BEING_SPOTTED);
						MESSAGE_SET_DATA(_msg, _groups select _found); // You can pass any data you like
						};
						// Get undercover monitor of this unit
						pr _sm = _playerUnit getVariable "undercoverMonitor";
						
						// Send the message
						CALL_METHOD(_sm, "postMessage", [_msg]);
					};					
				} foreach allPlayers;
			};
		};
		
		false // message not handled
	} ENDMETHOD;

ENDCLASS;