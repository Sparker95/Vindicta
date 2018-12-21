#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\modCompatBools.sqf"

// Create player's undercover monitor
gMsgLoopUndercover = NEW("MessageLoop", []);
CALL_METHOD(gMsgLoopUndercover, "setDebugName", ["Undercover thread"]);

#define pr private

	// ----------------------------------------------------------------------
	// |                U N D E R C O V E R  D E F I N E S                  |
	// ----------------------------------------------------------------------

#define SUSPICIOUS 0.7					// suspicion gained while being "suspicious" 
#define SUSP_CROUCH 0.1					// suspicion gained for crouching
#define SUSP_PRONE 0.2					// suspicion gained for being prone
#define SUSP_SPEEDMAX 0.35				// max atention gained for movement speed
#define SUSP_SPOT 0.05					// suspicion gained each cycle, while unit is "spotted" by enemy
#define SUSP_UNIFORM 0.7				// suspicion gained for mil uniform
#define SUSP_VEST 0.7					// suspicion gained for mil vest
#define SUSP_NVGS 0.7					// suspicion gained for NVGs
#define SUSP_HEADGEAR 0.7				// suspicion gained for mil headgear
#define SUSP_FACEWEAR 0.05				// suspicion gained for mil facewear
#define SUSP_BACKPACK 0.3				// suspicion gained for mil backpack
#define SUSP_HOSTILITY 30				// SUSP_HOSITILITY x (Interval for this monitor) = amount of time player is overt after hostile action
#define SUSP_VEH_DIST 200				// distance in vehicle, after which suspicious gear starts "fading" in - the closer the more overt player is
#define SUSP_VEH_DIST_OVERT 25			// distance in vehicle, closer than this = instantly overt if in military vehicle or wearing suspicious gear
#define DATE_TIME ((dateToNumber date))

	// ----------------------------------------------------------------------
	// |                       F U N C T I O N S 							|
	// ----------------------------------------------------------------------

	fnc_setUndercover = {
 	params ["_unit", "_suspicion"];

		if ( _suspicion >= 1.0 ) then { _unit setCaptive false; }
  		else { _unit setCaptive true; };
	};

	// Check unit's stance, crouching/prone = bSuspicious
	fnc_suspStance = {
		params ["_unit"];

		switch (stance _unit) do {

    		case "STAND": { 0.0; };
			case "CROUCH": { SUSP_CROUCH; };
    		case "PRONE": { SUSP_PRONE; };
    		case "UNDEFINED": { 0.0; };
    		default { 0.0; };
		};
	
	};

	// Check unit's movement speed, faster = more bSuspicious
	fnc_suspSpeed = {
		params ["_unit"];

		pr _suspSpeed = (vectorMagnitude velocity _unit) * 0.06;

		if ( _suspSpeed > SUSP_SPEEDMAX ) exitWith { SUSP_SPEEDMAX; };
		if ( _suspSpeed < 0.15 ) then { 0.0; } else { _suspSpeed; };
	};

	// Check if unit's equipment is in civilian item whitelist
	fnc_suspGear = {
		params ["_unit"];
		pr _suspGear = 0.0;
		pr _suspGearVeh = 0.0;

		if !((uniform _unit in civUniforms) or (uniform _unit == "")) then { _suspGear = _suspGear + SUSP_UNIFORM; };
		if !((headgear _unit in civHeadgear) or (headgear _unit == "")) then { _suspGear = _suspGear + SUSP_HEADGEAR; }; 
		if !((goggles _unit in civFacewear) or (goggles _unit == "")) then { _suspGear = _suspGear + SUSP_FACEWEAR; };
		if !((vest _unit in civVests) or (vest _unit == "")) then { _suspGear = _suspGear + SUSP_VEST; };
		if (hmd player != "") then { _suspGear = _suspGear + SUSP_NVGS; };

		_suspGearVeh = _suspGearVeh + _suspGear;
		_unit setVariable ["suspGearVeh", _suspGearVeh];

		if !((backpack _unit in civBackpacks) or (backpack _unit == "")) then { _suspGear = _suspGear + SUSP_BACKPACK; };
		
		_suspGear;
	};

	fnc_suspWeap = {
		params ["_unit"];

		if ( currentWeapon _unit in civWeapons ) exitWith { 0.0; };
		if ( currentWeapon _unit != ""  ) exitWith { 1.0; };
		if ( primaryWeapon _unit in civWeapons) exitWith { 0.0; };
		if ( secondaryWeapon _unit in civWeapons) exitWith { 0.0; };
		if ( primaryWeapon _unit != "" ) exitWith { 1.0; };
		if ( secondaryWeapon _unit != "" ) then { 1.0; } else { 0.0; };

	};

	// ----------------------------------------------------------------------
	// |                       M A I N  C L A S S                           |
	// ----------------------------------------------------------------------

