/*
An atomic goal for a unit to interact with an animObject for some duration of time.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

CLASS("GoalUnitDoInteractAnimObject", "Goal")

	VARIABLE("animObject");
	VARIABLE("pointID");
	VARIABLE("animDuration");
	VARIABLE("animationOut");
	VARIABLE("walkOutDir");
	VARIABLE("walkOutDistance");
	VARIABLE("timeCompleted"); // The time when this goal will be completed
	VARIABLE("hScript"); // Handle to a script which will be spawned
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]], ["_animObject", "", [""]], ["_animDuration", 0, [0]], ["_pointID", 0, [0]]];
		SETV(_thisObject, "animObject", _animObject);
		SETV(_thisObject, "pointID", _pointID);
		SETV(_thisObject, "animDuration", _animDuration);
		SETV(_thisObject, "animationOut", ""); // Actual value will be retrieved on goal activation
		SETV(_thisObject, "timeCompleted", (time + _animDuration));
		SETV(_thisObject, "walkOutDir", 0);
		SETV(_thisObject, "walkOutDistance", 0); // 0 means no walking out from animation
		SETV(_thisObject, "hScript", scriptNull);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		// Normally terminate must be called before delete. However just in case it's not like this:
		// Terminate the script
		private _hScript = GETV(_thisObject, "hScript");
		if (!scriptDone _hScript) then { terminate _hScript; };
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        A C T I V A T E                             |
	// ----------------------------------------------------------------------

	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		// Get variables
		private _entity = GETV(_thisObject, "entity");
		private _entityObjectHandle = CALLM(_entity, "getObjectHandle", []);
		private _animObject = GETV(_thisObject, "animObject");
		private _pointID = GETV(_thisObject, "pointID");
		
		// Is the desired point still free?
		private _args = [_animObject, _pointID];
		private _pointData = CALLM(_animObject, "getPointData", _args); // pointData: ["_posOffset", "_dir", "_animation", "_animationOut"]
		if ( count _pointData > 0 ) then {
			// Parse point data
			_pointData params ["_posOffset", "_dir", "_animation", "_animationOut", "_walkOutDir", "_walkOutDistance"];
			
			// Store some data
			SETV(_thisObject, "walkOutDir", _walkOutDir);
			SETV(_thisObject, "walkOutDistance", _walkOutDistance);
			
			// Get object handle
			private _animObjectHandle = CALLM(_animObject, "getObject", []);
			
			// Convert model to world coordinates
			_dir = _dir + (direction _animObjectHandle);
			private _pos = _animObjectHandle modelToWorld _posOffset;
			SETV(_thisObject, "animationOut", _animationOut); // Store the animation out in case we need to terminate this goal
			
			// Play the actual animation
			_entityObjectHandle switchMove _animation;
			_entityObjectHandle disableAI "MOVE";
			_entityObjectHandle disableAI "ANIM";
			_entityObjectHandle setPos _pos;
			_entityObjectHandle setDir _dir;
			
			// Spawn a script to monitor the behaviour of this unit
			private _hScript = [_thisObject] spawn { 
				params ["_thisObject"];
				private _entity = GETV(_thisObject, "entity");
				private _objectHandle = CALLM(_entity, "getObjectHandle", []);
				
				waitUntil {sleep 0.05; (behaviour _objectHandle) == "COMBAT" || (!alive _objectHandle) };
				
				// Are you still OK?		
				if (alive _objectHandle) then {
					CALLM(_thisObject, "stopInteraction", []);
					
					// Send a message to the goal
					// If the unit was killed, the appropriate message will be sent by event handler
					private _msg = MESSAGE_NEW();
					_msg set [MESSAGE_ID_DESTINATION, _thisObject];
					_msg set [MESSAGE_ID_TYPE, GOAL_MESSAGE_ANIMATION_INTERRUPTED];
					CALLM(_thisObject, "postMessage", [_msg]);
				};		
		 	};
		 	SETV(_thisObject, "hScript", _hScript);
		 	
			
			//if (_animSuccessfull) then {
				// Set the time variable to terminate this goal when the time is out
				private _animDuration = GETV(_thisObject, "animDuration");
				SETV(_thisObject, "timeCompleted", (time + _animDuration));
				SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
				GOAL_STATE_ACTIVE
			//} else {
			//	SETV(_thisObject, "state", GOAL_STATE_FAILED);
			//	GOAL_STATE_FAILED
			//};
		} else {
			// Someone has occupied the desired point!
			SETV(_thisObject, "state", GOAL_STATE_FAILED);
			GOAL_STATE_FAILED
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          P R O C E S S                             |
	// ----------------------------------------------------------------------

	METHOD("process") {
		params [["_thisObject", "", [""]]];
		private _state = CALLM(_thisObject, "activateIfInactive", []);		
		
		if (_state != GOAL_STATE_FAILED) then {
			// Check if we have been playing the animation for enough time
			private _timeCompleted = GETV(_thisObject, "timeCompleted");
			if (time > _timeCompleted) then {
				SETV(_thisObject, "state", GOAL_STATE_COMPLETED);
				_state = GOAL_STATE_COMPLETED;
			} else {
				SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
				_state = GOAL_STATE_ACTIVE;
			};
		};
		
		_state
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        T E R M I N A T E                           |
	// ----------------------------------------------------------------------

	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Terminate the script
		private _hScript = GETV(_thisObject, "hScript");
		if (!scriptDone _hScript) then { terminate _hScript; };
		
		private _state = GETV(_thisObject, "state");
		if (_state == GOAL_STATE_ACTIVE || _state == GOAL_STATE_COMPLETED) then {
			CALLM(_thisObject, "stopInteraction", []);
			
			// Notify the animObject that this seat is now free
			private _animObject = GETV(_thisObject, "animObject");
			private _pointID = GETV(_thisObject, "pointID");
			CALLM(_animObject, "pointIsFree", [_pointID]);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      H A N D L E   M E S S A G E                   |
	// |                                                                    |
	// | This goal accepts only GOAL_MESSAGE_ANIMATION_INTERRUPTED message and base class messages
	// ----------------------------------------------------------------------
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _msgType = _msg select MESSAGE_ID_TYPE;
		
		private _msgHandled = false;
		if (_msgType == GOAL_MESSAGE_ANIMATION_INTERRUPTED) then {
			diag_log "------------- Animation was interrupted!";
			// The animation was interrupted, so we must set this goal to failed state
			SETV(_thisObject, "state", GOAL_STATE_FAILED);
			_msgHandled = true // message has been handled
		} else {
			// Pass message to handleMessage of the base class
			_msgHandled = CALL_CLASS_METHOD("Goal", "handleMessage", [_msg]);
		};
		_msgHandled
	} ENDMETHOD;
	
	// Methods for interacting with the unit object handle
	// ---------------------------------------------------------------------------
	//                           S T A R T   I N T E R A C T I O N
	//
	//  Plays the animations on an object handle
	// ---------------------------------------------------------------------------
	METHOD("startInteraction") {
		params [ ["_thisObject", "", [""]] ];
		private _entity = GETV(_thisObject, "entity");
		private _objectHandle = CALLM(_entity, "getObjectHandle");
		
		// Perform actions on this soldier
		_objectHandle switchMove _animation;
		_objectHandle disableAI "MOVE";
		_objectHandle disableAI "ANIM";
		_objectHandle setPos _pos;
		_objectHandle setDir _dir;
		
	} ENDMETHOD;
	
	// ---------------------------------------------------------------------------
	//                           S T O P   I N T E R A C T I O N
	//
	//  Stops the animation by playing another animation
	// ---------------------------------------------------------------------------
	STATIC_METHOD("stopInteraction") {
		params [ ["_thisObject", "", [""]] ];
		private _animationOut = GETV(_thisObject, "animationOut");
		
		// Switch animation, enable AI
		private _entity = GETV(_thisObject, "entity");
		private _objectHandle = CALLM(_entity, "getObjectHandle", []);
		_objectHandle enableAI "ALL";
		_objectHandle switchMove _animationOut;
		
		// Walk out if needed
		private _walkOutDistance = GETV(_thisObject, "walkOutDistance");
		if (_walkOutDistance > 0) then {
			private _walkOutDir = GETV(_thisObject, "walkOutDir");
			private _posMove = (getPos _objectHandle) getPos [_walkOutDistance, _walkOutDir];
			_objectHandle doMove _posMove;
		};
	} ENDMETHOD;

ENDCLASS;