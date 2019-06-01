#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OOP_DEBUG
#define OFSTREAM_FILE "ArrestAction.rpt"
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
		T_SETV("target", _target);
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _captor = CALLM(_a, "getObjectHandle", []);
		T_SETV("objectHandle", _captor);
		
		//FSM
		T_SETV("stateChanged", true);
		T_SETV("stateMachine", 0);
		
		SETV(_thisObject,"spawnHandle",scriptNull);
		SETV(_thisObject,"screamTime",0);

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		pr _captor = T_GETV("objectHandle");		
		_captor lockWP false;
		_captor setSpeedMode "NORMAL";
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		CALLM(_thisObject, "activateIfInactive", []);
		
		pr _captor = T_GETV("objectHandle");
		pr _target = T_GETV("target");
		if (!(alive _captor) OR (behaviour _captor == "COMBAT")) exitWith {
			OOP_INFO_0("ActionUnitArrest: FAILED, reason: Captor unit dead or in combat."); 
			_state = ACTION_STATE_FAILED;
		};
		
		pr _state = ACTION_STATE_ACTIVE;
		scopename "switch";
		switch (T_GETV("stateMachine")) do {

			/*
			--------------------------------------------------------------------------------------------------------------------------------------------
			|	 C A T C H  U P  																									   				   |
			--------------------------------------------------------------------------------------------------------------------------------------------
			*/
			case 0: {
				OOP_INFO_0("ActionUnitArrest: Chasing target.");
				
				if (T_GETV("stateChanged")) then {
					T_SETV("stateChanged",false);
					T_SETV("stateTimer", time);		
					
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
					T_SETV("spawnHandle", _handle);

				} else {

					if (time - GETV(_thisObject,"stateTimer") > 15) then {//been following for 10 secs
						OOP_INFO_0("ActionUnitArrest: FAILED, reason: Timeout.");
						_state = ACTION_STATE_FAILED;
						//[_captor,"Yes keep running!",_target] call Dialog_fnc_hud_createSentence;
						breakTo "switch";

					} else {
	
						if (time > T_GETV("screamTime") && (_target getVariable ["isMoving", false])) then {
							
							SETV(_thisObject,"screamTime",time +2);
							if (selectRandom [true,false]) then {
								//[_captor,"Stop!",_target] call Dialog_fnc_hud_createSentence;
								_captor say "stop";
							} else {
								//[_captor,"Halt!",_target] call Dialog_fnc_hud_createSentence;
								_captor say "halt";
							};
							
							_captor setSpeedMode "FULL";
						};
					};
				};
				
				if (scriptDone T_GETV("spawnHandle")) then {
					diag_log "stateMachine 0 Done" ;
					T_SETV("stateChanged", true);
					T_SETV("stateMachine", 1);
				};
			}; // end CATCH UP
			
			/*
			--------------------------------------------------------------------------------------------------------------------------------------------
			|	 S E A R C H  A N D  A R R E S T																								   	   |
			--------------------------------------------------------------------------------------------------------------------------------------------
			*/
			case 1: {
				OOP_INFO_0("ActionUnitArrest: Searching/Arresting target.");

				if (T_GETV("stateChanged")) then {
					T_SETV("stateChanged", false);
					T_SETV("stateTimer", time);	
					
					pr _handle = [_captor, _target] spawn {
						params["_captor","_target"];
						waitUntil {
							_animationDone = false;
							_pos = (eyeDirection _target vectorMultiply 1.6) vectorAdd getpos _target;
							_captor doMove _pos;
							_captor doWatch _target;
							_pos_search = getpos _target;
							sleep 0.5;

							// play animation if close enough, finishing the script
							if (_pos_search distance getpos _target < 0.1) then {
								pr _animation = call {
									if( currentWeapon isequalto primaryWeapon _captor ) exitWith {
										"amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" //primary
									};
									if( currentWeapon isequalto secondaryWeapon _captor ) exitWith {
										"amovpercmstpsraswlnrdnon_ainvpercmstpsraswlnrdnon_putdown" //launcher
									};
									if( currentWeapon isequalto handgunWeapon _captor ) exitWith {
										"amovpercmstpsraswpstdnon_ainvpercmstpsraswpstdnon_putdown" //pistol
									};
									if( currentWeapon isequalto binocular _captor ) exitWith {
										"amovpercmstpsoptwbindnon_ainvpercmstpsoptwbindnon_putdown" //bino
									};
									"amovpercmstpsnonwnondnon_ainvpercmstpsnonwnondnon_putdown" //non
								};
								_captor playMove _animation;
								_animationDone = true;

								waitUntil {animationState _captor == _animation};
								waitUntil {animationState _captor != _animation};
								REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitArrested", [_target], _target, false);	
							};

							//_target setVariable ["isMoving", _isMoving];
							
							_return = _animationDone;
							_return
						};
					};
						
					//[_captor,"So who do whe have here?",_target] call Dialog_fnc_hud_createSentence;

					// arrest player by sending a message to unit's undercoverMonitor				
					
					T_SETV("spawnHandle", _handle);
				} else {
					if ((T_GETV("stateTimer") + 30) < time) exitWith {
						T_SETV("stateMachine", 2); // action failed
					};
				};
				
				if (scriptDone T_GETV("spawnHandle")) then {
					T_SETV("stateChanged", true);
					T_SETV("stateMachine", 3);
					
					_state = ACTION_STATE_COMPLETED;
					breakTo "switch";
				};
			}; // end SEARCH AND ARREST

			// FAILED
			case 2: {
				OOP_INFO_0("ActionUnitArrest: FAILED.");
				_state = ACTION_STATE_FAILED;
			};
			
			// COMPLETED SUCCESSFULLY
			case 3: {
				OOP_INFO_0("ActionUnitArrest: COMPLETED.");
				_state = ACTION_STATE_COMPLETED;
			};
			
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state;
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		OOP_INFO_0("ActionUnitArrest: Terminating.");

		pr _state = T_GETV("state");
		OOP_INFO_1("ActionUnitArrest: Terminate state: %1", _state);

		terminate T_GETV("spawnHandle");
		
		pr _captor = T_GETV("objectHandle");
		_captor doWatch objNull;
		_captor lookAt objNull;
		_captor lockWP false;
		_captor setSpeedMode "LIMITED";
		
	} ENDMETHOD;

ENDCLASS;