CLASS("undercoverMonitor", "MessageReceiver")

	VARIABLE("unit"); // Unit for which this script is running (player)
	VARIABLE("timer"); // Timer which will send SMON_MESSAGE_PROCESS message every second or so
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_unit", objNull, [objNull]]];

		// Unit (player) variables
		SETV(_thisObject, "unit", _unit);
		_unit setVariable ["undercoverMonitor", _thisObject]; 				// Later when you find that a group spots this unit, they can send the messages here
						
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_PROCESS);
		pr _updateInterval = 0.8;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		SETV(_thisObject, "timer", _timer);

		_unit setCaptive true; 												// initially, make unit undercover to avoid problems

		// PLAYER VARIABLES
		_unit setVariable ["suspGear", 0.0];								// suspiciousness of the unit's gear 
		_unit setVariable ["suspicion", 0.0];								// overall suspicion
		_unit setVariable ["_lastSpottedTimes", [1, 2, 3, 4, 5, 6]]; 		// recorded times since the player was last seen by an enemy. If each index is equal to every other index, player is presumed unseen
		_unit setVariable ["timeUnseen", 0];								// sum amount of time unit has not been seen by an enemy
		_unit setVariable ["bWanted", false];								// true if unit is "wanted" (overt)				
		_unit setVariable ["bSuspicious", false];							// true if unit is currently suspicious
		_unit setVariable ["bSeen", false];									// true if unit is currently seen by an enemy
		_unit setVariable ["distance", -1];									// not nearest unit to player, but distance to unit that currently sees player. If no enemy is there, distance is -1
		_unit setVariable ["recentHostility", 0];
		_unit setVariable ["suspGearVeh", 0.0];							
		_unit setVariable ["bInVeh", false];						

		// More efficient way of checking player equipment suspiciousness ("suspicion") only when loadout changes, requires CBA
		if (activeCBA) then {

			["loadout", { 
				params ["_unit", "_newLoadout"];
				pr _suspGearTemp = [_unit] call fnc_suspGear;

				if (typeOf(vehicle _unit) != "") then { _suspGearTemp = _unit getVariable "suspGearVeh"; };

				_unit setVariable ["suspGear", _suspGearTemp];
        		systemChat "Loadout changed.";
    		}] call CBA_fnc_addPlayerEventHandler;
    	};

    	[_unit] spawn fn_UndercoverDebugUI;

    	// Make player overt for SUSP_HOSTILITY x Interval, after hostile action
    	_unit addEventHandler ["Fired", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
			_unit setVariable ["recentHostility", SUSP_HOSTILITY];
		}];

	

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
		gMsgLoopUndercover
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                     H A N D L E  M E S S A G E                     |
	// ----------------------------------------------------------------------
	
	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[] ]] ];
		
		// Unpack the message
		pr _msgType = _msg select MESSAGE_ID_TYPE;
		
		switch (_msgType) do {
		
			// REAL-TIME EVALUATIONS OF PLAYER'S SUSPICIOUSNESS ("SUSPICION"), AND CONDITIONS FOR GOING FROM "WANTED" STATE TO "UNDERCOVER" STATE
			case SMON_MESSAGE_PROCESS: {

				pr _unit = GETV(_thisObject, "unit");

				// PLAYER VARIABLES
				pr _bWanted = _unit getVariable "bWanted";
				pr _bSuspicious = _unit getVariable "bSuspicious";
				pr _suspicion = _unit getVariable "suspicion";
				pr _bSeen = _unit getVariable "bSeen";
				pr _timeUnseen = _unit getVariable "timeUnseen";


				if !(_bSeen) then { _timeUnseen = _timeUnseen + 1; _unit setVariable ["timeUnseen", _timeUnseen]; };
				if (_timeUnseen > 60) then { _unit setVariable ["timeUnseen", 0]; }; 

					// CONDITION FOR GOING FROM "WANTED" TO "UNDERCOVER"
					if (_bWanted) then {
						if !(_bSeen) then {
							pr _timeUnseen = _unit getVariable "timeUnseen";

							if (_timeUnseen > 30 ) then {
								_unit setVariable ["bWanted", false]; _unit setVariable ["bSuspicious", true]; 
								_unit setVariable ["suspicion", SUSPICIOUS]; 
							};
						};
					};


					// REAL-TIME EVALUATION OF PLAYER'S SUSPICIOUSNESS WHILE IN VEHICLE
					if (!(isNull objectParent _unit) && !(_bWanted)) exitWith {

						pr _bInVeh = _unit getVariable "bInVeh";
						pr _suspicion = _unit getVariable "suspicion";
						_unit setVariable ["suspicion", 0.0];
						[_unit, 0.0] call fnc_setUndercover; 
 
						// TODO: IMPLEMENT OPEN/CLOSED SEATS IN VEHICLES
						// TODO: MAKE OTHER PLAYERS AFFECT VEHICLE'S OVERALL SUPICIOUSNESS

							// ONLY CHECK AGAINST CIV VEHICLE ONCE AFTER ENTERING VEHICLE
							if !(_bInVeh) then { 
								if !((typeOf (vehicle _unit)) in civVehs) exitWith { _unit setVariable ["suspicion", 1.0]; [_unit, 1.0] call fnc_setUndercover; 	
								}; 

								_unit setVariable ["bInVeh", true];
							};

							// ADJUST SUSPICIOUSNESS IN VEHICLE BASED ON DISTANCE TO ENEMY WHO SEES PLAYER
							//if (_bSeen) then { 

								pr _distance = _unit getVariable "distance"; // distance to nearest enemy who presently sees player
								pr _suspGear = _unit getVariable "suspGear";

								// EVALUATE GEAR VISIBLE IN SOMETHING LIKE THE HATCHBACK'S DRIVER' SEAT
								if !(activeCBA) then {
									_suspGear = 0.0;
									if !((uniform _unit in civUniforms) or (uniform _unit == "")) then { _suspGear = _suspGear + SUSP_UNIFORM; };
									if !((headgear _unit in civHeadgear) or (headgear _unit == "")) then { _suspGear = _suspGear + SUSP_HEADGEAR; }; 
									if !((goggles _unit in civFacewear) or (goggles _unit == "")) then { _suspGear = _suspGear + SUSP_FACEWEAR; };
									if !((vest _unit in civVests) or (vest _unit == "")) then { _suspGear = _suspGear + SUSP_VEST; };
								};
								// CHECK IF VEHICLE HAS GUNNER WITH SUSPICIOUS EQUIPMENT

								// "YOU'RE ONLY A NORMAL CIVILIAN IN THEIR CAR, NO NEED FOR FURTHER CHECKS"
								if ( _suspGear < 1 ) exitWith { _unit setVariable ["suspicion", 0.0]; [_unit, 0.0] call fnc_setUndercover; };

								// IF IN CIVILIAN VEHICLE, AND MORE THAN SUSP_VEH_DIST AWAY FROM ENEMY SPOTTING PLAYER, PLAYER REMAINS UNDERCOVER
								if ( _distance >= SUSP_VEH_DIST ) exitWith { _unit setVariable ["suspicion", 0.0]; [_unit, 0.0] call fnc_setUndercover; };

								// "PLAYER'S GEAR IS SUSPICIOUS, AND PLAYER IS SO CLOSE THEY CAN SEE IT"
								if ( _distance < 25 && _distance > -1 && _suspGear >= 1 ) exitWith { 
									_unit setVariable ["suspicion", 1.0]; [_unit, 1.0] call fnc_setUndercover; 
								};

								if ( _distance >= 25 && _distance > -1 && _distance < 200 && _suspGear >= 1 ) exitWith { 
									_suspicion = (SUSP_VEH_DIST - _distance) * 0.0055;
									_unit setVariable ["suspicion", _suspicion]; [_unit, _suspicion] call fnc_setUndercover; 
							//};


						};
					};


					// REAL-TIME EVALUATION OF PLAYER'S EQUIPMENT, STANCE, MOVEMENT SPEED, ETC FOR "SUSPICIOUSNESS"
					if !(_bWanted) then {
						pr _recentHostility = _unit getVariable "recentHostility";
						_suspicion = 0.0;
						_suspGear = _unit getVariable "suspGear";
						_unit setVariable ["bInVeh", false]; 
						

						if (_recentHostility > 0) then { 
							_recentHostility = _recentHostility - 1; 
							_unit setVariable ["recentHostility", _recentHostility];
							systemChat "decrease"; };

						if !(activeCBA) then { _suspGear = [_unit] call fnc_suspGear; } else { _suspGear = _unit getVariable "suspGear"; };

  						pr _suspStance = [_unit] call fnc_suspStance;
  						pr _suspSpeed = [_unit] call fnc_suspSpeed;
						pr _suspWeap = [_unit] call fnc_suspWeap;  
					
						if (_bSuspicious) then { _suspicion = _suspicion + SUSPICIOUS; };

    					_suspicion = _suspicion + _suspGear + _suspStance + _suspSpeed + _suspWeap + _recentHostility;

    					_unit setVariable ["suspicion", _suspicion];
    					[_unit, _suspicion] call fnc_setUndercover; 
					};
			};
			
			// CALLED WHEN PLAYER IS CURRENTLY KNOWN BY AN ENEMY GROUP - PLAYER CAN ONLY GO WANTED WHILE SPOTTED
			case SMON_MESSAGE_BEING_SPOTTED: {

				pr _msgData = _msg select MESSAGE_ID_DATA;
				pr _unit = GETV(_thisObject, "unit");

				// PLAYER VARIABLES
				pr _bSeen = _unit getVariable "bSeen";
				pr _bWanted = _unit getVariable "bWanted";
				pr _lastSpottedTimes = _unit getVariable "_lastSpottedTimes";
				pr _suspicion = _unit getVariable "suspicion";

				pr _knownTime = 0.0;

					// ON FOOT
					if (isNull objectParent _unit) then { 
						pr _found = (units _msgData) findIf {(_x targetKnowledge _unit) select 2 > 0 };

						if (_found != -1) then { 
							pr _enemyUnit = (units _msgData) select _found; 
							_knownTime = (_enemyUnit targetKnowledge _unit) select 2; 

							pr _tempArr = [_knownTime, _knownTime, _knownTime, _knownTime, _knownTime, _knownTime];

							pr _distance = _unit distance _enemyUnit;
							_unit setVariable ["distance", _distance];

							if (_tempArr isEqualTo _lastSpottedTimes) then { 

								_unit setVariable ["bSeen", false]; 
								_msgData forgetTarget _unit;
								_msgData forgetTarget vehicle _unit;
								_unit setVariable ["distance", 0];

				 			} else { _unit setVariable ["bSeen", true]; _unit setVariable ["timeUnseen", 0]; };

				 			_lastSpottedTimes pushBack _knownTime;
							_lastSpottedTimes deleteAt 0;
							_unit setVariable ["_lastSpottedTimes", _lastSpottedTimes];
							 
						};
					};

					// IN VEHICLE
					if !(isNull objectParent _unit) then { 
						pr _foundVeh = (units _msgData) findIf {(_x targetKnowledge vehicle _unit) select 2 > 0 };

						if (_foundVeh != -1) then { 
							pr _enemyUnit = (units _msgData) select _foundVeh; 
							_knownTime = (_enemyUnit targetKnowledge vehicle _unit) select 2;

							pr _tempArr = [_knownTime, _knownTime, _knownTime, _knownTime, _knownTime, _knownTime];
							pr _distance = vehicle _unit distance _enemyUnit;
							_unit setVariable ["distance", _distance];

							if (_tempArr isEqualTo _lastSpottedTimes) then {

								_unit setVariable ["bSeen", false]; 
								_msgData forgetTarget vehicle _unit;
								_msgData forgetTarget _unit;
								_unit setVariable ["distance", -1];

				 			} else { 
				 			_unit setVariable ["bSeen", true]; 
				 			_unit setVariable ["timeUnseen", -1]; 
				 			};

				 			_lastSpottedTimes pushBack _knownTime;
							_lastSpottedTimes deleteAt 0;
							_unit setVariable ["_lastSpottedTimes", _lastSpottedTimes];
							 
						};
					};

					// CONDITION FOR GOING OVERT/WANTED
					if (!(_bWanted) && (_suspicion >= 1) && _bSeen) exitWith { 
						_unit setVariable ["bWanted", true];	
					};		
			};
		};
		
		false
	} ENDMETHOD;

ENDCLASS;