#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\Resources\UndercoverUI\UndercoverUI_Macros.h"

#define pr private
#define sUNDERCOVER 0
#define sWANTED 1
#define sCOMPROMISED 2
#define sARRESTED 3
#define sINCAPACITATED 4
//#define DEBUG

gMsgLoopUndercover = NEW("MessageLoop", []);
CALL_METHOD(gMsgLoopUndercover, "setDebugName", ["Undercover thread"]);

/*
undercoverMonitor: Changes this object's unit's captive status dynamically based on equipment, behavior, location, and so on.

Date: December 2018
Authors: Sparker, Marvis
*/

// array of animations that force you undercover (ace surrender, ...)
g_UM_undercoverAnims = [
	"ace_amovpercmstpssurwnondnon",
	"AmovPercMstpSnonWnonDnon_Ease"
];

// ------------ U N D E R C O V E R  M O N I T O R  C L A S S ------------

CLASS("UndercoverMonitor", "MessageReceiver");

	VARIABLE("unit"); 														// unit this undercoverMonitor is attached to
	VARIABLE("state");														// state of this unit's undercoverMonitor
	VARIABLE("stateChanged");												// "do once" variable for state changes
	VARIABLE("suspicion");													// unit's final suspiciousness for each interval
	VARIABLE("incrementSusp");												// a temporary variable for suspicion increases over time
	VARIABLE("timeSeen");														
	VARIABLE("timeHostility");												// greater than current mission time if player recently fired a weapon
	VARIABLE("eyePosOld");													
	VARIABLE("eyePosOldVeh");
	VARIABLE("nearestEnemyDist");
	VARIABLE("nearestEnemy");	
	VARIABLE("bSeen");
	VARIABLE("suspGear");
	VARIABLE("suspGearVeh");
	VARIABLE("bodyExposure");
	VARIABLE("timeCompromised");
	VARIABLE("camoCoeff"); 													// modified vanilla camouflage coefficient, see: community.bistudio.com/wiki/setUnitTrait
	VARIABLE("bGhillie");													// true if unit is wearing ghillie suit
	VARIABLE("EHLoadout");
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
		T_SETV("timeHostility", 0);
		T_SETV("eyePosOld", [0 ARG 0 ARG 0]);
		T_SETV("eyePosOldVeh", [0 ARG 0 ARG 0]);
		T_SETV("nearestEnemyDist", -1);
		T_SETV("nearestEnemy", objNull);
		T_SETV("bSeen", false);
		T_SETV("suspGear", 0);
		T_SETV("suspGearVeh", 0);
		T_SETV("bodyExposure", 1);
		T_SETV("timeCompromised", -1);
		pr _camoCoeff = _unit getUnitTrait "camouflageCoef";
		T_SETV("camoCoeff", _camoCoeff);
		T_SETV("bGhillie", false);
		T_SETV("EHLoadout", false);

		// Global unit variables
		_unit setVariable [UNDERCOVER_EXPOSED, false, true];				// GLOBAL: true if player unit's exposure is above some threshold while he's in a vehicle
		_unit setVariable [UNDERCOVER_WANTED, false, true];					// GLOBAL: if true player unit is hostile and "setCaptive false"
		_unit setVariable [UNDERCOVER_SUSPICIOUS, false, true];				// GLOBAL: true if player is suspicious (suspicion variable >= SUSPICIOUS #define)
		_unit setVariable [UNDERCOVER_SUSPICION, 0, true];					// GLOBAL: suspicion variable for this unit, set each interval													

		CALLM0(_thisObject, "calcGearSuspicion");							// evaluate suspicion of unit's equipment
		_unit setCaptive true;

		// CBA event handler for checking player unit's equipment suspiciousness
		pr _EH_loadout = ["loadout", {
			params ["_unit", "_newLoadout"];
			pr _uM = _unit getVariable "undercoverMonitor";
			if (_uM != "") then { CALLM0(_uM, "calcGearSuspicion"); };
    	}] call CBA_fnc_addPlayerEventHandler;
		T_SETV("EHLoadout", _EH_loadout);

    	// event handler to check if unit fired weapon
    	_unit addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
			pr _uM = _unit getVariable "undercoverMonitor";
			SETV(_uM, "timeHostility", (time +TIME_HOSTILITY));
		}];

		// event handler for deleting this undercover monitor
		_unit addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];

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
		//pr _unit = T_GETV("unit");
		//_unit setVariable ["undercoverMonitor", nil];

		pr _EH_loadout = T_GETV("EHLoadout");
		 ["loadout", _EH_loadout] call CBA_fnc_removeEventHandler;
		T_SETV("EHLoadout", nil);

		T_SETV("unit", nil);
		T_SETV("state", nil);
		T_SETV("stateChanged", nil);
		T_SETV("suspicion", nil);
		T_SETV("incrementSusp", nil);
		T_SETV("timeSeen", nil);
		T_SETV("timeHostility", nil);
		T_SETV("eyePosOld", nil);
		T_SETV("eyePosOldVeh", nil);
		T_SETV("nearestEnemyDist", nil);
		T_SETV("nearestEnemy", nil);
		T_SETV("bSeen", nil);
		T_SETV("suspGear", nil);
		T_SETV("suspGearVeh", nil);
		T_SETV("bodyExposure", nil);
		T_SETV("timeCompromised", nil);
		T_SETV("camoCoeff", nil);
		T_SETV("bGhillie", nil);

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
				pr _hintKeys = [];									// UI keys for displaying hints
				pr _nearestEnemy = T_GETV("nearestEnemy");
				pr _camoCoeffMod = 0;								// percentage by which camouflage coefficient is modified each interval

				// reset "seen by enemy" variable
				pr _timeSeen = T_GETV("timeSeen");
				if (time > _timeSeen) then { 
					T_SETV("bSeen", false);
					_timeSeen = -1;
					T_SETV("timeSeen", _timeSeen);
				};

				// check if unit is in vehicle
				pr _bInVeh = false;
				if (!(isNull objectParent _unit)) then { _bInVeh = true; }; 

				if ( _unit getVariable ["ACE_isUnconscious", false] ) then { T_CALLM("setState", [sINCAPACITATED]); _hintKeys pushback HK_INCAPACITATED; };		// ACE unconscious

				if ((vehicle _unit nearRoads SUSP_NOROADS) isEqualTo [] ) then { 
					_suspicion = _suspicion + SUSP_OFFROAD;
					_hintKeys pushback HK_OFFROAD;
				}; // offroad suspicion penalty
									
				//FSM
				switch (_state) do {

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 U N D E R C O V E R  S T A T E  																									   |
					|	 Player can be captive or non-captive at the end of the undercover state process. 			   										   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
					case sUNDERCOVER: {
						if (T_GETV("stateChanged")) then {
						_unit setVariable [UNDERCOVER_WANTED, false, true];	
						T_SETV("stateChanged", false);
						}; // do once when state changed

						pr _timeHostility = T_GETV("timeHostility");
						if (time < _timeHostility) exitWith { _suspicion = 1; _hintKeys pushback HK_HOSTILITY; };
	
						// check if unit is in allowed area
						pr _pos = getPos _unit;
						pr _bInAllowedArea = false;
				 		pr _loc = CALL_STATIC_METHOD("Location", "getLocationAtPos", [_pos]);
				 		if (_loc != "") then { 	
							if ( CALLM(_loc, "isInAllowedArea", [_pos]) ) then { 
								_bInAllowedArea = true; _hintKeys pushback HK_ALLOWEDAREA;
							} else { 
								_suspicion = _suspicion + 1;
							};
				 		};

						switch (_bInVeh) do {

							// ------------------------------------------- 
							//  O N   F O O T 
							// -------------------------------------------
							case false: {
								_unit setVariable [UNDERCOVER_EXPOSED, true, true];	

								if (animationState _unit in g_UM_undercoverAnims) exitWith { _suspicion = 0; _hintKeys pushback HK_SURRENDER; }; // Hotfix for ACE surrendering

								pr _suspGear = T_GETV("suspGear");
								if (_suspGear > 0) then { _hintKeys pushback HK_SUSPGEAR; };

								// suspiciousness for movement speed
								pr _suspSpeed = (vectorMagnitude velocity _unit) * 0.06;
								if ( _suspSpeed > SUSP_SPEEDMAX ) then { _suspSpeed = SUSP_SPEEDMAX; };

								// suspiciousness for stance
								pr _suspStance = 0;
								switch (stance _unit) do {
									case "CROUCH": { _suspStance = SUSP_CROUCH; _camoCoeffMod = _camoCoeffMod + CAMO_CROUCH; };
					    			case "PRONE": { _suspStance = SUSP_PRONE; _camoCoeffMod = _camoCoeffMod + CAMO_PRONE; };
					    		};

								_suspicion = _suspicion + _suspGear + _suspSpeed + _suspStance;
							};

							// ------------------------------------------- 
							//  I N  V E H I C L E
							// -------------------------------------------
							case true: {
								pr _suspGearVeh = T_GETV("suspGearVeh");
								pr _bodyExposure = T_CALLM0("getBodyExposure");		// get how visible unit is

								if !(gettext (configfile >> "CfgVehicles" >> (typeOf vehicle _unit) >> "faction") == "CIV_F") exitWith {
								_suspicion = 1;
								_hintKeys pushback HK_MILVEH;
								}; // if in military vehicle

								// get distance to nearestEnemy
								pr _distance = -1;
								if !(isNull _nearestEnemy) then { 
									_distance = (position _nearestEnemy) distance (position _unit); 
								};

								// additional penalty for more vehicle passengers
								if (count crew vehicle _unit > 1) then {
									_suspicion = _suspicion + (SUSP_VEH_CREW * (count crew vehicle _unit));
								};

								#ifdef DEBUG 
									_unit setVariable ["distance", _distance];
									_unit setVariable ["bodyExposure", _bodyExposure];
								#endif

								if (!(currentWeapon _unit in g_UM_civWeapons) && _bodyExposure > 0.5) exitWith { _suspicion = 1; _hintKeys pushback HK_WEAPON; };

								/*  Suspiciousness in a civilian vehicle, based on distance to the nearest enemy who sees player unit */
								if (_distance != -1 && _suspGearVeh >= SUSPICIOUS) then {
									// unit's gear is suspicious, and enemy is so close they can see it
									if ( _distance < SUSP_VEH_DIST_MIN && _distance > -1 && _bodyExposure > 0.4 ) exitWith { _suspicion = 1; };

									// scale in suspiciousness as unit gets closer to nearest enemy
									if ( _distance >= SUSP_VEH_DIST_MIN && _distance < SUSP_VEH_DIST && _suspGearVeh >= SUSPICIOUS ) exitWith {
										_suspicion = 0.7 * (_suspicion + ((SUSP_VEH_DIST - _distance) * SUSP_VEH_DIST_MULT));
										if (_suspicion < 1) then { _hintKeys pushback HK_CLOSINGIN; };
									};
								};
							};

						};

					}; // state "UNDERCOVER" end

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 W A N T E D  S T A T E 																											   |
					|	 Player is always non-captive in this state until exit conditions are met. Simplifies calculations and simulates a sense of            | 
					|	 "object permanence" for the AI, so player can't go back to captive by simply dropping their gun while unseen.				   		   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
					case sWANTED: {
						if (T_GETV("stateChanged")) then {
						_unit setVariable [UNDERCOVER_WANTED, true, true];	
						T_SETV("stateChanged", false);
						}; // do once when state changed

						// create marker, kind of like GTA's red circle you have to escape to lose the police
						// only update marker if unit is seen, otherwise no escape possible
						if (T_GETV("bSeen")) then {
							pr _mrkLastHost = createMarkerLocal ["markerWanted", position _unit];
							"markerWanted" setMarkerAlphaLocal 0.0;

							#ifdef DEBUG
								"markerWanted" setMarkerBrushLocal "SOLID";
								"markerWanted" setMarkerAlphaLocal 0.5;
								"markerWanted" setMarkerColorLocal "ColorBlue";
								"markerWanted" setMarkerSizeLocal [WANTED_CIRCLE_RADIUS/2, WANTED_CIRCLE_RADIUS/2];
								"markerWanted" setMarkerShapeLocal "ELLIPSE";
							#endif
						}; 

						_suspicion = 1;

						// Conditions for exiting WANTED state
						if ( ((position _unit) distance2D (getMarkerPos "markerWanted")) > (WANTED_CIRCLE_RADIUS/2)) exitWith { 
							T_CALLM("setState", [sUNDERCOVER]);
							deleteMarkerLocal "markerWanted";
							OOP_INFO_0("No longer WANTED, reason: Left wanted marker radius."); 
						}; // left "wanted marker"

						if ((_timeSeen - time) < TIME_UNSEEN_WANTED_EXIT) exitWith { 
							T_CALLM("setState", [sUNDERCOVER]);
							deleteMarkerLocal "markerWanted";
							OOP_INFO_0("No longer WANTED, reason: Unseen for long enough."); 
						}; // unseen for TIME_UNSEEN_WANTED_EXIT minutes

						if ({alive _x} count units group _nearestEnemy == 0 ) exitWith { 
							T_CALLM("setState", [sUNDERCOVER]);
							deleteMarkerLocal "markerWanted";
							OOP_INFO_0("No longer WANTED, reason: Killed or lost last group that spotted unit."); 
						}; // no unit from group that last spotted unit is alive

					}; // state WANTED end

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 C O M P R O M I S E D  S T A T E 																									   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
					case sCOMPROMISED: {
						T_SETV("stateChanged", false);
						pr _timeCompromised = T_GETV("timeCompromised");

						if !(_bInVeh OR !(time > _timeCompromised)) exitWith {
							T_CALLM("setState", [sUNDERCOVER]);	
							OOP_INFO_0("Leaving COMPROMISED state.");
						};

						_suspicion = 1;

					}; // state "COMPROMISED" end

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 A R R E S T E D  S T A T E 																									   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
					case sARRESTED: {
						T_SETV("stateChanged", false);

					}; // state "ARRESTED" end

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 I N C A P A C I T A T E D  S T A T E 																								   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
					case sINCAPACITATED: {
						T_SETV("stateChanged", false);

						if (activeACE) then { 
							if !(_unit getVariable ["ACE_isUnconscious", false]) then { T_CALLM("setState", [sUNDERCOVER]); };
						};

					}; // state "INCAPACITATED" end

				}; // end FSM

				OOP_INFO_1("hintKeys: %1", _hintKeys);

				// compromise other players in vehicle
				if (_bInVeh && _suspicion >= 1) then {
					if (count crew vehicle _unit > 1) then {
						{
							if (isPlayer _x && alive _x && _x != _unit) then { 
								pr _um = _x getVariable ["undercoverMonitor", ""];
								if (_um != "") then { // Sanity check
									pr _msg = MESSAGE_NEW();
									MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_COMPROMISED);
									CALLM1(_um, "postMessage", _msg);
									OOP_INFO_0("SMON_MESSAGE_COMPROMISED sent to all occupants.");
								};
							};
						} forEach crew vehicle _unit;		
					};
				};

				// set captive status of unit
				pr _args = [_suspicion, _state];
				T_CALLM("calcCaptive", _args);

				// set new camouflage coeffcient 
				pr _camoCoeff =  T_GETV("camoCoeff"); // initial unit-based value
				if (T_GETV("bGhillie")) then { _camoCoeffMod = _camoCoeffMod + CAMO_GHILLIE; };
				_camoCoeff = _camoCoeff * (1 - _camoCoeffMod);
				_unit setUnitTrait ["camouflageCoef", _camoCoeff];

				// update normal UI
				#ifndef DEBUG
				_args = [_unit, _suspicion, _hintKeys];
				CALL_STATIC_METHOD("UndercoverUI", "drawUI", _args); // draw UI
				#endif

				// update debug UI
				#ifdef DEBUG
				_unit setVariable ["suspicion", _suspicion];
				_unit setVariable ["bInVeh", _bInVeh];
				_unit setVariable ["nearestEnemy", _nearestEnemy];
				[_unit] call fnc_UIUndercoverDebug;
				g_rscLayerUndercover cutRsc ["Default", "PLAIN", -1, false];
				#endif

			}; // end SMON_MESSAGE_PROCESS

			// Messaged by onUnitSpotted method (see SensorGroupTargets), when this object's unit is seen by an enemy.
			// Also finds enemy unit closest to punit and store it in variable for SMON_MESSAGE_PROCESS
			case SMON_MESSAGE_BEING_SPOTTED: {

				OOP_INFO_0("Received message: SMON_MESSAGE_BEING_SPOTTED!");

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
				T_SETV("nearestEnemy", _nearestEnemy);

				if (_suspicion >= 1 or !(captive _unit)) then {
					T_CALLM("setState", [sWANTED]);
				}; 
			}; // end SMON_MESSAGE_BEING_SPOTTED

			// messages sent here will temporarily make this object's unit overt 
			case SMON_MESSAGE_COMPROMISED: {
				OOP_INFO_0("Received message: SMON_MESSAGE_COMPROMISED");

				pr _unit = T_GETV("unit");
				T_CALLM("setState", [sCOMPROMISED]);
				T_SETV("timeCompromised", (time + 5));
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
		pr _unit = T_GETV("unit");

		if (_suspicion < 1 && _suspicion >= SUSPICIOUS) then { _unit setVariable [UNDERCOVER_SUSPICIOUS, true, true]; } else { _unit setVariable [UNDERCOVER_SUSPICIOUS, false, true]; };
		if (_suspicion >= 1) then { _unit setCaptive false; } else { _unit setCaptive true; };
		
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

		OOP_INFO_1("setState Method: state set to: %1", T_GETV("state"));
		
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

		if ((uniform _unit in g_UM_ghillies)) then { T_SETV("bGhillie", true); } else { T_SETV("bGhillie", false); };
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
				_unit setVariable [UNDERCOVER_EXPOSED, false, true];
			} else {
				if (_bodyExposure > 0.85) then {
					_unit setVariable [UNDERCOVER_EXPOSED, true, true];
				};
			}; T_SETV("eyePosOldVeh", _eyePosNewVeh);
		};
		T_SETV("bodyExposure", _bodyExposure);
		_bodyExposure
		
	} ENDMETHOD;

ENDCLASS;
