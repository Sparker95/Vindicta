#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\Resources\UndercoverUI\UndercoverUI_Macros.h"

#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"

#define pr private
#define sUNDERCOVER 0
#define sWANTED 1
#define sCOMPROMISED 2
#define sSURRENDERED 3
#define sINCAPACITATED 4
#define DEBUG

gMsgLoopUndercover = NEW("MessageLoop", []);
CALL_METHOD(gMsgLoopUndercover, "setDebugName", ["Undercover thread"]);

/*
undercoverMonitor: Changes this object's unit's captive status dynamically based on equipment, behavior, location, and so on.

Date: December 2018
Authors: Sparker, Marvis
*/

// ------------ S Q F  F U N C T I O N S ------------

	// increases suspicion for suspicious behavior and returns it
	fnc_UM_incSuspBehavior = { 
		params ["_unit"];
		pr _susp = _unit getVariable "incrementSusp";
		_susp = _susp + SUSP_INCREMENT;
		_unit setVariable ["incrementSusp", _susp];
		_susp;
	};

// ------------ U N D E R C O V E R  M O N I T O R  C L A S S ------------

CLASS("undercoverMonitor", "MessageReceiver");

	VARIABLE("unit"); 														// unit this undercoverMonitor is attached to
	VARIABLE("state");														// state of this unit's undercoverMonitor
	VARIABLE("stateChanged");												// "do once" variable for state changes
	VARIABLE("suspicion");													// unit's final suspiciousness for each interval
	VARIABLE("incrementSusp");												// a temporary variable for suspicion increases over time
	VARIABLE("timeSeen");														
	VARIABLE("timeCompromised");											// greater than current mission time if player was compromised by external process
	VARIABLE("timeHostility");												// greater than current mission time if player recently fired a weapon
	VARIABLE("eyePosOld");													
	VARIABLE("eyePosOldVeh");
	VARIABLE("nearestEnemyDist");
	VARIABLE("nearestEnemy");	
	VARIABLE("bSeen");
	VARIABLE("suspGear");
	VARIABLE("suspGearVeh");
	VARIABLE("timer"); 														// Timer which will send SMON_MESSAGE_PROCESS message every second or so

	// ------------ N E W ------------

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_unit", objNull, [objNull]]];

		T_SETV("unit", _unit);
		_unit setVariable ["undercoverMonitor", _thisObject];

		// FSM
		T_SETV("state", sUNDERCOVER);
		T_SETV("stateChanged", true);

		// UM variables
		T_SETV("suspicion", 0);
		T_SETV("incrementSusp", 0);
		T_SETV("timeSeen", 0);
		T_SETV("timeCompromised", 0);
		T_SETV("timeHostility", 0);
		T_SETV("eyePosOld", [0, 0, 0]);
		T_SETV("eyePosOldVeh", [0, 0, 0]);
		T_SETV("nearestEnemyDist", -1);
		T_SETV("nearestEnemy", objNull);
		T_SETV("bSeen", false);
		T_SETV("suspGear", 0);
		T_SETV("suspGearVeh", 0);

		// Global unit variables
		_unit setVariable [UNDERCOVER_EXPOSED, false, true];				// GLOBAL: true if player unit's exposure is above some threshold while he's in a vehicle
		_unit setVariable [UNDERCOVER_WANTED, false, true];					// GLOBAL: if true player unit is hostile and "setCaptive false"
		_unit setVariable [UNDERCOVER_SUSPICIOUS, false, true];				// GLOBAL: true if player is suspicious (suspicion variable >= SUSPICIOUS #define)
		_unit setVariable [UNDERCOVER_SUSPICION, 0, true];					// GLOBAL: suspicion variable for this unit, set each interval													

		// animations that force you undercover (ace surrender, ...)
		g_UM_undercoverAnims = [
			"ace_amovpercmstpssurwnondnon",
			"AmovPercMstpSnonWnonDnon_Ease"
		];

		CALLM0(_thisObject, "calcGearSuspicion");							// evaluate suspicion of unit's equipment
		_unit setCaptive true;

		// CBA event handler for checking player unit's equipment suspiciousness
		["loadout", {
			params ["_unit", "_newLoadout"];
			pr _uM = _unit getVariable "undercoverMonitor";
			CALLM0(_uM, "calcGearSuspicion");
    	}] call CBA_fnc_addPlayerEventHandler;

    	// used for checking when player has last fired a weapon
    	_unit addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
			_unit setVariable ["timeHostility", time + TIME_HOSTILITY];
		}];

		_unit addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];

			// delete this undercoverMonitor
			pr _um = _unit getVariable ["undercoverMonitor", ""];
			if (_um != "") then { // Sanity check
				pr _msg = MESSAGE_NEW();
				MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_DELETE);
				CALLM1(_um, "postMessage", _msg);
			};
		}];

		// show debug UI
		#ifdef DEBUG
		g_rscLayerUndercoverDebug = ["rscLayerUndercoverDebug"] call BIS_fnc_rscLayer;
		g_rscLayerUndercoverDebug cutRsc ["UndercoverUIDebug", "PLAIN", -1, false];
		#endif

		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_PROCESS);
		pr _updateInterval = 1.0;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);

	} ENDMETHOD;


	// ------------ D E L E T E ------------

	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		// Delete the timer
		pr _timer = T_GETV("timer");
		pr _unit = T_GETV("unit");
		_unit setVariable ["undercoverMonitor", nil];

		DELETE(_timer);
	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMsgLoopUndercover
	} ENDMETHOD;


	// ------------ H A N D L E  M E S S A G E ------------

	METHOD("handleMessage") {
		params [["_thisObject", "", [""]] , ["_msg", [], [[] ]]];
		pr _msgType = _msg select MESSAGE_ID_TYPE;

		switch (_msgType) do {

			// 	M A I N  U N D E R C O V E R  P R O C E S S
			case SMON_MESSAGE_PROCESS: {
				pr _state = T_GETV("state");
				OOP_INFO_1("undercoverMonitor START state: %1", _state);

				pr _unit = T_GETV("unit");
				pr _suspicion = 0;
				pr _hintKeys = [];							// each interval, stores keys for hints to show 
				
				pr _bInAllowedArea = false;

				pr _bSeen = T_GETV("bSeen");
				pr _nearestEnemy = T_GETV("nearestEnemy");
				pr _timeSeen =  T_GETV("timeSeen");

				pr _timeCompromised = T_GETV("timeCompromised");
				// check if unit was compromised externally
				if (time < _timeCompromised) then {


				};
				
				if (animationState _unit in g_UM_undercoverAnims) exitWith { _state = sUNDERCOVER; _hintKeys pushback HK_SURRENDER; }; // Hotfix for ACE surrendering
				if ( _unit getVariable ["ACE_isUnconscious", false] ) exitWith { _state = sUNDERCOVER; _hintKeys pushback HK_INCAPACITATED; };
					
				//FSM
				switch (_state) do {

					// state "UNDERCOVER" start
					case sUNDERCOVER: {
						if (T_GETV("stateChanged")) then {
						_unit setVariable [UNDERCOVER_WANTED, false, true];	
						T_SETV("stateChanged", false);
						}; // do once when state changed
	

						pr _bInVeh = false;
						if (!(isNull objectParent _unit)) then { _bInVeh = true; }; // player in vehicle?

						switch (_bInVeh) do {

							// unit IS NOT in vehicle
							case false: {
								pr _suspGear = T_GETV("suspGear");
								if (_suspGear > 0) then { _hintKeys pushback HK_SUSPGEAR; };

								// suspiciousness for movement speed
								pr _suspSpeed = (vectorMagnitude velocity _unit) * 0.06;
								if ( _suspSpeed > SUSP_SPEEDMAX ) then { _suspSpeed = SUSP_SPEEDMAX; };

								// suspiciousness for stance
								pr _suspStance = 0;
								switch (stance _unit) do {
									case "CROUCH": { _suspStance = SUSP_CROUCH; };
					    			case "PRONE": { _suspStance = SUSP_PRONE; };
					    		};


								_suspicion = _suspGear + _suspSpeed + _suspStance;
							};

							// unit IS in vehicle
							case true: {
								pr _suspGearVeh = T_GETV("suspGearVeh");
								pr _bodyExposure = T_CALLM("getBodyExposure");

								_suspicion = _suspGearVeh;
							};

						};

					}; // state "UNDERCOVER" end

					// state "WANTED" start
					case sWANTED: {
						if (T_GETV("stateChanged")) then {
						_unit setVariable [UNDERCOVER_WANTED, true, true];	
						T_SETV("stateChanged", false);
						}; // do once when state changed

						// create marker, kind of like GTA's red circle you have to escape to lose the police
						// only update marker if unit is seen, otherwise no escape possible
						if (_bSeen) then {
							pr _mrkLastHost = createMarkerLocal ["mrkLastHostility", position _unit];
							"mrkLastHostility" setMarkerAlphaLocal 0.0;

							#ifdef DEBUG
								"mrkLastHostility" setMarkerBrushLocal "SOLID";
								"mrkLastHostility" setMarkerAlphaLocal 0.5;
								"mrkLastHostility" setMarkerColorLocal "ColorBlue";
								"mrkLastHostility" setMarkerSizeLocal [WANTED_CIRCLE_RADIUS/2, WANTED_CIRCLE_RADIUS/2];
								"mrkLastHostility" setMarkerShapeLocal "ELLIPSE";
							#endif
						}; 

						_suspicion = 1;

						// Conditions for exiting WANTED state
						if ( ((position _unit) distance2D (getMarkerPos "mrkLastHostility")) > WANTED_CIRCLE_RADIUS) exitWith { 
							T_CALLM("setState", [sUNDERCOVER]);
							OOP_INFO_0("undercoverMonitor: No longer WANTED, reason: Left wanted radius."); 
						};

						if ((_timeSeen - time) < TIME_UNSEEN_WANTED_EXIT) exitWith { 
							T_CALLM("setState", [sUNDERCOVER]);
							OOP_INFO_0("undercoverMonitor: No longer WANTED, reason: Unseen for long enough."); 
						};

						if ({alive _x} count units group _nearestEnemy == 0 ) exitWith { 
							T_CALLM("setState", [sUNDERCOVER]);
							OOP_INFO_0("undercoverMonitor: No longer WANTED, reason: Killed last group that spotted player."); 
						}; // no unit from group that last spotted player unit is alive

					}; // state WANTED end

					// state "COMPROMISED" start
					case sCOMPROMISED: {

					}; // state "COMPROMISED" end


					// state SURRENDERED start
					case sCOMPROMISED: {

					}; // state "SURRENDERED" start


					// state "INCAPACITATED" start
					case sINCAPACITATED: {

					}; // state "INCAPACITATED" end
				}; // end FSM

				OOP_INFO_1("undercoverMonitor: hint keys: %1", _hintKeys);

				T_SETV("state", _state);
				OOP_INFO_1("undercoverMonitor END state: %1", _state);
				systemChat format ["State END: %1", _state];

				// set captive status of unit
				pr _args = [_suspicion, _state];
				CALLSM("undercoverMonitor", "setCaptive", _args);

				// update normal UI
				#ifndef DEBUG
				_args = [_unit, _suspicion, _hintKeys];
				CALL_STATIC_METHOD("UndercoverUI", "drawUI", _args); // draw UI
				#endif

				// update debug UI
				#ifdef DEBUG
				_unit setVariable ["suspicion", _suspicion];
				[_unit] call fnc_UIUndercoverDebug;
				g_rscLayerUndercover cutRsc ["Default", "PLAIN", -1, false];
				#endif

			}; // end SMON_MESSAGE_PROCESS

			// Messaged by onUnitSpotted method (see SensorGroupTargets), when this object's unit is seen by an enemy.
			// Also finds enemy unit closest to player unit and store it in variable for SMON_MESSAGE_PROCESS
			case SMON_MESSAGE_BEING_SPOTTED: {

				pr _msgData = _msg select MESSAGE_ID_DATA;

				pr _unit = T_GETV("unit");
				pr _suspicion = T_GETV("suspicion");

				T_SETV("bSeen", true);
				T_SETV("timeSeen", (time + TIME_SEEN));

				// find closest enemy watching player
				pr _grpDistances = [];
				{
					pr _tempDist = (position _x) distance (position _unit);
					_grpDistances pushBack _tempDist;
				} forEach units _msgData;

				pr _minDist = selectMin _grpDistances;
				pr _minDistIndex = _grpDistances find _minDist;

				pr _nearestEnemy = (units _msgData) select _minDistIndex;
				//T_SETV("nearestEnemy", _nearestEnemy);

				if (_suspicion >= 1 or !(captive _unit)) then {
					T_CALLM("setState", [sWANTED]);
				}; 
			}; // end SMON_MESSAGE_BEING_SPOTTED

			// messages sent here will temporarily make this object's unit overt 
			case SMON_MESSAGE_COMPROMISED: {
				OOP_INFO_0("undercoverMonitor: Received message: SMON_MESSAGE_COMPROMISED");

				pr _unit = T_GETV("unit");
				T_SETV("timeCompromised", (time + 4));
				T_CALLM("setState", [sCOMPROMISED]);
			}; // end SMON_MESSAGE_COMPROMISED

			// delete dead unit's undercoverMonitor
			case SMON_MESSAGE_DELETE: {
				DELETE(_thisObject);
			}; // end SMON_MESSAGE_DELETE
		};

		false
	} ENDMETHOD;

	/* 
	SensorGroupTargets remoteExecutes this on this computer when an enemy group is currently spotting the player.
	This function resolves undercoverMonitor of player and posts a message to it.
	*/
	STATIC_METHOD("onUnitSpotted") {
		params ["_thisClass", ["_unit", objNull, [objNull]], ["_group", grpNull, [grpNull]]];
		pr _um = _unit getVariable ["undercoverMonitor", ""];
		if (_um != "") then { // Sanity check
			pr _msg = MESSAGE_NEW();
			MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_BEING_SPOTTED);
			MESSAGE_SET_DATA(_msg, _group);
			CALLM1(_um, "postMessage", _msg);
		};
	} ENDMETHOD;


	/*
	Method: calcCaptive
	Sets captive status of unit based on state variable and suspicion variable.

	Parameters: 0: _state 			- (Integer) current state of UM
				1: _suspicion 		- (Integer) suspicion value of unit

	*/
	METHOD("calcCaptive") {
		params [["_thisObject", "", [""]], ["_suspicion", 0], ["_state", sUNDERCOVER]];

		// _unit setCaptive false;

		//if (_state == sUNDERCOVER OR )
		
	} ENDMETHOD;


	/*
	Method: setState
	Changes the undercoverMonitor state and sets stateChanged variable to true.

	Parameters: 0: _state 			- (Integer) new state for UM

	*/
	METHOD("setState") {
		params [["_thisObject", "", [""]], ["_state", 0]];

		T_SETV("state", _state);
		T_SETV("stateChanged", true);
		
	} ENDMETHOD;


	/*
	Method: calcGearSuspicion

	Calculates the suspiciousness of the units equipment on foot and in vehicles, and stores it in two variables for this object.

	*/
	METHOD("calcGearSuspicion") {
		params [["_thisObject", "", [""]]];
		pr _unit = T_GETV("unit");

		pr _suspGear = 0;
		pr _suspGearVeh = 0;

		if !((uniform _unit in g_UM_civUniforms) or (uniform _unit == "")) then { _suspGear = _suspGear + SUSP_UNIFORM; _suspGearVeh = _suspGearVeh + SUSP_UNIFORM; };
		if !((headgear _unit in g_UM_civHeadgear) or (headgear _unit == "")) then { _suspGear = _suspGear + SUSP_HEADGEAR; _suspGearVeh = _suspGearVeh + SUSP_HEADGEAR; };
		if !((goggles _unit in g_UM_civFacewear) or (goggles _unit == "")) then { _suspGear = _suspGear + SUSP_FACEWEAR; _suspGearVeh = _suspGearVeh + SUSP_FACEWEAR; };
		if !((vest _unit in g_UM_civVests) or (vest _unit == "")) then { _suspGear = _suspGear + SUSP_VEST; _suspGearVeh = _suspGearVeh + SUSP_VEST; };
		if (hmd _unit != "") then { _suspGear = _suspGear + SUSP_NVGS; };
		if !((backpack _unit in g_UM_civBackpacks) or (backpack _unit == "")) then { _suspGear = _suspGear + SUSP_BACKPACK; };

		if !( primaryWeapon _unit in g_UM_civWeapons) then { _suspGear = _suspGear + 1; };
		if !( secondaryWeapon _unit in g_UM_civWeapons) then { _suspGear = _suspGear + 1; };

		T_SETV("suspGear", _suspGear);
		T_SETV("suspGearVeh", _suspGearVeh);
		
	} ENDMETHOD;

	/*
	Method: getBodyExposure

	Returns the body exposure value of the unit, or: how visible the this undercoverMonitor's unit currently is.
	Also sets a global "exposed" boolean variable on the unit. If the variable is false, then the unit is invisible to enemy.

	Returns: Number between 0.0 and 1.0.

	*/
	METHOD("getBodyExposure") {
		params [["_thisObject", "", [""]]];
		pr _unit = T_GETV("unit");

		pr _bodyExposure = T_GETV("bodyExposure");
		pr _eyePosOldVeh = T_GETV("eyePosOldVeh");
		pr _eyePosOld = T_GETV("eyePosOld");
		pr _eyePosNewVeh = (vehicle _unit) worldToModelVisual (_unit modelToWorldVisual (_unit selectionPosition "head"));

		// bodyExposure and eyePos
		if ((_eyePosOldVeh vectorDistance _eyePosNewVeh) > 0.15) then {
			_bodyExposure = [20, 120, 0, 360, _unit] call fnc_getVisibleSurface;

			// Limit body exposure to more usable values, set bExposed variable
			if (_bodyExposure < 0.12) then {
				_bodyExposure = 0.0;
				_unit setVariable [UNDERCOVER_EXPOSED, false, true];
			} else {
				if (_bodyExposure > 0.85) then {
					_bodyExposure = 1;
					_unit setVariable [UNDERCOVER_EXPOSED, true, true];
				};
			}; T_SETV("eyePosOldVeh", _eyePosNewVeh);
		};
		_bodyExposure
		
	} ENDMETHOD;

ENDCLASS;
