#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\UndercoverUI\UndercoverUI_Macros.h"

/*
Undercover Monitor: Determines if the enemy should identify a player as
a hostile or a civilian by changing the player unit's captive status.

TODO:

Date: December 2018
Author: Sparker, Marvis
*/

gMsgLoopPlayerChecks = NEW("MessageLoop", []);
CALL_METHOD(gMsgLoopPlayerChecks, "setDebugName", ["Undercover thread"]);

#define pr private
//#define DEBUG

	// ----------------------------------------------------------------------
	// |                       S Q F  F U N C T I O N S 					|
	// ----------------------------------------------------------------------

	fnc_UM_suspSpeed = { 
		params ["_unit"];
		pr _suspSpeed = (vectorMagnitude velocity _unit) * 0.06;
		if ( _suspSpeed > SUSP_SPEEDMAX ) then { _suspSpeed = SUSP_SPEEDMAX; };
		_suspSpeed;
	};

	// increases suspicion for suspicious behavior and returns it
	fnc_UM_incSuspBehavior = { 
		params ["_unit"];
		pr _susp = _unit getVariable "incrementSusp";
		_susp = _susp + SUSP_INCREMENT;
		_unit setVariable ["incrementSusp", _susp];
		_susp;
	};

	fnc_UM_removeWanted = {
		params ["_unit"];
		deleteMarkerLocal "mrkLastHostility";
		_unit setVariable [UNDERCOVER_WANTED, false, true];
		_unit setVariable ["removeWanted", false];
	};

	// set unit's body exposure
	fnc_UM_bodyExposure = { 
		params ["_unit"];

		pr _bodyExposure = _unit getVariable "bodyExposure";
		pr _eyePosNewVeh = (vehicle _unit) worldToModelVisual (_unit modelToWorldVisual (_unit selectionPosition "head"));
		pr _eyePosOldVeh = _unit getVariable "eyePosOldVeh";
		pr _eyePosOld = _unit getVariable "eyePosOld";

		// bodyExposure and eyePos
		if ((_eyePosOldVeh vectorDistance _eyePosNewVeh) > 0.15) then {
			_bodyExposure = [20, 120, 0, 360, _unit] call fnc_getVisibleSurface;
			_unit setVariable ["bodyExposure", _bodyExposure];

			// Limit body exposure to more usable values, set bExposed variable
			if (_bodyExposure < 0.12) then {
				_bodyExposure = 0.0;
				_unit setVariable [UNDERCOVER_EXPOSED, false, true];
			} else {
				if (_bodyExposure > 0.85) then {
					_bodyExposure = 1;
					_unit setVariable [UNDERCOVER_EXPOSED, true, true];
				};
			}; _unit setVariable ["eyePosOldVeh", _eyePosNewVeh]; // bodyExposure and eyePos
		};
		_bodyExposure;
	};


	fnc_UM_suspGear = {
		params ["_unit"];

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

		_unit setVariable ["suspGear", _suspGear];
		_unit setVariable ["suspGearVeh", _suspGearVeh]; // equipment we think is visible in a car (e.g. no backpack visible)
	};

	// ----------------------------------------------------------------------
	// |                       M A I N  C L A S S                           |
	// ----------------------------------------------------------------------

