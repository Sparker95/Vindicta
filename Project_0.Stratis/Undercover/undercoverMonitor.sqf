#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\modCompatBools.sqf"

// SAVED for later: if ((vehicle player) isEqualTo player) 

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
#define SUSP_HEADGEAR 0.3				// suspicion gained for mil headgear
#define SUSP_FACEWEAR 0.05				// suspicion gained for mil facewear
#define SUSP_BACKPACK 0.3				// suspicion gained for mil backpack
#define SUSP_NVGS 0.5					// suspicion gained for NVGs
#define DATE_TIME ((dateToNumber date))

	// ----------------------------------------------------------------------
	// |                       F U N C T I O N S 							|
	// ----------------------------------------------------------------------

/*  ["<t color='#ff0000' size = '1.5'>Overt</t>",-1,0,4,1,0,789] spawn BIS_fnc_dynamicText;

	["<t color='#008000' size = '1.5'>Incognito</t>",-1,0,4,1,0,789] spawn BIS_fnc_dynamicText; */

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

		if !((uniform _unit in civUniforms) or (uniform _unit == "")) then { _suspGear = _suspGear + SUSP_UNIFORM; };
		if !((headgear _unit in civHeadgear) or (headgear _unit == "")) then { _suspGear = _suspGear + SUSP_HEADGEAR; }; 
		if !((goggles _unit in civFacewear) or (goggles _unit == "")) then { _suspGear = _suspGear + SUSP_FACEWEAR; };
		if !((vest _unit in civVests) or (vest _unit == "")) then { _suspGear = _suspGear + SUSP_VEST; };
		if !((backpack _unit in civBackpacks) or (backpack _unit == "")) then { _suspGear = _suspGear + SUSP_BACKPACK; };
		if (hmd player != "") then { _suspGear = _suspGear + SUSP_NVGS; systemChat format ["nvgs %1", _suspGear]; };

		_suspGear;
	};

	fnc_suspWeap = {
		params ["_unit"];

		if ( currentWeapon _unit != "" ) exitWith { 1.0; };
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
		_unit setCaptive true; 												// initially, make unit undercover to avoid problems
		_unit setVariable ["suspGear", 0.0];								// suspiciousness of the unit's gear 
		_unit setVariable ["suspicion", 0.0];								// overall suspicion
		_unit setVariable ["_lastSpottedTimes", [1, 2, 3, 4, 5]]; 			// recorded times since the player was last seen by an enemy. If all indices are equal, player is unseen
		_unit setVariable ["timeUnseen", 0];								// sum amount of time unit has not been seen by an enemy
		_unit setVariable ["bWanted", false];								// true if unit is "wanted" (overt)				
		_unit setVariable ["bSuspicious", false];							// true if unit is currently suspicious
		_unit setVariable ["bSeen", false];									// true if unit is currently seen by an enemy

		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_PROCESS);
		pr _updateInterval = 1.0;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		pr _timer = NEW("Timer", _args);
		SETV(_thisObject, "timer", _timer);

		// More efficient way of checking player equipment suspiciousness only when loadout changes, requires CBA
		if (activeCBA) then { 
			["loadout", { params ["_unit", "_newLoadout"];
			pr _suspGearTemp = [_unit] call fnc_suspGear; 
			_unit setVariable ["suspGear", _suspGearTemp];
        	systemChat "Loadout changed.";
    	}] call CBA_fnc_addPlayerEventHandler;
	};

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
		
			// This will be called every time interval to run calculations
			case SMON_MESSAGE_PROCESS: {
				pr _unit = GETV(_thisObject, "unit");
				pr _bWanted = _unit getVariable "bWanted";
				pr _bSuspicious = _unit getVariable "bSuspicious";
				pr _suspicion = _unit getVariable "suspicion";
				pr _bSeen = _unit getVariable "bSeen";

				// conditions for returning from "wanted" back to "incognito"
				if (_bWanted) then {
					if !(_bSeen) then {
						if ((_unit getVariable "timeUnseen") > 20 ) then {
							_unit setCaptive true; 
							_unit setVariable ["bWanted", false]; _unit setVariable ["bSuspicious", true]; 
							_unit setVariable ["suspicion", SUSPICIOUS]; 
							["<t color='#008000' size = '1.5'>Incognito</t>",-1,0,4,1,0,789] call BIS_fnc_dynamicText; 
							systemChat "Incognito."; 
						};
					};
				};

				if (!(isNull objectParent _unit) && !(_bWanted)) exitWith {
				};


				// real-time evaluation of player's suspiciousness based on movement, stance, etc. Not necessary if player is "wanted" (overt)
				if !(_bWanted) then {

					_suspicion = 0.0;
					_suspGear = _unit getVariable "suspGear";					

					if !(activeCBA) then { _suspGear = [_unit] call fnc_suspGear; } else { _suspGear = _unit getVariable "suspGear"; };

  					pr _suspStance = [_unit] call fnc_suspStance;
  					pr _suspSpeed = [_unit] call fnc_suspSpeed;
					pr _suspWeap = [_unit] call fnc_suspWeap;  
					_suspGear = [_unit] call fnc_suspGear;
					
					if (_bSuspicious) then { _suspicion = _suspicion + SUSPICIOUS; };
    				_suspicion = _suspicion + _suspGear + _suspStance + _suspSpeed + _suspWeap;
    				if ( _suspicion > 1 ) then { _suspicion = 1.0; }; // max suspicion 1.0

    				_unit setVariable ["suspicion", _suspicion];
    				[_unit, _suspicion] call fnc_setUndercover; 
				};
			};
			
			// This will be called when a player is being spotted, it is send from groupMonitor
			case SMON_MESSAGE_BEING_SPOTTED: {

				pr _msgData = _msg select MESSAGE_ID_DATA;
				pr _unit = GETV(_thisObject, "unit");
				pr _bSeen = _unit getVariable "bSeen";
				pr _timeUnseen = _unit getVariable "timeUnseen";
				pr _playerinVeh = false;
				pr _lastSpottedTimes = _unit getVariable "_lastSpottedTimes";
				pr _enemyUnit = 0;
				pr _knows = 0;

				pr _found = (units _msgData) findIf {(_x targetKnowledge _unit) select 2 > 0 };
				if (_found != -1) then { _enemyUnit = (units _msgData) select _found; } else {
						_found = (units _msgData) findIf {(_x targetKnowledge vehicle _unit) select 2 > 0 };
						_enemyUnit = (units _msgData) select _found;
						_playerinVeh = true;
				};
				
				if (_playerinVeh) then { 
					_knows = (_enemyUnit targetKnowledge vehicle _unit) select 2;
					pr _distance = vehicle _unit distance _enemyUnit;
					systemChat format ["Distance: %1", _distance];
				};

				if !(_playerinVeh) then {
					_knows = (_enemyUnit targetKnowledge _unit) select 2;
					pr _distance = _unit distance _enemyUnit;
					systemChat format ["Distance: %1", _distance];
				};

				// Check if player is seen or unseen
				pr _tempArray = [_knows, _knows, _knows, _knows, _knows];
				if (_tempArray isEqualTo _lastSpottedTimes) exitWith { 
					hint format ["NOT SPOTTED"]; _unit setVariable ["bSeen", false]; 
					_timeUnseen = _timeUnseen + 1; 
					_unit setVariable ["timeUnseen", _timeUnseen]; 
					_msgData forgetTarget _unit;
					_msgData forgetTarget vehicle _unit;
				 };

				if !(_tempArray isEqualTo _lastSpottedTimes && !(_bSeen)) then { 
					hint format ["SPOTTED"]; _unit setVariable ["bSeen", true]; 
					_unit setVariable ["timeUnseen", 0]; 
				};

				_lastSpottedTimes pushBack _knows;
				_lastSpottedTimes deleteAt 0;
				_unit setVariable ["_lastSpottedTimes", _lastSpottedTimes];
				systemChat format ["Last spotted: %1!", _lastSpottedTimes];


					// condition for going from "incognito" to "wanted"
					pr _suspicion = _unit getVariable "suspicion";	
					pr _bWanted = _unit getVariable "bWanted";

					if (!(_bWanted) && (_suspicion >= 1) && _bSeen) exitWith {
								["<t color='#ff0000' size = '1.5'>Wanted</t>",-1,0,8,0,0,789] call BIS_fnc_dynamicText; 
								_unit setVariable ["bWanted", true];
								systemChat "Wanted";	
					};			
			};
		};
		
		false // message not handled
	} ENDMETHOD;

ENDCLASS;