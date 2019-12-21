#include "..\CivilianPresence\CivilianPresence.hpp"
#include "..\OOP_Light\OOP_Light.h"

#define pr private

// Bail-out confition, if someone dies or whatever
#define __CHECK_EXIT_COND ((!alive _civ) || (!alive player))

// Each character adds this amount of time of sleep between sentences
#define SLEEP_TIME_COEFF 0.0625

// Macro to sleep depending on text length
#define __SLEEP(txt) sleep (SLEEP_TIME_COEFF * (count txt))

params [["_civ",objNull,[objNull]], ["_mode", "", [""]]];

if(isnull _civ)exitWith{};


// Stop unit
// Must call it on the server
[_civ, player, true] remoteExecCall ["CivPresence_fnc_talkToServer", 2];

// Mark him as he is talking now
_civ setVariable [CP_VAR_IS_TALKING, true, true]; // Broadcast that to everyone

switch (_mode) do {
	case "intel": {
		pr _locs = _civ getVariable [CP_VAR_KNOWN_LOCATIONS, []];
		pr _text = "Hello! Do you know any military places in the area?";
		[player, _text, _civ] call  Dialog_fnc_hud_createSentence;
		
		__SLEEP(_text);
		if (__CHECK_EXIT_COND) exitWith {};

		if (count _locs == 0) then {
			_text = "No, I am sure there are none within several kilometers";
			[_civ, _text,player] call  Dialog_fnc_hud_createSentence;
			__SLEEP(_text);
			if (__CHECK_EXIT_COND) exitWith {};

			[player,"All right, thank you, bye", _civ] call  Dialog_fnc_hud_createSentence;
		} else {
			_text = "Yeah, I know a some places like that...";
			[_civ, _text,player] call  Dialog_fnc_hud_createSentence;
			__SLEEP(_text);
			if (__CHECK_EXIT_COND) exitWith {};

			// Civilian tells player about all the locations he knows about
			{
				pr _loc = _x;
				pr _type = CALLM0(_loc, "getType");
				pr _locPos = CALLM0(_loc, "getPos");
				pr _bearing = player getDir _locPos;
				pr _distance = player distance2D _locPos;
				pr _bearings = ["North", "North-East", "East", "South-East", "South", "South-West", "West", "North-West"];
				pr _bearingID = (round (_bearing/45)) % 8;

				// Strings
				pr _typeString = CALLSM1("Location", "getTypeString", _type);
				pr _bearingString = _bearings select _bearingID;
				pr _distanceString = if(_distance < 400) then {
					["very close", "within 400 meters", "right over here", "five-minute walk from here"]
				} else {
					if (_distance < 1000) then {
						selectRandom ["not far away", "within a kilometer", "within a mile", "10-minute walk from here"];
					} else {
						selectRandom ["very far", "far away", "more than a mile from here", "more than a kilometer from here"];
					};
				};
				pr _intro = selectRandom [	"There is a ",
											"I know about a",
											"I think there is a",
											"Some time ago I saw a",
											"Friend told me about a",
											"People are nervous about a",
											"People are talking about a",
											"Long time ago there was a",
											"Not sure about the coordinates, there is a"];

				pr _text = format ["%1 %2 to the %3, %4", _intro, _typeString, _bearingString, _distanceString];
				[_civ,_text,player] call  Dialog_fnc_hud_createSentence;

				// Also reveal the location to player's side
				private _updateLevel = -666;
				private _accuracyRadius = 0;
				private _dist = _distance;
				private _distCoeff = 0.22; // How much accuracy radius increases with  distance
				//diag_log format ["   %1 %2", _x, _type];

				switch (_type) do {
					case LOCATION_TYPE_CITY: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; };
					case LOCATION_TYPE_POLICE_STATION: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; };
					case LOCATION_TYPE_ROADBLOCK: {
						_updateLevel = CLD_UPDATE_LEVEL_SIDE;
						_accuracyRadius = 50+_dist*_distCoeff;
					};
					case LOCATION_TYPE_CAMP: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
					case LOCATION_TYPE_BASE: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
					case LOCATION_TYPE_OUTPOST: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
				};

				if (_updateLevel != -666) then {
					//diag_log format ["    adding to database"];
					private _commander = CALLSM1("AICommander", "getAICommander", playerSide);
					CALLM2(_commander, "postMethodAsync", "updateLocationData", [_x ARG _updateLevel ARG sideUnknown ARG false ARG false ARG _accuracyRadius]);
				};

				// Sleep
				__SLEEP(_text);
				if (__CHECK_EXIT_COND) exitWith {};
			} forEach _locs;

			// Civilian has told all he knows about

			// Civilian: I must go
			pr _text = selectRandom [
				"That's all I know",
				"Can't tell you more, I must go now",
				"Sorry man, cops might be onto us, I must leave",
				"We might be watched, I must go now!",
				"It might be dangerous to talk about such things in the street, I must go now!"
			];
			[_civ,_text,player] call  Dialog_fnc_hud_createSentence;
			__SLEEP(_text);
			if (__CHECK_EXIT_COND) exitWith {};

			// Player: ok, bye
			pr _text = selectRandom [
				"No problem, bye",
				"Thanks for the help, bye",
				"Yes, I understand, bye",
				"Very good, thanks, bye"
			];
			[player,_text, _civ] call  Dialog_fnc_hud_createSentence;
		};
	};

	case "agitate": {

	};
};


//remove player from list so unit can walk again
// Must call it on the server
[_civ, player, false] remoteExecCall ["CivPresence_fnc_talkToServer", 2];

// Unit is not talking any more
_civ setVariable [CP_VAR_IS_TALKING, false, true]; // Broadcast that to everyone

true;