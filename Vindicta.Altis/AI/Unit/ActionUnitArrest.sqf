#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OOP_DEBUG
#define OFSTREAM_FILE "ArrestAction.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#define IS_TARGET_ARRESTED_UNCONSCIOUS_DEAD !(alive _target) || (animationState _target == "unconsciousoutprone") || (animationState _target == "unconsciousfacedown") || (animationState _target == "unconsciousfaceup") || (animationState _target == "unconsciousrevivedefault") || (animationState _target == "acts_aidlpsitmstpssurwnondnon_loop") || (animationState _target == "acts_aidlpsitmstpssurwnondnon01")

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

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_target", objNull, [objNull]] ];
		pr _a = GETV(_AI, "agent");
		pr _captor = CALLM(_a, "getObjectHandle", []);
		T_SETV("objectHandle", _captor);
		T_SETV("target", _target);
		
		//FSM
		T_SETV("stateChanged", true);
		T_SETV("stateMachine", 0);
		
		T_SETV("spawnHandle", scriptNull);
		T_SETV("screamTime", 0);
	} ENDMETHOD;
	
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _captor = T_GETV("objectHandle");		
		_captor lockWP false;
		_captor setSpeedMode "NORMAL";

		OOP_INFO_0("ActionUnitArrest: ACTIVATE");
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		CALLM(_thisObject, "activateIfInactive", []);
		
		pr _state = T_GETV("state");
		if (_state != ACTION_STATE_ACTIVE) exitWith {_state};

		pr _captor = T_GETV("objectHandle");
		pr _target = T_GETV("target");

		if (!(alive _captor) || (behaviour _captor == "COMBAT")) then {
			OOP_INFO_0("ActionUnitArrest: FAILED, reason: Captor unit dead or in combat."); 
			T_SETV("stateChanged", true);
			T_SETV("stateMachine", 2);
		};

		if (IS_TARGET_ARRESTED_UNCONSCIOUS_DEAD) then {
			OOP_INFO_0("ActionUnitArrest: completed, reason: target unit dead, unconscious or arrested."); 
			T_SETV("stateChanged", true);
			T_SETV("stateMachine", 3);
		};
		
		scopename "switch";
		switch (T_GETV("stateMachine")) do {

			// CATCH UP
			case 0: {
				OOP_DEBUG_1("CATCH UP %1", getPos _captor distance2D getPos _target);

				if (
					getPos _captor distance2D getPos _target < 6 && 
					!(IS_TARGET_ARRESTED_UNCONSCIOUS_DEAD) &&
					random 4 <= 2
				) then {
					/*
					// Must rework it :/
					[[_target], {
						params ["_target"];
						if (!hasInterface) exitWith {};

						OOP_DEBUG_0("uncon");
						_target playMoveNow "unconsciousfacedown"; // face plant
						sleep 2;
						_target playMoveNow "acts_aidlpsitmstpssurwnondnon01"; // sitting down and tied up

					}] remoteExec ["spawn", _target, false];
					*/

					CALLSM1("ActionUnitArrest", "performArrest", _target);

					_target setVariable ["timeArrested", time+10];

					REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitArrested", [_target], _target, false);	
					
					T_SETV("stateMachine", 1);
					breakTo "switch";
				};

				if (IS_TARGET_ARRESTED_UNCONSCIOUS_DEAD) exitWith {
					T_SETV("state", ACTION_STATE_COMPLETED);
					ACTION_STATE_COMPLETED
				};

				if (T_GETV("stateChanged")) then {
					T_SETV("stateChanged", false);
					T_SETV("stateTimer", time);
					
					_captor dotarget _target;

					pr _handle = [_target,_captor] spawn {
						params ["_target", "_captor"];
						waitUntil {
							pr _pos = (eyeDirection _target vectorMultiply 1.6) vectorAdd getpos _target;
							
							_captor doMove _pos;
							_captor doWatch _target;
							_pos_arrest = getpos _target;

							if (getpos _target distance getpos _captor > 30) then { sleep 3;};
							sleep 1;

							_isMoving = !(_pos_arrest distance getpos _target < 0.1);
							_target setVariable ["isMoving", _isMoving];
							
							pr _return = !_isMoving && {_pos distance getpos _captor < 1.5};
							_return
						};
					};
					terminate T_GETV("spawnHandle");
					T_SETV("spawnHandle", _handle);
				} else {
					// been following for 30 secs
					if (time - T_GETV("stateTimer") > 30) then {
						T_SETV("stateMachine", 2);

						breakTo "switch";
					} else {
						// mitigate the msg flood
						if (random 10 < 1) then {
							if (time > T_GETV("screamTime") && (_target getVariable ["isMoving", false])) then {
								pr _newScreamTime = time + random [10, 15, 20];
								T_SETV("screamTime", _newScreamTime);
								
								pr _sentence = "Stop! Get on the ground!";
								if (selectRandom [true,false]) then { 
									_captor say "stop";
									_sentence = selectRandom [
										"Stop! Get on the ground!",
										"Stop! Get on the ground or I'll shoot!"
										]; 
								} else {
									_captor say "halt";
									_sentence = selectRandom [
										"Halt! Get on the ground!",
										"Halt! Get on the ground or I'll shoot!"
										]; 
								};
								
								[_captor, _sentence, _target] call Dialog_fnc_hud_createSentence;
								_captor setSpeedMode "FULL";
							};
						};
					};
				};
				
				if (scriptDone T_GETV("spawnHandle")) then {
					T_SETV("stateChanged", true);
					T_SETV("stateMachine", 1);
				};
			}; // end CATCH UP

			// SEARCH AND ARREST
			case 1: {
				OOP_INFO_0("ActionUnitArrest: Searching/Arresting target.");

				if (T_GETV("stateChanged")) then {
					T_SETV("stateChanged", false);
					T_SETV("stateTimer", time);
					
					pr _handle = [_captor, _target] spawn {
						params ["_captor", "_target"];
						waitUntil {
							
							_animationDone = false;
							_pos = (eyeDirection _target vectorMultiply 1.6) vectorAdd getpos _target;
							_captor doMove _pos;
							_captor doWatch _target;
							_pos_search = getpos _target;

							// play animation if close enough, finishing the script
							if (getPos _captor distance getPos _target < 1) then {
								pr _currentWeapon = currentWeapon _captor;
								pr _animation = call {
									if(_currentWeapon isequalto primaryWeapon _captor) exitWith {
										"amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" //primary
									};
									if(_currentWeapon isequalto secondaryWeapon _captor) exitWith {
										"amovpercmstpsraswlnrdnon_ainvpercmstpsraswlnrdnon_putdown" //launcher
									};
									if(_currentWeapon isequalto handgunWeapon _captor) exitWith {
										"amovpercmstpsraswpstdnon_ainvpercmstpsraswpstdnon_putdown" //pistol
									};
									if(_currentWeapon isequalto binocular _captor) exitWith {
										"amovpercmstpsoptwbindnon_ainvpercmstpsoptwbindnon_putdown" //bino
									};
									"amovpercmstpsnonwnondnon_ainvpercmstpsnonwnondnon_putdown" //non
								};

								_captor playMove _animation;
								_animationDone = true;

								// WTF why do we have waitUntil here @Sen ?? :O
								waitUntil {animationState _captor == _animation};
								waitUntil {animationState _captor != _animation};
								
								CALLSM1("ActionUnitArrest", "performArrest", _target);
							};

							_animationDone
						};
					};
						
					//[_captor,"So who do whe have here?",_target] call Dialog_fnc_hud_createSentence;			
					
					T_SETV("spawnHandle", _handle);
				} else {
					if ((T_GETV("stateTimer") + 30) < time) then {
						T_SETV("stateMachine", 2);

						breakTo "switch";
					};
				};
				
				if (scriptDone T_GETV("spawnHandle")) then {
					T_SETV("stateChanged", true);
					T_SETV("stateMachine", 3);

					breakTo "switch";
				};
			}; // end SEARCH AND ARREST

			// FAILED
			case 2: {
				OOP_INFO_0("ActionUnitArrest: FAILED CATCH UP.");

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
		_state
	} ENDMETHOD;

	// Performs the actual arrest of target
	STATIC_METHOD("performArrest") {
		params [P_THISCLASS, P_OBJECT("_target")];

		// If it's a civilian presence target...
		if ([_target] call CivPresence_fnc_isUnitCreatedByCP) then {
			[_target, true] call CivPresence_fnc_arrestUnit;
		} else {
			// Otherwise it's a player
			_target playMoveNow "acts_aidlpsitmstpssurwnondnon01"; // sitting down and tied up

			if (!isPlayer _target) then {
				// Some inspiration from https://forums.bohemia.net/forums/topic/193304-hostage-script-using-holdaction-function-download/
				_target disableAI "MOVE"; // Disable AI Movement
				_target disableAI "AUTOTARGET"; // Disable AI Autotarget
				_target disableAI "ANIM"; // Disable AI Behavioural Scripts
				_target allowFleeing 0; // Disable AI Fleeing
				_target setBehaviour "Careless"; // Set Behaviour to Careless because, you know, ARMA AI.
			};
		
			_target setVariable ["timeArrested", time+10];

			REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitArrested", [_target], _target, false);
		};
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];

		terminate T_GETV("spawnHandle");
		pr _captor = T_GETV("objectHandle");
		_captor doWatch objNull;
		_captor lookAt objNull;
		_captor lockWP false;
		_captor setSpeedMode "LIMITED";
		
	} ENDMETHOD;

ENDCLASS;
