#include "..\OOP_Light\OOP_Light.h"
#include "..\CivilianPresence\CivilianPresence.hpp"
#include "..\Location\Location.hpp"
#include "..\AI\Commander\AICommander.hpp"
#include "..\AI\Commander\LocationData.hpp"

#define pr private


params [["_civ",objNull,[objNull]]];

if(isnull _civ)exitWith{};


// Stop unit
// Must call it on the server
[_civ, player, true] remoteExecCall ["CivPresence_fnc_talkToServer", 2];

if(selectRandom[true,false])then{

	[player,"Hi! Have you seen any military in the area?", _civ] call  Dialog_fnc_hud_createSentence;

	sleep 1;

	if (!alive _civ) exitWith {
		[_civ,"I think i see the light! No wait its AAWWW",player] call  Dialog_fnc_hud_createSentence;

	};

	[_civ,"Let me think...",player] call  Dialog_fnc_hud_createSentence;

	sleep (0.5+random 1);
	
	// Check nearby locations
	private _locs = CALLSM0("Location", "getAll");
	private _locsNear = _locs select {
		CALLM0(_x, "getPos") distance player < 5000
	};

	if (count _locsNear == 0) then {
		[_civ,"No, I don't know anything, let me go!",player] call  Dialog_fnc_hud_createSentence;
	} else {
		[_civ,"I think I know something...",player] call  Dialog_fnc_hud_createSentence;
		diag_log format ["---- Civilian told about locations:"];
		{
			//[CLD_UPDATE_LEVEL_TYPE_UNKNOWN, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
			// Civilians know about police stations in cities
			// And have limited knowledge about military facilities around
			pr _type = CALLM0(_x, "getType");
			private _updateLevel = -666;
			private _accuracyRadius = 0;
			private _dist = CALLM0(_x, "getPos") distance player;
			private _distCoeff = 0.1; // How much accuracy radius increases with  distance
			diag_log format ["   %1 %2", _x, _type];

			switch (_type) do {
				case LOCATION_TYPE_CITY: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; };
				case LOCATION_TYPE_POLICE_STATION: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; };
				case LOCATION_TYPE_ROADBLOCK: {
					if (GETV(_x, "isBuilt")) then {_updateLevel = CLD_UPDATE_LEVEL_SIDE;
					_accuracyRadius = 50+_dist*_distCoeff; };
				};
				case LOCATION_TYPE_CAMP: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
				case LOCATION_TYPE_BASE: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
				case LOCATION_TYPE_OUTPOST: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
			};

			if (_updateLevel != -666) then {
				diag_log format ["    adding to database"];
				private _commander = CALLSM1("AICommander", "getCommanderAIOfSide", playerSide);
				CALLM2(_commander, "postMethodAsync", "updateLocationData", [_x ARG _updateLevel ARG sideUnknown ARG false ARG false ARG _accuracyRadius]);
			};
		} forEach _locsNear;
	};
}else{

	[player,"Hello", _civ] call  Dialog_fnc_hud_createSentence;

	sleep 1;

	[_civ,"Ow, hey there", player] call  Dialog_fnc_hud_createSentence;

	sleep 2;
	
	[player,"Do you know any nearby AAF military facilities?", _civ] call  Dialog_fnc_hud_createSentence;

	sleep 1;
	
	[_civ,"Yes, I know some...", player] call  Dialog_fnc_hud_createSentence;

	sleep 1;
	
	[player,"Thanks!", _civ] call  Dialog_fnc_hud_createSentence;

	sleep 1;
	[_civ,"No problem, bye", player] call  Dialog_fnc_hud_createSentence;

	sleep 3;
};


//remove player from list so unit can walk again
// Must call it on the server
[_civ, player, false] remoteExecCall ["CivPresence_fnc_talkToServer", 2];

true;