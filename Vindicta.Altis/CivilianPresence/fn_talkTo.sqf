#include "..\CivilianPresence\common.hpp"
#include "..\common.h"

#define pr private

// Bail-out confition, if someone dies or whatever
#define __CHECK_EXIT_COND ((!alive _civ) || (!alive player) || ( (player distance _civ) > 10))

// Each character adds this amount of time of sleep between sentences
#define SLEEP_TIME_COEFF 0.0625

// Macro to sleep depending on text length
#define __SLEEP(txt) sleep (SLEEP_TIME_COEFF * (count txt))

// Macro to boost suspicion on each sentence
#define __BOOST_SUSP CALLSM2("undercoverMonitor", "boostSuspicion", player, 0.2 + (random 0.1))

params [["_civ",objNull,[objNull]], P_STRING("_mode")];

if(isnull _civ)exitWith{};


// Stop unit
// Must call it on the server
[_civ, player, true] remoteExecCall ["CivPresence_fnc_talkToServer", 2];

switch (_mode) do {
	case "talk": {
		pr _text = selectRandom [
			"Hey, can I talk to you for a moment?",
			"Hi! Can I talk to you?",
			"Hey, do you have a second?",
			"Hey! Got a minute?",
			"Hey, I'd like to talk to you."];

		[player, _text, _civ] call  Dialog_fnc_hud_createSentence;
		sleep 5;
	};

	case "intel": {
		// Mark him as he is talking now
		_civ setVariable [CP_VAR_IS_TALKING, true, true]; // Broadcast that to everyone

		pr _locs = _civ getVariable [CP_VAR_KNOWN_LOCATIONS, []];
		pr _text = selectRandom [
			"Do you know any military outposts in the area?",
			"Do you know of any military places around here?",
			"Hey, are there any ... you know ... military places near here?",
			"Have you seen any military activity around here?",
			"Do you know any military locations around here?"];

		[player, _text, _civ] call  Dialog_fnc_hud_createSentence;
		__BOOST_SUSP;
		
		__SLEEP(_text);
		if (__CHECK_EXIT_COND) exitWith {};

		if (random 100 < 2) exitWith {
			_text = selectRandom [	"I am nothing but a simulation on some computer.",
									"This all is not real! This is a simulation! What shall we do now?",
									"How can you prove that this world is real? It's all a simulation!",
									"Me and you and this world, we are just a bunch of 1s and 0s!",
									"Help! I don't remember what happened to me 3 minutes ago. I just appeared out of nowhere!!",
									"What has happened? All my furniture is gone and I must sleep on the floor now.",
									"I think therefore I am.",
									"To be is to be perceived.",
									"The only thing I know is that I know nothing",
									"Nothing is enough for the man to whom enough is too little."];
			[_civ, _text, player] call  Dialog_fnc_hud_createSentence;
		};

		if (count _locs == 0) then {
			_text = "No, there aren't any within kilometers of this place.";
			[_civ, _text,player] call  Dialog_fnc_hud_createSentence;
			__BOOST_SUSP;
			__SLEEP(_text);
			if (__CHECK_EXIT_COND) exitWith {};

			[player,"All right, thank you, bye", _civ] call  Dialog_fnc_hud_createSentence;
		} else {
			_text = "Yeah, I know of a few places like that ...";
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
				pr _bearings = ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"];
				pr _bearingID = (round (_bearing/45)) % 8;

				// Strings
				pr _typeString = CALLSM1("Location", "getTypeString", _type);
				pr _bearingString = _bearings select _bearingID;
				pr _distanceString = if(_distance < 400) then {
					selectRandom ["quite close.", "within 400 meters.", "right over here.", "five-minute walk from here."]
				} else {
					if (_distance < 1000) then {
						selectRandom ["not too far away from here.", "within a kilometer.", "10 minute walk from here.", "not far from here at all."];
					} else {
						selectRandom ["very far away.", "pretty far away.", "more than a kilometer from here.", "quite a bit away from here."];
					};
				};
				pr _intro = selectRandom [	"There is a ",
											"I know about a",
											"I think there is a",
											"Some time ago I saw a",
											"A friend told me about a",
											"People are nervous about a",
											"People are talking about a",
											"A long time ago there was a",
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
					// We don't report camps to player
					// case LOCATION_TYPE_CAMP: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
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
				"That's all I can tell you.",
				"I don't know any more than that. I need to go.",
				"Have to be careful out here. I'm going to leave now.",
				"We might be watched, I must go now!",
				"It's dangerous to talk about this out in the open, I have to go!"
			];
			[_civ,_text,player] call  Dialog_fnc_hud_createSentence;
			__BOOST_SUSP;
			__SLEEP(_text);
			if (__CHECK_EXIT_COND) exitWith {};

			// Player: ok, bye
			pr _text = selectRandom [
				"No problem. See you!",
				"Thanks for helping us. See you around!",
				"Yes, I understand. See you!",
				"Perfect, thanks.",
				"That's okay. See you!"
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
			"Hey, consider joining the resistance. We need you.",
			"You know there's a resistance movement, right? Would you like to join us?",
			"Our group needs people like you.",
			"Join us if you want to liberate this place."
		];
		[player,_text, _civ] call  Dialog_fnc_hud_createSentence;
		__BOOST_SUSP;

		__SLEEP(_text);
		if (__CHECK_EXIT_COND) exitWith {};

		if (!(_civ getVariable [CP_VAR_AGITATED, false])) then { // If not agitated yet

			pr _text = selectRandom [
				"Alright, I'm going to think about it.",
				"Yeah, I'm tired of those thugs, I'll consider joining.",
				"Thanks, I'll keep it in mind.",
				"I might join some time later, thanks.",
				"It's not like I have anything left to lose ... sure ...",
				"I thought you'd never ask. I'm in.",
				"You son of a bitch, I'm in!",
				"Those bastards destroyed my village and arrested all my friends. Yes, I will join you.",
				"I'm going to find you as soon as I can. Yes, I'm in.",
				"You know what, I will join."];
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
					"Thanks, I know about that already.",
					"I already know about it, thanks.",
					"I have already heard about it, yes.",
					"Yes, I know.",
					"Shhh ... I know ..."
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