CLASS("undercoverMonitor", "MessageReceiver");

	VARIABLE("unit"); // Unit for which this script is running (player)
	VARIABLE("timer"); // Timer which will send SMON_MESSAGE_PROCESS message every second or so

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_unit", objNull, [objNull]]];

		// Unit (player) variables
		SETV(_thisObject, "unit", _unit);
		_unit setVariable ["undercoverMonitor", _thisObject];
		_unit setVariable [UNDERCOVER_EXPOSED, false, true];				// GLOBAL: true if player unit's exposure is above some threshold while he's in a vehicle
		_unit setVariable [UNDERCOVER_WANTED, false, true];					// GLOBAL: if true player unit is hostile and "setCaptive false"
		_unit setVariable [UNDERCOVER_SUSPICIOUS, false, true];				// GLOBAL: true if player is suspicious (suspicion variable >= SUSPICIOUS #define)
		_unit setVariable [UNDERCOVER_SUSPICION, 0, true];					// GLOBAL: suspicion variable for this unit, set each interval
		_unit setVariable ["suspicion", 0];									// final suspiciousness of player		
		_unit setVariable ["timeSeen", 0];
		_unit setVariable ["timeHostility", 0];
		_unit setVariable ["incrementSusp", 0];								// suspicion value that increases for suspicious behavior being performed while seen	
		_unit setVariable ["bSeen", false];									// true if unit is currently seen by an enemy	
		_unit setVariable ["compromised", false];							// true if player was compromised (made overt) by another script							
		_unit setVariable ["timeCompromised", 0];							// time when unit was compromised in vehicle						
		_unit setVariable ["nearestEnemyDist", -1];							// distance to nearest unit in group that has spotted player
		_unit setVariable ["nearestEnemy", objNull];						// enemy closest to player, taken from group that has spotted player last
		_unit setVariable ["bodyExposure", 1.0];							// value for how exposed player is inside current vehicle seat
		_unit setVariable ["eyePosOld", [0, 0, 0]];
		_unit setVariable ["eyePosOldVeh", [0, 0, 0]];

		// animations that force you undercover (unconscious, cuffed, etc)
		g_UM_undercoverAnims = [
			"ace_amovpercmstpssurwnondnon",
			"AmovPercMstpSnonWnonDnon_Ease"
		];

		[_unit] call fnc_UM_suspGear; 										// evaluate suspicion of unit's equipment
		_unit setCaptive true;

		// CBA event handler for checking player unit's equipment suspiciousness
		["loadout", {
			params ["_unit", "_newLoadout"];
			[_unit] call fnc_UM_suspGear;
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
		SETV(_thisObject, "timer", _timer);

	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------

	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		// Delete the timer
		pr _timer = GETV(_thisObject, "timer");
		pr _unit = GETV(_thisObject, "unit");
		_unit setVariable ["undercoverMonitor", nil];
		DELETE(_timer);
	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMsgLoopPlayerChecks
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                     H A N D L E  M E S S A G E                     |
	// ----------------------------------------------------------------------

	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[] ]] ];

		// Unpack the message
		pr _msgType = _msg select MESSAGE_ID_TYPE;

		switch (_msgType) do {

			// executed every interval: real-time evaluation of player unit's suspicion/suspiciousness
			case SMON_MESSAGE_PROCESS: {
				pr _unit = GETV(_thisObject, "unit");
				pr _bSeen = _unit getVariable "bSeen";
				pr _compromised = _unit getVariable "compromised";
				pr _bInVeh = false;
				pr _bInAllowedArea = false;
				pr _suspicion = 0;
				pr _camouflage = 0;																	// value subtracted from camouflage coefficient trait
				pr _timeHostility = _unit getVariable "timeHostility";
				pr _timeSeen = _unit getVariable "timeSeen";
				pr _timeCompromised = _unit getVariable "timeCompromised";
				pr _nearestEnemy = _unit getVariable "nearestEnemy"; 								// enemy closest to player, from group sent to SMON_MESSAGE_BEING_SPOTTED
				pr _incrementSusp = _unit getVariable "incrementSusp";
				pr _hintKeys = [];																	// array with suspiciousness values for UI 
				if (!(isNull objectParent _unit)) then { _bInVeh = true; }; 						// is player unit in vehicle?
				_unit setVariable [UNDERCOVER_SUSPICIOUS, false, true];
				_unit setVariable [UNDERCOVER_EXPOSED, true, true];

				if ((time > _timeCompromised) or !(_bInVeh)) then { _unit setVariable ["compromised", false]; };

				// condition for resetting player to unseen by enemy
				if (time > _timeSeen) then { 
					_unit setVariable ["bSeen", false];
					pr _timeSeen = _unit getVariable "timeSeen";
					if (_timeSeen > 0) then { _timeSeen = 0; };
					_timeSeen = _timeSeen - 1;
					_unit setVariable ["timeSeen", _timeSeen];
					if (_timeSeen < -2) then { _unit setVariable ["incrementSusp", 0]; };
				};

				0 call { // start exitWith scope

					// player has surrendered
					/*if (currentWeapon _unit == "" && animationState _unit == "AmovPincMstpSnonWnonDnon") exitWith { 
						if (([_unit] call fnc_UM_suspSpeed) == 0) then { _suspicion = 0; };
					};*/

					if (animationState _unit in g_UM_undercoverAnims) exitWith { _suspicion = 0; _hintKeys pushback HK_SURRENDER; }; // Hotfix for ACE surrendering
					if ( _unit getVariable ["ACE_isUnconscious", false] ) exitWith { _suspicion = 0; _hintKeys pushback HK_INCAPACITATED; };

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	W A N T E D   S T A T E 																											   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/

					if (UNDERCOVER_IS_UNIT_WANTED(_unit)) exitWith { // start WANTED routine

						OOP_INFO_0("WANTED!");

						// create marker, kind of like GTA's red circle you have to escape to lose the police
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

						}; // only update marker if unit is seen, otherwise no escape possible

						_suspicion = 1;

						// conditions for going back to UNDERCOVER state
						if ( ((position _unit) distance2D (getMarkerPos "mrkLastHostility")) > WANTED_CIRCLE_RADIUS) exitWith { [_unit] call fnc_UM_removeWanted; OOP_INFO_0("No longer WANTED, reason: Left wanted radius."); };
						if ((_timeSeen - time) < TIME_UNSEEN_WANTED_EXIT) exitWith { [_unit] call fnc_UM_removeWanted; OOP_INFO_0("No longer WANTED, reason: Unseen for long enough."); };
						if ({alive _x} count units group _nearestEnemy == 0 ) exitWith { [_unit] call fnc_UM_removeWanted; OOP_INFO_0("No longer WANTED, reason: Killed last group that spotted player."); }; // no unit from group that last spotted player unit is alive

					}; // end WANTED routine

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 I N  V E H I C L E  A N D  O N  F O O T																							   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/

				 	if (time < _timeHostility) exitWith { _suspicion = 1; _hintKeys pushback HK_HOSTILITY; };

					pr _pos = getPos _unit;
				 	pr _loc = CALL_STATIC_METHOD("Location", "getLocationAtPos", [_pos]);
				 	if (_loc != "") then { 	
				 		if ( CALLM(_loc, "isInAllowedArea", [_pos]) ) then { 
				 			_bInAllowedArea = true; _hintKeys pushback HK_ALLOWEDAREA; 
				 		} else { 
				 			_suspicion = 1; 
				 		};
				 	};	// check for being at enemy location and allowed area
				 	if (_suspicion >= 1) exitWith { _suspicion = 1; }; // exitWith for being inside outpost
					if ( (vehicle _unit nearRoads SUSP_NOROADS) isEqualTo [] ) then { 
						_suspicion = _suspicion + SUSP_OFFROAD;
						_hintKeys pushback HK_OFFROAD;
					}; // offroad suspicion penalty

					pr _enemyBehavior = -1;
					pr _distance = -1;
					if !(isNull _nearestEnemy) then { 
						_distance = (position _nearestEnemy) distance (position _unit); 
						_enemyBehavior = behaviour _nearestEnemy;
					}; // get distance to nearestEnemy

					#ifdef DEBUG 
						_unit setVariable ["distance", _distance];
					#endif

					switch (_bInVeh) do {

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 O N  F O O T  O N L Y																												   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
						case false: {
							if !(currentWeapon _unit in g_UM_civWeapons) then { _suspicion = 1; _hintKeys pushback HK_WEAPON; };
							pr _suspGear = _unit getVariable "suspGear"; // full equipment suspiciousness as determined by CBA "loadout" event handler
							if (_suspGear > 0) then { _hintKeys pushback HK_SUSPGEAR; };
							pr _suspSpeed = [_unit] call fnc_UM_suspSpeed;
							pr _suspBehaviour = 0;

							pr _suspStance = 0;
							switch (stance _unit) do {
								case "CROUCH": { _suspStance = SUSP_CROUCH; };
					    		case "PRONE": { _suspStance = SUSP_PRONE; };
					    	};

					    	// supicious behaviours
					    	if (animationState _unit == "AinvPercMstpSnonWnonDnon") then { _suspBehaviour = _suspBehaviour + ([_unit] call fnc_UM_incSuspBehavior); _hintKeys pushback HK_SUSPBEHAVIOR; };
					    	if (currentWeapon _unit in g_UM_suspWeapons) then { _suspBehaviour = _suspBehaviour + ([_unit] call fnc_UM_incSuspBehavior); _hintKeys pushback HK_SUSPBEHAVIOR; };
							if (_bInAllowedArea) then {
							if (_suspStance > 0) then { _suspBehaviour = _suspBehaviour + ([_unit] call fnc_UM_incSuspBehavior); _hintKeys pushback HK_SUSPBEHAVIOR; };
							};

							_suspicion = _suspicion + _suspGear + _suspSpeed + _suspStance + _suspBehaviour;
						};

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 I N  V E H I C L E  O N L Y																										   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
						case true: {
							pr _suspGearVeh = _unit getVariable "suspGearVeh"; 	// in vehicle equipment suspiciousness as determined by CBA "loadout" event handler
							if (_suspGearVeh >= 1) then { _hintKeys pushback HK_SUSPGEARVEH; };

							if !(gettext (configfile >> "CfgVehicles" >> (typeOf vehicle _unit) >> "faction") == "CIV_F") then {
								_suspicion = 1;
								_hintKeys pushback HK_MILVEH;
							}; // if in military vehicle

							// Always re-evaluate body exposure while in a vehicle
							pr _bodyExposure = [_unit] call fnc_UM_bodyExposure;
							if (!(currentWeapon _unit in g_UM_civWeapons) && _bodyExposure > 0.69) exitWith { _suspicion = 1; _hintKeys pushback HK_WEAPON; };

							/*  Suspiciousness in a civilian vehicle, based on distance to the nearest enemy who sees player unit */
							// make sure there is an actual enemy and a distance
							if (_distance != -1 && _suspGearVeh >= SUSPICIOUS) then {

								// player unit's gear is suspicious, and player is so close they can see it
								if ( _distance < SUSP_VEH_DIST_MIN && _distance > -1 && _bodyExposure > 0.4 ) exitWith { _suspicion = 1; };

								// scale in suspiciousness as player unit gets closer to nearest enemy
								if ( _distance >= SUSP_VEH_DIST_MIN && _distance < SUSP_VEH_DIST && _suspGearVeh >= SUSPICIOUS ) exitWith {
									_suspicion = 0.7 * (_suspicion + ((SUSP_VEH_DIST - _distance) * SUSP_VEH_DIST_MULT));
									if (_suspicion < 1) then { _hintKeys pushback HK_CLOSINGIN; };
								};
							};
						}; // end case: player unit IS in vehicle
					};  // end switch "is player unit in vehicle?"
				}; // end exitWith scope

				if (_compromised) then { _suspicion = 1; };
				if ( _suspicion >= SUSPICIOUS && _suspicion < 1 ) then { _unit setVariable [UNDERCOVER_SUSPICIOUS, true, true]; };
				if ( _suspicion >= 1 ) then { _unit setCaptive false; } else { _unit setCaptive true; };
				_unit setVariable ["suspicion", _suspicion];
				_unit setVariable [UNDERCOVER_SUSPICION, _suspicion, true];

				// compromise other players in vehicle
				// important because AI will not shoot at vehicles with any one captive player!
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

				OOP_INFO_1("HINT KEYS: %1", _hintKeys);

				// update debug UI
				#ifdef DEBUG
				[_unit] call fnc_UIUndercoverDebug;
				g_rscLayerUndercover cutRsc ["Default", "PLAIN", -1, false];
				#endif

				// update normal UI
				#ifndef DEBUG
				pr _args = [_unit, _suspicion, _hintKeys];
				CALL_STATIC_METHOD("UndercoverUI", "drawUI", _args); // draw UI
				#endif

			}; // end SMON_MESSAGE_PROCESS

			// Finds enemy unit closest to player unit and store it in variable for SMON_MESSAGE_PROCESS
			case SMON_MESSAGE_BEING_SPOTTED: {

				pr _msgData = _msg select MESSAGE_ID_DATA;
				pr _unit = GETV(_thisObject, "unit");
				pr _suspicion = _unit getVariable "suspicion";
				_unit setVariable ["bSeen", true];
				_unit setVariable ["timeSeen", time + TIME_SEEN];

				pr _grpDistances = [];

				{
					pr _tempDist = (position _x) distance (position _unit);
					_grpDistances pushBack _tempDist;
				} forEach units _msgData;

				pr _minDist = selectMin _grpDistances;
				pr _minDistIndex = _grpDistances find _minDist;

				pr _nearestEnemy = (units _msgData) select _minDistIndex;
				_unit setVariable ["nearestEnemy", _nearestEnemy];

				if (_suspicion >= 1 or !(captive _unit)) then {
					 _unit setVariable [UNDERCOVER_WANTED, true, true];
				}; // end SMON_MESSAGE_BEING_SPOTTED
			};

			// messages here will compromise this unit as if spotted while suspicion > 1
			// fixes AI not shooting at vehicle with one captive unit in it
			// sets unit wanted if visually exposed or temporarily not captive if hidden in vehicle
			case SMON_MESSAGE_COMPROMISED: {
				OOP_INFO_0("SMON_MESSAGE_COMPROMISED received.");

				pr _unit = GETV(_thisObject, "unit");
				_unit setVariable ["compromised", true];
				_unit setVariable ["timeCompromised", time + 4];
			}; // end SMON_MESSAGE_COMPROMISED

			// delete dead unit's undercoverMonitor
			case SMON_MESSAGE_DELETE: {
				DELETE(_thisObject);
			}; // end SMON_MESSAGE_DELETE
		};

		false
	} ENDMETHOD;

	// SensorGroupTargets remoteExecutes this on player's computer when a group is currently spotting player
	// This function resolves UndercoverMonitor of player and posts a message to it
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

ENDCLASS;
