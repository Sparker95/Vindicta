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

CLASS("ActionUnitArrest", "Action")
	
	VARIABLE("target");
	VARIABLE("objectHandle");
	VARIABLE("stateTimer");
	VARIABLE("stateMachine");
	VARIABLE("stateChanged");
	VARIABLE("spawnHandle");
	VARIABLE("screamTime");
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_target", objNull, [objNull]] ];
		SETV(_thisObject, "target", _target);
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _captor = CALLM(_a, "getObjectHandle", []);
		SETV(_thisObject, "objectHandle", _captor);
		
		
		//FSM
		SETV(_thisObject, "stateChanged", true);
		SETV(_thisObject, "stateMachine", 0);
		
		SETV(_thisObject,"spawnHandle",scriptNull);
		SETV(_thisObject,"screamTime",0);

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		pr _captor = GETV(_thisObject, "objectHandle");		
		_captor lockWP false;
		_captor setSpeedMode "NORMAL";
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		CALLM(_thisObject, "activateIfInactive", []);
		
		pr _captor = GETV(_thisObject, "objectHandle");
		pr _target = GETV(_thisObject, "target");
		if !(alive _captor) exitWith { 
			_state = ACTION_STATE_FAILED;
			T_SETV("state", ACTION_STATE_FAILED); 
			_state;
		};
		
		diag_log format ["stateMachine %1",GETV(_thisObject, "stateMachine")];
		pr _state = ACTION_STATE_ACTIVE;
		scopename "switch";
		switch (GETV(_thisObject, "stateMachine")) do {

			// catch up to target
			case 0: {
				
				if (GETV(_thisObject, "stateChanged")) then {
					diag_log "START STATE 0";
					SETV(_thisObject, "stateChanged",false);
					
					SETV(_thisObject,"stateTimer",time);		
					
					_captor dotarget _target;
					
					pr _handle = [_target,_captor] spawn {
						params["_target","_captor"];
						waitUntil{
							_pos = (eyeDirection _target vectorMultiply 1.6) vectorAdd getpos _target;
							_captor doMove _pos;
							_captor doWatch _target;
							_pos_arrest = getpos _target;
							sleep 0.5;
							_isMoving = !(_pos_arrest distance getpos _target <0.1);
							_target setVariable ["isMoving", _isMoving];
							
							_return = !_isMoving && {_pos distance getpos _captor < 1.5};
							_return
						};
					};
					SETV(_thisObject, "spawnHandle", _handle);

				}else{

					if (time - GETV(_thisObject,"stateTimer") > 15)then{//been following for 10 secs
						_state = ACTION_STATE_FAILED;
					
						CALLM(_thisObject, "terminate", []);
						diag_log "ACTION_STATE_FAILED";
						[_captor,"Yes keep running!",_target] call Dialog_fnc_hud_createSentence;
						breakTo "switch";

					}else{
	
						if(time > GETV(_thisObject,"screamTime") && (_target getVariable ["isMoving", false]))then{
							
							SETV(_thisObject,"screamTime",time +2);
							if(selectRandom [true,false])then{
								[_captor,"Stop!",_target] call Dialog_fnc_hud_createSentence;
								_captor say "stop";
							}else{
								[_captor,"Halt!",_target] call Dialog_fnc_hud_createSentence;
								_captor say "halt";
							};
							
							_captor setSpeedMode "FULL";
						};
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
					
					pr _handle = [_captor,_target] spawn {
						params["_captor","_target"];
						pr _currentWeapon = currentWeapon _captor;
						pr _animation = call{
							if(_currentWeapon isequalto primaryWeapon _captor)exitWith{
								"amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" //primary
							};
							if(_currentWeapon isequalto secondaryWeapon _captor)exitWith{
								"amovpercmstpsraswlnrdnon_ainvpercmstpsraswlnrdnon_putdown" //launcher
							};
							if(_currentWeapon isequalto handgunWeapon _captor)exitWith{
								"amovpercmstpsraswpstdnon_ainvpercmstpsraswpstdnon_putdown" //pistol
							};
							if(_currentWeapon isequalto binocular _captor)exitWith{
								"amovpercmstpsoptwbindnon_ainvpercmstpsoptwbindnon_putdown" //bino
							};
							"amovpercmstpsnonwnondnon_ainvpercmstpsnonwnondnon_putdown" //non
						};
						
						[_captor,"So who do whe have here?",_target] call Dialog_fnc_hud_createSentence;
						
						_captor playMove _animation;
						waitUntil {animationState _captor == _animation};
						waitUntil {animationState _captor != _animation};
						
						//_target removeWeapon currentWeapon _target;
						
						//sleep 1;
						
						
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
		
		pr _captor = GETV(_thisObject, "objectHandle");
		_captor doWatch objNull;
		_captor lookAt objNull;
		_captor lockWP false;
		_captor setSpeedMode "LIMITED";
		hint "";
		
	} ENDMETHOD;

ENDCLASS;