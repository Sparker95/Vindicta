#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Template of an Action class
*/

#define pr private

CLASS("ActionUnitMoveToDanger", "Action")
	
	VARIABLE("target");
	VARIABLE("objectHandle");
	VARIABLE("stateTimer");
	VARIABLE("stateMachine");
	VARIABLE("stateChanged");
	VARIABLE("spawnHandle");
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_target", objNull, [objNull]] ];
		SETV(_thisObject, "target", _target);
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _oh = CALLM(_a, "getObjectHandle", []);
		SETV(_thisObject, "objectHandle", _oh);
		
		
		//FSM
		SETV(_thisObject, "stateChanged", true);
		SETV(_thisObject, "stateMachine", 0);
		
		SETV(_thisObject,"spawnHandle",scriptNull);

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		pr _oh = GETV(_thisObject, "objectHandle");
		pr _target = GETV(_thisObject, "target");
		
		diag_log format ["stateMachine %1",GETV(_thisObject, "stateMachine")];
		pr _state = ACTION_STATE_ACTIVE;
		scopename "switch";
		switch (GETV(_thisObject, "stateMachine")) do {
			//follow/move to
			case 0: {
				
				if (GETV(_thisObject, "stateChanged")) then {
					diag_log "START STATE 0";
					SETV(_thisObject, "stateChanged",false);
					
					SETV(_thisObject,"stateTimer",time);		
					
					_oh dotarget _target;
					
					pr _handle = [_target,_oh] spawn {
						params["_target","_oh"];
						waitUntil{
							_pos = (eyeDirection _target vectorMultiply 1.6) vectorAdd getpos _target;
							_oh doMove _pos;
							_oh doWatch _target;
							_pos_disarm = getpos _target;
							sleep 0.5;
							
							
							
							(_pos_disarm distance (getpos _target))<0.1 && {_pos distance getpos _oh < 1.5};
						};
					};
					SETV(_thisObject, "spawnHandle", _handle);
				}else{
					if (time - GETV(_thisObject,"stateTimer") > 10)then{//been following for 10 secs
						_state = ACTION_STATE_FAILED;
					
						CALLM(_thisObject, "terminate", []);
						diag_log "ACTION_STATE_FAILED";
						Hint "Im tired";
						breakTo "switch";
					}else{
						hint "STOP RUNNING";
					};
				};
				
				if (scriptDone GETV(_thisObject, "spawnHandle")) then {
					diag_log "stateMachine 0 Done" ;
					SETV(_thisObject, "stateChanged", true);
					SETV(_thisObject, "stateMachine", 1);
					
					diag_log format ["stateMachine changed %1",GETV(_thisObject, "stateMachine")];
				};
			};
			
			//follow close
			case 1: {
				if (GETV(_thisObject, "stateChanged")) then {
					diag_log "stateMachine 1" ;
					SETV(_thisObject, "stateChanged",false);
					SETV(_thisObject, "stateTimer",time);	
					
					pr _handle = [_oh,_target] spawn {
						params["_oh","_target"];
						pr _currentWeapon = currentWeapon _oh;
						pr _animation = call{
							if(_currentWeapon isequalto primaryWeapon _oh)exitWith{
								"amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" //primary
							};
							if(_currentWeapon isequalto secondaryWeapon _oh)exitWith{
								"amovpercmstpsraswlnrdnon_ainvpercmstpsraswlnrdnon_putdown" //launcher
							};
							if(_currentWeapon isequalto handgunWeapon _oh)exitWith{
								"amovpercmstpsraswpstdnon_ainvpercmstpsraswpstdnon_putdown" //pistol
							};
							if(_currentWeapon isequalto binocular _oh)exitWith{
								"amovpercmstpsoptwbindnon_ainvpercmstpsoptwbindnon_putdown" //bino
							};
							"amovpercmstpsnonwnondnon_ainvpercmstpsnonwnondnon_putdown" //non
						};
						
						_oh playMove _animation;
						waitUntil {animationState _oh == _animation};
						waitUntil {animationState _oh != _animation};
						
						//_target removeWeapon currentWeapon _target;
						
						//sleep 1;
						
						hint "Hello i'm here";
					};		
					
					SETV(_thisObject, "spawnHandle", _handle);
				};
				
				if (scriptDone GETV(_thisObject, "spawnHandle")) then {
					SETV(_thisObject, "stateChanged", true);
					SETV(_thisObject, "stateMachine", 3);
					
					_state = ACTION_STATE_COMPLETED;
					breakTo "switch";
				};
			};
			
			//failed
			case 2: {
				_state = ACTION_STATE_FAILED;
			};
			
			case 3: {
				_state = ACTION_STATE_COMPLETED;
			};
			
		};
		
		// Return the current state
		SETV(_thisObject, "state", _state);
		_state;
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		terminate GETV(_thisObject, "spawnHandle");
		
		pr _oh = GETV(_thisObject, "objectHandle");
		_oh doWatch objNull;
		_oh lookAt objNull;
		
		hint "";
		
	} ENDMETHOD;
	
	 
	// Calculates cost of this action
	/*
	STATIC_METHOD( ["_thisClass", "", [""]], "getCost") {
		params [["_AI", "", [""]], ["_wsStart", [], [[]]], ["_wsEnd", [], [[]]]];
		
		// Return cost
		0
	} ENDMETHOD;
	*/

ENDCLASS;