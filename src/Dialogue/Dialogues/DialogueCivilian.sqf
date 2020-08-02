#include "..\common.hpp"
#include "..\..\Location\Location.hpp"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\..\Undercover\UndercoverMonitor.hpp"
#include "..\..\Intel\Intel.hpp"

// Test dialogue class

#define OOP_CLASS_NAME DialogueCivilian
CLASS("DialogueCivilian", "Dialogue")

	// <Civilian> object handle
	VARIABLE("civ");

	// We can incite civilian only once during the dialogue
	// todo it must be stored in Civilian object
	VARIABLE("incited");

	METHOD(new)
		params [P_THISOBJECT,  P_OBJECT("_unit0"), P_OBJECT("_unit1"), P_NUMBER("_clientID")];
		T_SETV("incited", false);

		pr _civ = CALLSM1("Civilian", "getCivilianFromObjectHandle", _unit0);
		T_SETV("civ", _civ);
	ENDMETHOD;

	protected override METHOD(getNodes)
		params [P_THISOBJECT, P_OBJECT("_unit0"), P_OBJECT("_unit1")];
		
		pr _phrasesPlayerAskMilitaryLocations = [
			"Do you know any military outposts in the area?",
			"Do you know of any military places around here?",
			"Hey, are there any ... you know ... military places near here?",
			"Have you seen any military activity around here?",
			"Do you know any military locations around here?"
		];

		pr _phrasesIncite = [
			"Damn police, they keep arresting innocent people!",
			"Those militarist pigs will pay for their crimes!",
			"Yesterday they have arrested my friends' family because of 'terrorist activity' as the police say!",
			"The police took my brother yesterday, you might be next one!",
			"Have you heard about those illegal detention camps? I know a guy who returned from one, horrible place!",
			"We must stay united, or next time police will take one of us for some fake reason!",
			"Police tossed drugs to one of my friends and arrested him! Assholes!",
			"We should seek justice for all the war crimes the military are doing here!",
			"The military are so corrupt! There is no other solution to this any more!"
		];

		pr _phrasesCivilianInciteResponse = [
			"Damn that's horrible!",  "I am shocked to hear this!",
			"You are so right!", "That's horrible!", "We should put an end to this!",
			"Yes! The truth must be exposed!", "Oh really, they don't tell that on TV!",
			"Damn I've never heard of it on the local radio!",
			// Written by Jasperdoit:
			"You're straight up spitting facts there mate! It's about time somebody puts a stop to that, and I for one am up for it!",
			"You're right, they really are corrupt. Lets get to work on some change around here!",
			"They definitely have some stick up their ass, let's show them who the real boss is!",
			"Well there is one solution, and it involves guns and liberation. I'm up for it if you ask me!",
			"I might know a way to fix their attitude! Its about time I get involved in this!",
			"The less control they have, the better! Count me in!"
		];

		pr _phrasesScare = [
			"Get out of here, quick!",
			"Something bad is going to happen here. Better move away!",
			"It's not safe here, run away!",
			"This place is not safe, you better get away!",
			"Sir you better get out of here, quick!",
			"Move out of here! This place is not safe!"
		];

		pr _phrasesIntel = [
			"Do you know if there will be any military maneuvers nearby?",
			"Have you got any idea if the military are planning something?",
			"Any idea if the army is planning something?"
		];

		pr _phrasesAskHelp = [
			"The resistence needs your help! Do you have any building supplies?",
			"Listen, the resistence needs some building supplies, do you have any?"
		];

		pr _phrasesAgreeHelp = [
			"Here, take these construction supplies, that's all I have.",
			"Take these construction supplies, that's all I can help you with."
		];

		pr _phrasesDontSupportResistance = [
			"I can't help you with it.",
			"Sorry I can't help you.",
			"There is nothing I can help you with."
		];

		pr _phrasesDontKnowIntel = [
			"I don't know anything like that.",
			"I am not aware of such information.",
			"Sorry I don't know anything of this kind."
		];

		pr _array = [
			//NODE_SENTENCE("", TALKER_PLAYER, g_phrasesPlayerStartDialogue),
			NODE_SENTENCE("", TALKER_NPC, ["Sure!" ARG "Yes?" ARG "How can I help you?"]),
			
			// Options: 
			NODE_OPTIONS("node_options", ["opt_locations" ARG "opt_intel" ARG "opt_incite" ARG "opt_askContribute" ARG "opt_scare" ARG "opt_time" ARG "opt_bye"]),

			// Option: ask about military locations
			NODE_OPTION("opt_locations", _phrasesPlayerAskMilitaryLocations),
			NODE_CALL("", "subroutineTellLocations"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: ask about intel
			NODE_OPTION("opt_intel", selectRandom _phrasesIntel),
			NODE_JUMP_IF("", "node_tellIntel", "knowsIntel", []),
			NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesDontKnowIntel),
			NODE_JUMP("", "node_anythingElse"),

			NODE_CALL("node_tellIntel", "subroutineTellIntel"),
			NODE_JUMP("", "node_options"),

			// Option: incite civilian
			NODE_OPTION("opt_incite", _phrasesIncite),
			NODE_JUMP_IF("", "node_alreadyIncited", "isIncited", []),	// If already incited
			NODE_SENTENCE("", TALKER_NPC, _phrasesCivilianInciteResponse),
			NODE_CALL_METHOD("", "inciteCivilian", []),
			NODE_SENTENCE("", TALKER_PLAYER, "Tell it to others!"),
			NODE_JUMP("", "node_options"),

			NODE_SENTENCE("node_alreadyIncited", TALKER_NPC, "I know! It's dangerous to discuss this."),
			NODE_JUMP("", "node_options"),

			// Option: ask for contribution
			NODE_OPTION("opt_askContribute", selectRandom _phrasesAskHelp),
			NODE_JUMP_IF("", "node_alreadyContributed", "hasContributed", []),
			NODE_JUMP_IF("", "node_giveBuildResources", "supportsResistance", []),
			NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesDontSupportResistance),
			NODE_JUMP("", "node_anythingElse"),

			NODE_CALL_METHOD("node_giveBuildResources", "giveBuildResources", []),
			NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesAgreeHelp),
			NODE_JUMP("", "node_anythingElse"),

			NODE_SENTENCE("node_alreadyContributed", TALKER_NPC, "Sorry I gave all I could already!"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: scare civilian
			NODE_OPTION("opt_scare", _phrasesScare),
			NODE_CALL_METHOD("", "scareCivilian", []),
			NODE_END(""),

			// Option: ask about time
			NODE_OPTION("opt_time", "What time is it?"),
			NODE_SENTENCE_METHOD("", TALKER_NPC, "sentenceTime"),
			NODE_SENTENCE("", TALKER_PLAYER, "Thanks!"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: leave
			NODE_OPTION("opt_bye", "Bye! I must leave now."),
			NODE_SENTENCE("", TALKER_NPC, ["Bye!" ARG "Good bye!" ARG "See you!"]),
			NODE_END(""),

			// Genertic 'Anything else?' reply after the end of some option branch
			NODE_SENTENCE("node_anythingElse", TALKER_NPC, "Anything else?"),
			NODE_JUMP("", "node_options") // Go back to options
		];

		T_CALLM1("generateLocationsNodes", _array); // Extra nodes are appended to the end
		pr _civ = T_GETV("civ");
		pr _loc = GETV(_civ, "loc");
		T_CALLM2("generateIntelNodes", _array, _loc);

		_array;
	ENDMETHOD;

	METHOD(generateLocationsNodes)
		params [P_THISOBJECT, P_ARRAY("_nodes")];

		OOP_INFO_0("generateLocationsNodes");

		// Resolve which locations are known
		pr _unit = T_GETV("unit0");
		private _locs = CALLSM0("Location", "getAll");
		private _locsNear = _locs select {
			pr _type = CALLM0(_x, "getType");
			pr _dist = CALLM0(_x, "getPos") distance _unit;
			(_dist < 4000) &&
			(_type != LOCATION_TYPE_CITY)
		};

		OOP_INFO_1("  Nearby locations: %1", _locsNear);

		_locsCivKnows = _locsNear select {
			pr _type = CALLM0(_x, "getType");
			pr _dist = CALLM0(_x, "getPos") distance _unit;
			// Civilian can't tell about everything, but they surely know about police stations and locations which are very close
			(!(_type in [LOCATION_TYPE_CAMP, LOCATION_TYPE_RESPAWN])) && // Array of types the civilian can't know about
			{
				(random 10 < 5) ||
				{_type == LOCATION_TYPE_POLICE_STATION}
				// If it's very close, civilians will surely tell about it
			}
		};

		OOP_INFO_1("  Locations known by civilian: %1", _locsCivKnows);

		_a = [];
		_a pushBack NODE_SENTENCE("subroutineTellLocations", TALKER_NPC, ["Let me think..." ARG "Give me a second..." ARG "One moment. Let me think..."]);
		
		if (count _locsCivKnows == 0) then {
			pr _str = "No, there aren't any within kilometers of this place.";
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _str);
		} else {
			pr _str = "Yes, I know of a few places like that ...";
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _str);

			{ // forEach _locsCivKnows;
				pr _loc = _x;
				pr _type = CALLM0(_loc, "getType");
				pr _locPos = CALLM0(_loc, "getPos");
				pr _bearing = _unit getDir _locPos;
				pr _distance = _unit distance2D _locPos;
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
				
				_a pushBack NODE_SENTENCE("", TALKER_NPC, _text);
				// todo add player's suspiciousness

				// After this sentence is said, reveal the location
				pr _args = [_loc, _type, _distance];
				_a pushBack NODE_CALL_METHOD("", "revealLocation", _args);

			} forEach _locsCivKnows;

			// Civilian: I must go
			_strMustGo = selectRandom [
				"That's all I can tell you.",
				"I don't know anything else.",
				"That's all I know."
			];
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _strMustGo);
		};

		// This dialogue part is called as a subroutine
		// Therefore we must return back
		_a pushBack NODE_RETURN("");

		// Combine the node arrays
		_nodes append _a;

	ENDMETHOD;

	METHOD(generateIntelNodes)
		params [P_THISOBJECT, P_ARRAY("_nodes"), P_OOP_OBJECT("_loc")];

		OOP_INFO_2("generateIntelNodes: location: %1 %2", _loc, CALLM0(_loc, "getName"));

		_a = [];
		_a pushBack NODE_SENTENCE("subroutineTellIntel", TALKER_NPC, ["Let me think..." ARG "Give me a second..." ARG "One moment. Let me think..."]);

		pr _phrasesIntelSource = [
			"A friend told me about a",
			"A friend said he heard from somebody about a",
			"I heard some guys talk about a",
			"I think I heard policemen talk about a",
			"My friend told me about a",
			"Some time ago I could hear some soldiers talk about a"
		];

		pr _intelArray = CALLM0(_loc, "getIntel");
		if (count _intelArray > 0) then {
			{
				pr _intel = _x;
				pr _intelState = GETV(_intel, "state");
				// Check if it's a future event
				// If it's stil lactive or inactive, but not ended
				if (_intelState != INTEL_ACTION_STATE_END) then {					
					pr _departDate = GETV(_intel, "dateDeparture");
					// Fir for minutes being above 60 sometimes
					pr _year = _departDate#0;
					_departDate = numberToDate [_year, (dateToNumber _departDate)];
					pr _intelNameStr = CALLM0(_intel, "getShortName");
					pr _dateStr = _departDate call misc_fnc_dateToISO8601;
					pr _text = format ["%1 %2 at %3", selectRandom _phrasesIntelSource, _intelNameStr, _dateStr];
					_a pushBack NODE_SENTENCE("", TALKER_NPC, _text);
					_a pushBack NODE_CALL_METHOD("", "revealIntel", [_intel]);
				};
			} forEach _intelArray;

			// Civilian: I must go
			_strMustGo = selectRandom [
				"What are you going to do with this information anyway?",
				"By the way, why do you are you asking this?",
				"Just don't tell me why you are asking, all right?",
				"I don't want to know what you are going to do with this information!",
				"Just don't tell them I told you this!",
				"I have a bad feeling about this."
			];
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _strMustGo);
		} else {
			_a pushBack NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesDontKnowIntel);
		};

		// This dialogue part is called as a subroutine
		// Therefore we must return back
		_a pushBack NODE_RETURN("");

		// Combine the node arrays
		_nodes append _a;

	ENDMETHOD;

	METHOD(revealLocation)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc"), P_STRING("_type"), P_NUMBER("_distance")];

		OOP_INFO_1("revealLocation: %1", _this);

		// Also reveal the location to player's side
		private _updateLevel = -6;
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

		if (_updateLevel != -6) then {
			//diag_log format ["    adding to database"];
			private _commander = CALLSM1("AICommander", "getAICommander", side group T_GETV("unit1"));
			CALLM2(_commander, "postMethodAsync", "updateLocationData", [_loc ARG _updateLevel ARG sideUnknown ARG false ARG false ARG _accuracyRadius]);
		};
	ENDMETHOD;

	METHOD(revealIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];
		OOP_INFO_1("revealIntel: %1", _intel);
		pr _player = T_GETV("unit1");
		pr _cmdr = CALLSM1("AICommander", "getAICommander", side group _player);
		CALLM2(_cmdr, "postMethodAsync", "inspectIntel", [_intel]);
	ENDMETHOD;

	METHOD(sentenceTime)
		params [P_THISOBJECT];
		if (random 10 < 2) then {
			selectRandom
				[
					"Are you serious? You have a watch on your hand!",
					"Don't you have a phone?",
					"Don't you have a watch yourself?"
				];
		} else {
			format ["It is %1", [_time, "HH:MM"] call BIS_fnc_timeToString];
		};
	ENDMETHOD;

	METHOD(isIncited)
		params [P_THISOBJECT];
		pr _civ = T_GETV("unit0");
		T_GETV("incited") || UNDERCOVER_IS_UNIT_SUSPICIOUS(_civ);
	ENDMETHOD;

	METHOD(hasContributed)
		params [P_THISOBJECT];
		pr _civ = T_GETV("civ");
		GETV(_civ, "hasContributed");
	ENDMETHOD;

	METHOD(knowsIntel)
		params [P_THISOBJECT];
		pr _civ = T_GETV("civ");
		GETV(_civ, "knowsIntel");
	ENDMETHOD;

	METHOD(supportsResistance)
		params [P_THISOBJECT];
		pr _civ = T_GETV("civ");
		GETV(_civ, "supportsResistance");
	ENDMETHOD;

	METHOD(inciteCivilian)
		params [P_THISOBJECT];
		if (!T_CALLM0("isIncited")) then {

			pr _pos = getPos T_GETV("unit0");
			CALLSM("AICommander", "addActivity", [CALLM0(gGameMode, "getEnemySide") ARG _pos ARG (7+random(7))]);
			pr _civ = T_GETV("unit0");
			UNDERCOVER_SET_UNIT_SUSPICIOUS(_civ, true);
			T_SETV("incited", true);

			// Notify game mode
			CALLM2(gGameMode, "postMethodAsync", "civilianIncited", [_pos]);
		};
	ENDMETHOD;

	METHOD(scareCivilian)
		params [P_THISOBJECT];
		pr _civ = T_GETV("unit0");
		CALLSM1("AIUnitCivilian", "dangerEventHandler", _civ);
	ENDMETHOD;

	METHOD(giveBuildResources)
		params [P_THISOBJECT];

		SETV(T_GETV("civ"), "hasContributed", true);

		pr _civ = T_GETV("unit0");
		pr _player = T_GETV("unit1");
		pr _count = round (10 + random 10);

		pr _canAdd = _player canAddItemToBackpack ["vin_build_res_0", _count];

		if (_canAdd) then {
			(unitbackpack _player) addMagazineCargoGlobal ["vin_build_res_0", _count];
		} else {
			pr _holder = createVehicle ["WeaponHolderSimulated", getPosATL _civ, [], 0, "CAN_COLLIDE"]; 
			_holder addBackpackCargoGlobal ["B_FieldPack_khk", 1];
			(firstbackpack _holder) addMagazineCargoGlobal ["vin_build_res_0", _count];
		};


	ENDMETHOD;

ENDCLASS;