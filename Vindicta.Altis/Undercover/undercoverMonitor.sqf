#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\InGameUI\InGameUI_Macros.h"

#define pr private
#define sUNDERCOVER 0
#define sWANTED 1
#define sCOMPROMISED 2
#define sARRESTED 3
#define sINCAPACITATED 4

#ifndef RELEASE_BUILD
//#define DEBUG_UNDERCOVER_MONITOR
#endif

/*
undercoverMonitor: Changes this object's unit's captive status dynamically based on equipment, behavior, location, and so on.

Date: December 2018
Authors: Marvis, Sparker
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
	VARIABLE("prevState");													// previous state of this unit's undercoverMonitor
	VARIABLE("stateChanged");												// "do once" variable for state changes
	VARIABLE("suspicion");													// unit's final suspiciousness for each interval
	VARIABLE("incrementSusp");												// a temporary variable for suspicion increases over time
	VARIABLE("suspicionBoost");												// A one-time suspicion increment active for the current time interval
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
	VARIABLE("bCaptive");													// true if unit is in arrested state, must be false to leave arrested state
	VARIABLE("camoCoeff"); 													// modified vanilla camouflage coefficient, see: community.bistudio.com/wiki/setUnitTrait
	VARIABLE("bGhillie");													// true if unit is wearing ghillie suit
	VARIABLE("EHLoadout");
	VARIABLE("EHFiredMan");
	VARIABLE("timer");														// Timer which will send SMON_MESSAGE_PROCESS message every second or so
	VARIABLE("inventoryOpen");												// Bool, set from event handlers
	VARIABLE("inventoryContainer");											// Object handle, current inventory container we are accessing
	VARIABLE("eventHandlers");										// Array with inventory EH IDs

	// ------------ N E W ------------

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_unit", objNull, [objNull]]];

		T_SETV("unit", _unit);
		_unit setVariable ["undercoverMonitor", _thisObject];

		// FSM
		T_SETV("state", sUNDERCOVER);
		T_SETV("prevState", sUNDERCOVER);
		T_SETV("stateChanged", true);

		// UM variables
		T_SETV("suspicion", 0);
		T_SETV("suspicionBoost", 0);
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
		T_SETV("bCaptive", false);
		pr _camoCoeff = _unit getUnitTrait "camouflageCoef";
		T_SETV("camoCoeff", _camoCoeff);
		T_SETV("bGhillie", false);
		T_SETV("inventoryOpen", false);
		T_SETV("inventoryContainer", objNull);

		T_SETV("eventHandlers", []);

		// Global unit variables
		_unit setVariable [UNDERCOVER_EXPOSED, true, true];					// GLOBAL: true if player unit's exposure is above some threshold while he's in a vehicle
		_unit setVariable [UNDERCOVER_WANTED, false, true];					// GLOBAL: if true player unit is hostile and "setCaptive false"
		_unit setVariable [UNDERCOVER_SUSPICIOUS, false, true];				// GLOBAL: true if player is suspicious (suspicion variable >= SUSPICIOUS #define)													

		// make everyone ACE medic, temp fix I guess 
		_unit setVariable ["ACE_medical_medicClass", 2, true];

		CALLM0(_thisObject, "calcGearSuspicion");							// evaluate suspicion of unit's equipment
		_unit setCaptive true;

		// CBA event handler for checking player unit's equipment suspiciousness
		pr _EH_loadout = ["loadout", {
			params ["_unit", "_newLoadout"];
			pr _uM = _unit getVariable ["undercoverMonitor", ""];
			if (_uM != "") then { CALLM0(_uM, "calcGearSuspicion"); };
    	}] call CBA_fnc_addPlayerEventHandler;
		T_SETV("EHLoadout", _EH_loadout);

    	// event handler to check if unit fired weapon
    	pr _EH_firedMan = _unit addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
			pr _uM = _unit getVariable ["undercoverMonitor", ""];
			SETV(_uM, "timeHostility", (time +TIME_HOSTILITY));
		}];
		T_SETV("EHFiredMan", _EH_firedMan);

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
		#ifdef DEBUG_UNDERCOVER_MONITOR
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

		// Add inventory event handlers
		pr _ID = _unit addEventHandler ["InventoryClosed", {
			params ["_unit", "_container"];
			pr _thisObject = _unit getVariable ["undercoverMonitor", ""];
			if (_thisObject != "") then {
				T_SETV("inventoryOpen", false);
				T_SETV("inventoryContainer", objNull);
			};
		}];
		T_GETV("eventHandlers") pushBack ["InventoryClosed", _ID];

		pr _ID = _unit addEventHandler ["InventoryOpened", {
			params ["_unit", "_container"];
			pr _thisObject = _unit getVariable ["undercoverMonitor", ""];
			if (_thisObject != "") then {
				T_SETV("inventoryOpen", true);
				T_SETV("inventoryContainer", _container);
			};
		}];
		T_GETV("eventHandlers") pushBack ["InventoryOpened", _ID];

		// Take/put event handlers
		private _ehid = player addEventHandler ["Take", 
		{
			params ["_unit", "_container", "_item"];

			pr _thisObject = _unit getVariable ["undercoverMonitor", ""];
			if (_thisObject != "") then {
				pr _type = typeOf _container;
				pr _sideNum = getNumber (configFile >> "CfgVehicles" >> _type >> "side");
				// Only give boost if we are accessing military containers/vehicles
				if (_type isKindOf "ThingX" || _sideNum in [0, 1, 2]) then {
					pr _boost = T_GETV("suspicionBoost");
					T_SETV("suspicionBoost", _boost + SUSP_INV_TAKE_PUT_BOOST);
				};
			};
		}];
		T_GETV("eventHandlers") pushBack ["Take", _ID];

		private _ehid = player addEventHandler ["Put", 
		{
			params ["_unit", "_container", "_item"];

			pr _thisObject = _unit getVariable ["undercoverMonitor", ""];
			if (_thisObject != "") then {
				pr _type = typeOf _container;
				pr _sideNum = getNumber (configFile >> "CfgVehicles" >> _type >> "side");
				// Only give boost if we are accessing military containers/vehicles
				if (_type isKindOf "ThingX" || _sideNum in [0, 1, 2]) then {
					pr _boost = T_GETV("suspicionBoost");
					T_SETV("suspicionBoost", _boost + SUSP_INV_TAKE_PUT_BOOST);
				};
			};
		}];
		T_GETV("eventHandlers") pushBack ["Put", _ID];


	} ENDMETHOD;


	// ------------ D E L E T E ------------

	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		// Delete the timer
		pr _timer = T_GETV("timer");
		DELETE(_timer);
		pr _unit = T_GETV("unit");
		_unit setVariable ["undercoverMonitor", nil];

		// Delete event handlers
		{
			_unit removeEventHandler _x;
		} forEach (T_GETV("eventHandlers"));

		/*
		// No need to set them to nil manually, it gets cleared on its own by OOP light
		// Let it be here like a monument
		T_SETV("EHLoadout", nil);
		T_SETV("EHFiredMan", nil);
		T_SETV("unit", nil);
		T_SETV("state", nil);
		T_SETV("prevState", nil);
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
		T_SETV("bCaptive", nil);
		T_SETV("camoCoeff", nil);
		T_SETV("bGhillie", nil);
		T_SETV("timer", nil);
		*/

	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMsgLoopPlayerChecks
	} ENDMETHOD;


	// ------------ H A N D L E  M E S S A G E ------------

	METHOD("handleMessage") {
		params [["_thisObject", "", [""]] , ["_msg", [], [[] ]]];
		pr _msgType = _msg select MESSAGE_ID_TYPE;

		switch (_msgType) do {

			// 	M A I N  U N D E R C O V E R  P R O C E S S
			case SMON_MESSAGE_PROCESS: {
				pr _state = T_GETV("state");
				//OOP_INFO_1("undercoverMonitor START state: %1", _state);

				pr _unit = T_GETV("unit");

				pr _suspicionArr = [[0, "default"]];			
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

				// check if vanilla or ACE unconscious
				if ( _unit getVariable ["ACE_isUnconscious", false] OR (lifeState _unit == "INCAPACITATED")) then { T_CALLM("setState", [sINCAPACITATED]); _hintKeys pushback HK_INCAPACITATED; };		// ACE unconscious
									
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
							deleteMarkerLocal "markerWanted";
							T_SETV("stateChanged", false);
						}; // do once when state changed

						if (!(currentWeapon _unit in g_UM_civWeapons) && currentWeapon _unit != "" && !(_bInVeh)) exitWith { 
							_suspicionArr pushBack [1, "On foot & weapon"]; _hintKeys pushback HK_WEAPON; 
						};

						pr _timeHostility = T_GETV("timeHostility");
						if (time < _timeHostility) exitWith { _suspicionArr pushBack [1, "Hostility"]; _hintKeys pushback HK_HOSTILITY; };
	
						// check if unit is in allowed area
						pr _pos = getPos _unit;
				 		pr _loc = CALL_STATIC_METHOD("Location", "getLocationAtPos", [_pos]); // It will return the lowermost location, so if it's a police station in a city, it will return police station, not a city.
				 		if (_loc != "") then { 	
							if ( CALLM(_loc, "isInAllowedArea", [_pos]) ) then { // Will always return true for city or roadblock, regardless of actual allowed area marker area
								_bInAllowedArea = true; _hintKeys pushback HK_ALLOWEDAREA;
							} else {
								// Suspiciousness for being in a military area depends on the campaign progress
								pr _progress = CALLM0(gGameModeServer, "getCampaignProgress"); // 0..1
								pr _multiplier = 1+2*_progress;
								_suspicionArr pushBack [_multiplier*SUSP_MIL_LOCATION, "In military area"];
								_hintKeys pushBack HK_MILAREA;
							};
				 		};

						switch (_bInVeh) do {

							// ------------------------------------------- 
							//  O N   F O O T 
							// -------------------------------------------
							case false: {
								_unit setVariable [UNDERCOVER_EXPOSED, true, true];	

								if (animationState _unit in g_UM_undercoverAnims) exitWith { _suspicionArr pushBack [-1, "Surrender"]; _hintKeys pushback HK_SURRENDER; }; // Hotfix for ACE surrendering

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

								// suspiciousness for inventory
								pr _suspInv = 0;
								if (T_GETV("inventoryOpen")) then {
									pr _cont = T_GETV("inventoryContainer");

									pr _type = typeOf _cont;
									/* // https://community.bistudio.com/wiki/CfgVehicles_Config_Reference#side
									#define NO_SIDE -1
									#define EAST 0			// (Russian)
									#define WEST 1			// (NATO)
									#define RESISTANCE 2	// Guerilla 
									#define CIVILIAN 3
									#define NEUTRAL 4
									#define ENEMY 5
									#define FRIENDLY 6
									#define LOGIC 7
									*/
									// When player opens his own inv, the container is a "GroundWeaponHolder" which has side 3 (civilian)
									// "ThingX" type corresponds to supply crates
									pr _sideNum = getNumber (configFile >> "CfgVehicles" >> _type >> "side");
									if (_type isKindOf "ThingX" || _sideNum in [0, 1, 2]) then {
										_suspInv = SUSP_INV_MIL;
									} else {
										_suspInv = SUSP_INV_CIV;
									};

									_hintKeys pushBack HK_INVENTORY;
								};

								_suspicionArr pushBack [_suspGear, "On foot equipment"]; 
								_suspicionArr pushBack [_suspSpeed, "Movement speed"]; 
								_suspicionArr pushBack [_suspStance, "Stance"];
								_suspicionArr pushBack [_suspInv, "Open inventory"];
							};

							// ------------------------------------------- 
							//  I N  V E H I C L E
							// -------------------------------------------
							case true: {
								pr _suspGearVeh = T_GETV("suspGearVeh");
								pr _bodyExposure = T_CALLM("getBodyExposure", [_unit]);		// get how visible unit is

								if !(gettext (configfile >> "CfgVehicles" >> (typeOf vehicle _unit) >> "faction") == "CIV_F") exitWith {
									_suspicionArr pushBack [1, "Military vehicle"];
									_hintKeys pushback HK_MILVEH;
								}; // if in military vehicle

								// get distance to nearestEnemy
								pr _distance = -1;
								if !(isNull _nearestEnemy) then { 
									_distance = (position _nearestEnemy) distance (position _unit); 
								};
								
								#ifdef DEBUG_UNDERCOVER_MONITOR 
									_unit setVariable ["distance", _distance];
									_unit setVariable ["bodyExposure", _bodyExposure];
									OOP_INFO_0("Distance and bodyExposure set to player");
								#endif

								pr _crewSuspMod = SUSP_VEH_CREW_MOD;
								if ((count crew vehicle _unit) > 1) then {
									{
										if (UNDERCOVER_IS_UNIT_EXPOSED(_x)) then { 
											_crewSuspMod = _crewSuspMod + SUSP_VEH_CREW_MOD;
										};
									} forEach (crew vehicle _unit);
								};

								if (!(currentWeapon _unit in g_UM_civWeapons) && _bodyExposure > 0.7) then {  };

								/*  Suspiciousness in a civilian vehicle, based on distance to the nearest enemy who sees player unit */
								if (_distance != -1 && _suspGearVeh >= SUSPICIOUS) then {
									if (_distance <= SUSP_VEH_DIST) then {
										_arg = (SUSP_VEH_DIST - _distance) * ((SUSP_VEH_DIST_MULT + (_crewSuspMod * (_crewSuspMod / SUSP_VEH_CREW_MOD))) / SUSP_VEH_DIST);
										_suspicionArr = [];
										_suspicionArr pushBack [_arg, "Distance-based, in vehicle"];
										_unit setVariable ["suspDistVeh", _arg];
									};
								};
							};
						};

						if ((vehicle _unit nearRoads SUSP_NOROADS) isEqualTo [] ) then { 
							_suspicionArr pushBack [SUSP_OFFROAD, "Offroad"];
							_hintKeys pushback HK_OFFROAD;
						}; // offroad suspicion penalty

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

							#ifdef DEBUG_UNDERCOVER_MONITOR
								"markerWanted" setMarkerBrushLocal "SOLID";
								"markerWanted" setMarkerAlphaLocal 0.5;
								"markerWanted" setMarkerColorLocal "ColorBlue";
								"markerWanted" setMarkerSizeLocal [WANTED_CIRCLE_RADIUS/2, WANTED_CIRCLE_RADIUS/2];
								"markerWanted" setMarkerShapeLocal "ELLIPSE";
							#endif
						}; 

						_suspicionArr pushBack [1, "WANTED STATE"];

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
						if (T_GETV("stateChanged")) then {	
							T_SETV("stateChanged", false);
							_unit setVariable [UNDERCOVER_WANTED, false, true];
							deleteMarkerLocal "markerWanted";
						}; // do once when state changed

						pr _timeCompromised = T_GETV("timeCompromised");
						_hintKeys pushBack HK_COMPROMISED;

						if !(_bInVeh OR !(time > _timeCompromised)) exitWith {
							pr _prevState = T_GETV("state");
							
							if (_prevState == sCOMPROMISED) then { 
								T_CALLM("setState", [sUNDERCOVER]); 
							} else {
								if (T_GETV("bSeen")) then {
									T_CALLM("setState", [sWANTED]);	
								} else { 
									T_CALLM("setState", [_prevState]);	
								};
							}; // don't want to be trapped in compromised state

							OOP_INFO_0("Leaving COMPROMISED state.");
						};

						_suspicionArr pushBack [1, "COMPROMISED STATE"];

					}; // state "COMPROMISED" end

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 A R R E S T E D  S T A T E 																									   	   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
					case sARRESTED: {
						if (T_GETV("stateChanged") && !(T_GETV("bCaptive"))) then {
							T_SETV("stateChanged", false);
							_unit setVariable [UNDERCOVER_WANTED, false, true];
							_unit setVariable [UNDERCOVER_EXPOSED, false, true]; // prevent unit being picked up by SensorGroupTargets again
							deleteMarkerLocal "markerWanted";
							T_SETV("bCaptive", true);
							// TODO: Sparker hide/show action behavior
							pr _addAction = [_unit] call fnc_UM_addActionUntieLocal;
							_unit setVariable ["timeArrested", time+10, true];
						}; // do once when state changed

						// exit arrested state
						if !(T_GETV("bCaptive")) then {
							player playMoveNow "acts_aidlpsitmstpssurwnondnon_out";
							T_CALLM("setState", [sUNDERCOVER]);
							_unit setVariable [UNDERCOVER_TARGET, false, true];
						};

						_suspicionArr pushBack [-1, "ARRESTED STATE"];
						_hintKeys pushBack HK_ARRESTED;

					}; // state "ARRESTED" end

					/*
					--------------------------------------------------------------------------------------------------------------------------------------------
					|	 I N C A P A C I T A T E D  S T A T E 																								   |
					--------------------------------------------------------------------------------------------------------------------------------------------
					*/
					case sINCAPACITATED: {
						if (T_GETV("stateChanged")) then {
							T_SETV("stateChanged", false);
							_unit setVariable [UNDERCOVER_WANTED, false, true];
							deleteMarkerLocal "markerWanted";
						}; // do once when state changed

						if (activeACE) then { 
							if !(_unit getVariable ["ACE_isUnconscious", false]) then { 
								T_CALLM("setState", [sUNDERCOVER]); 
								OOP_INFO_0("ACE_isUnconscious is false, leaving state sINCAPACITATED");
							};
						};

						/*if (lifeState _unit == "HEALTHY") then { 
							T_CALLM("setState", [sUNDERCOVER]);
							OOP_INFO_0("lifeState _unit == 'HEALTHY', leaving state sINCAPACITATED");
						};*/

					}; // state "INCAPACITATED" end

				}; // end FSM

				//OOP_INFO_1("hintKeys: %1", _hintKeys);

				
				// set captive status of unit
				pr _args = [_suspicionArr, _state];
				T_CALLM("calcCaptive", _args);

				pr _suspicion = T_GETV("suspicion");
				// compromise other players in vehicle
				/*
				if (_bInVeh && _suspicion >= 1) then {
					if (count crew vehicle _unit > 1) then {
						{
							if (isPlayer _x && alive _x && _x != _unit) then { 
								REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitCompromised", [_x], _x, false); //classNameStr, methodNameStr, extraParams, targets, JIP
							};
						} forEach crew vehicle _unit;		
					};
				};
				*/

				// set new camouflage coeffcient 
				pr _camoCoeff =  T_GETV("camoCoeff"); // initial unit-based value
				if (T_GETV("bGhillie")) then { _camoCoeffMod = _camoCoeffMod + CAMO_GHILLIE; };
				_camoCoeff = _camoCoeff * (1 - _camoCoeffMod);
				_unit setUnitTrait ["camouflageCoef", _camoCoeff];

				// update normal UI
				#ifndef DEBUG_UNDERCOVER_MONITOR
				_args = [_unit, _suspicion, _hintKeys];
				CALL_STATIC_METHOD("UndercoverUI", "drawUI", _args); // draw UI
				#endif

				// update debug UI
				#ifdef DEBUG_UNDERCOVER_MONITOR
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

				T_SETV("bSeen", true);
				T_SETV("timeSeen", (time + TIME_SEEN));

				// find closest enemy watching player
				pr _grpDistances = [];
				{
					pr _tempDist = (position _x) distance (position _unit);
					_grpDistances pushBack _tempDist;
				} forEach units _msgData;

				if (count _grpDistances > 0) then {
					pr _minDist = selectMin _grpDistances;
					pr _minDistIndex = _grpDistances find _minDist;

					pr _nearestEnemy = (units _msgData) select _minDistIndex;
					T_SETV("nearestEnemy", _nearestEnemy);

					if !(captive _unit) then {
						T_CALLM("setState", [sWANTED]);
					};
				} else {
					T_SETV("nearestEnemy", objNull);
				};
			}; // end SMON_MESSAGE_BEING_SPOTTED

			// messages sent here will temporarily make this object's unit overt 
			case SMON_MESSAGE_COMPROMISED: {
				OOP_INFO_0("Received message: SMON_MESSAGE_COMPROMISED");

				pr _unit = T_GETV("unit");
				T_CALLM("setState", [sCOMPROMISED]);
				pr _prevState = T_GETV("state");
				T_SETV("prevState", _prevState);
				T_SETV("timeCompromised", (time + 10));
			}; // end SMON_MESSAGE_COMPROMISED

			// messaged when player is being arrested
			case SMON_MESSAGE_ARRESTED: {
				T_CALLM("setState", [sARRESTED]);
			}; // end SMON_MESSAGE_ARRESTED

			// delete dead unit's undercoverMonitor
			case SMON_MESSAGE_DELETE: {
				// remove CBA loadout event handler
				pr _EH_loadout = T_GETV("EHLoadout");
		 		["loadout", _EH_loadout] call CBA_fnc_removePlayerEventHandler;

				// remove vanilla fired event handler
				pr _unit = T_GETV("unit");
				pr _EH_firedMan = T_GETV("EHFiredMan");
				_unit removeEventHandler ["FiredMan", _EH_firedMan];

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
		ActionUnitArrest remoteExecutes this on this computer when an enemy group is arresting the player.
		This function resolves undercoverMonitor of player and posts a message to it.
	*/
	STATIC_METHOD("onUnitArrested") {
		params ["_thisClass", ["_unit", objNull, [objNull]]];
		pr _uM = _unit getVariable ["undercoverMonitor", ""];
		if (_uM != "") then { // Sanity check
			if !(GETV(_uM, "bCaptive")) then {
				pr _msg = MESSAGE_NEW();
				MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_ARRESTED);
				CALLM1(_um, "postMessage", _msg);
			};
		};
		OOP_INFO_0("onUnitArrested called.");
	} ENDMETHOD;

	/* 
		setUnitFree remoteExecutes this on this computer when an enemy group is arresting the player.
		This function resolves undercoverMonitor of player and posts a message to it.
	*/
	STATIC_METHOD("setUnitFree") {
		params ["_thisClass", ["_unit", objNull, [objNull]]];
		pr _uM = _unit getVariable ["undercoverMonitor", ""];
		if (_uM != "") then { // Sanity check
			SETV(_uM, "bCaptive", false);
		};
		OOP_INFO_0("setUnitFree called");
	} ENDMETHOD;

	/* 
		Other player's computers remoteExecute this on this computer to make this player overt.
		This function resolves undercoverMonitor of player and posts a message to it.
	*/
	STATIC_METHOD("onUnitCompromised") {
		params ["_thisClass", ["_unit", objNull, [objNull]]];
		pr _um = _unit getVariable ["undercoverMonitor", ""];
		if (_um != "") then { // Sanity check
			pr _msg = MESSAGE_NEW();
			MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_COMPROMISED);
			CALLM1(_um, "postMessage", _msg);
		};
	} ENDMETHOD;


	/*
		Method: calcCaptive
		Sets captive status of unit based on state variable and suspicion variable.

		Parameters: 0: _state 			- (Integer) current state of UM
					1: _suspicionArr 	- (Array) array with suspicion values of unit, format: [[<suspicion value>, "debug description"], ...]

	*/
	METHOD("calcCaptive") {
		params [["_thisObject", "", [""]], ["_suspicionArr", [], [[0, ""]]], ["_state", sUNDERCOVER]];
		pr _unit = T_GETV("unit");
		
		pr _suspicion = 0;
		{
			pr _var = _x select 0;

			if (_var == -1) then { _suspicion = 0; }
			else {
				_suspicion = _suspicion + _var;
			};
		} forEach _suspicionArr;

		// Aply the temporary boost
		_suspicion = _suspicion + T_GETV("suspicionBoost");
		T_SETV("suspicionBoost", 0); // It only lasts for this interval

		if (_suspicion >= 1) then { 
			_unit setVariable [UNDERCOVER_SUSPICIOUS, false, true];
			_unit setCaptive false;
		} else { 
			if (_suspicion >= SUSPICIOUS) then { 
				_unit setVariable [UNDERCOVER_SUSPICIOUS, true, true]; 
				_unit setCaptive true;  
			} else {
				_unit setVariable [UNDERCOVER_SUSPICIOUS, false, true];
				_unit setCaptive true; 
			};
		};

		T_SETV("suspicion", _suspicion);

		#ifdef DEBUG_UNDERCOVER_MONITOR
		_unit setVariable ["suspicionArr", _suspicionArr];
		_unit setVariable ["suspicion", _suspicion];
		#endif
		
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
		params ["_thisObject", ["_unit", objNull, [objNull]]];

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
				_unit setVariable [UNDERCOVER_EXPOSED, true, true];
			}; T_SETV("eyePosOldVeh", _eyePosNewVeh);
		};
		T_SETV("bodyExposure", _bodyExposure);
		_bodyExposure
		
	} ENDMETHOD;

	// Boosts suspicion for this interval
	STATIC_METHOD("boostSuspicion") {
		params [P_THISCLASS, P_OBJECT("_unit"), P_NUMBER("_value")];
		pr _thisObject = _unit getVariable ["undercoverMonitor", ""];
		if (_thisObject != "") then {
			pr _boost = T_GETV("suspicionBoost");
			T_SETV("suspicionBoost", _boost + _value);
		};
	} ENDMETHOD;

ENDCLASS;
