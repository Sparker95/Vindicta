#include "..\CivilianPresence\common.hpp"
#include "..\OOP_Light\OOP_Light.h"

#define pr private

// Bail-out confition, if someone dies or whatever
#define __CHECK_EXIT_COND ((!alive _civ) || (!alive player) || ( (player distance _civ) > 10))

// Each character adds this amount of time of sleep between sentences
#define SLEEP_TIME_COEFF 0.0625

// Macro to sleep depending on text length
#define __SLEEP(txt) sleep (SLEEP_TIME_COEFF * (count txt))

// Macro to boost suspicion on each sentence
#define __BOOST_SUSP CALLSM2("undercoverMonitor", "boostSuspicion", player, 0.2 + (random 0.1))

params [["_civ",objNull,[objNull]], ["_mode", "", [""]]];

if(isnull _civ)exitWith{};


// Stop unit
// Must call it on the server
[_civ, player, true] remoteExecCall ["CivPresence_fnc_talkToServer", 2];

switch (_mode) do {
	case "talk": {
		pr _text = "Hi, can I talk to you?";
		[player, _text, _civ] call  Dialog_fnc_hud_createSentence;
		sleep 5;
	};

	case "intel": {
		// Mark him as he is talking now
		_civ setVariable [CP_VAR_IS_TALKING, true, true]; // Broadcast that to everyone

		pr _locs = _civ getVariable [CP_VAR_KNOWN_LOCATIONS, []];
		pr _text = "Hello! Do you know any military places in the area?";
		[player, _text, _civ] call  Dialog_fnc_hud_createSentence;
		__BOOST_SUSP;
		
		__SLEEP(_text);
		if (__CHECK_EXIT_COND) exitWith {};

		if (count _locs == 0) then {
			_text = "No, I am sure there are none within several kilometers";
			[_civ, _text,player] call  Dialog_fnc_hud_createSentence;
			__BOOST_SUSP;
			__SLEEP(_text);
			if (__CHECK_EXIT_COND) exitWith {};

			[player,"All right, thank you, bye", _civ] call  Dialog_fnc_hud_createSentence;
		} else {
			_text = "Yeah, I know some places like that...";
			[_civ, _text,player] call  Dialog_fnc_hud_createSentence;
			__BOOST_SUSP;
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
					selectRandom ["very close", "within 400 meters", "right over here", "five-minute walk from here"]
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

				pr _posString = if (_type == LOCATION_TYPE_POLICE_STATION) then {
					pr _locCities = CALLSM1("Location", "getLocationsAtPos", _locPos) select {
						CALLM0(_x, "getType") == LOCATION_TYPE_CITY
					};
					if (count _locCities > 0) then {
						format ["at %1", CALLM0(_locCities select 0, "getName")];
					} else {
						format ["to the %1", _bearingString];
					};
				} else {
					format ["to the %1", _bearingString];
				};

				pr _text = format ["%1 %2 %3, %4", _intro, _typeString, _posString, _distanceString];
				[_civ,_text,player] call  Dialog_fnc_hud_createSentence;
				__BOOST_SUSP;

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
					case LOCATION_TYPE_AIRPORT: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; _accuracyRadius = 50+_dist*_distCoeff; };
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
			__BOOST_SUSP;
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
			__BOOST_SUSP;
		};
	};

	case "agitate": {
		// Mark him as he is talking now
		_civ setVariable [CP_VAR_IS_TALKING, true, true]; // Broadcast that to everyone

		// Player suggests to join the rebels
		pr _text = selectRandom [
			"Hey man, consider joining the rebellion, we need you",
			"You know there's a rebel movement, right? Would you like to join?",
			"The rebel movement needs people like you",
			"Join the rebels if you want to liberate this place"
		];
		[player,_text, _civ] call  Dialog_fnc_hud_createSentence;
		__BOOST_SUSP;

		__SLEEP(_text);
		if (__CHECK_EXIT_COND) exitWith {};

		if (!(_civ getVariable [CP_VAR_AGITATED, false])) then { // If not agitated yet

			pr _text = selectRandom [
				"Allright, I will think about it",
				"Yeah, I'm tired of these nazis, I'll consider joining",
				"Thanks, I'll keep it in mind",
				"I will join some time later, thanks",
				"I have nothing to lose any more... sure..."
			];
			[_civ,_text,player] call  Dialog_fnc_hud_createSentence;
			__BOOST_SUSP;

			__SLEEP(_text);
			if (__CHECK_EXIT_COND) exitWith {};

			// Now unit is agitated and suspicious
			_civ setVariable [CP_VAR_AGITATED, true, true];
			_civ setVariable ["bSuspicious", true, true];
			// Also increase activity in the city
			CALLSM("AICommander", "addActivity", [CALLM0(gGameMode, "getEnemySide") ARG getPos player ARG (7+random(7))]);
			} else {
				pr _text = selectRandom [
					"Sure, I know about that already",
					"I already know about it, thanks",
					"I have already heard about it, yes",
					"Yes, I know it already"
				];
				[_civ,_text,player] call  Dialog_fnc_hud_createSentence;
				__BOOST_SUSP;
		};

	};
};


//remove player from list so unit can walk again
// Must call it on the server
//if (_civ getVariable CP_VAR_IS_TALKING) then {
	[_civ, player, false] remoteExecCall ["CivPresence_fnc_talkToServer", 2];
//};

// Unit is not talking any more
_civ setVariable [CP_VAR_IS_TALKING, false, true]; // Broadcast that to everyone

true;