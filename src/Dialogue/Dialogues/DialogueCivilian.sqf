#include "..\common.hpp"
#include "..\..\Location\Location.hpp"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\..\Undercover\UndercoverMonitor.hpp"
#include "..\..\Intel\Intel.hpp"

// How much we'll boost player's suspicion when he picks 'dangerous' dialogue options
#define SUSP_BOOST_AMOUNT 0.7

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
			localize "STR_MILITARY_LOCATIONS_1",
			localize "STR_MILITARY_LOCATIONS_2",
			localize "STR_MILITARY_LOCATIONS_3",
			localize "STR_MILITARY_LOCATIONS_4",
			localize "STR_MILITARY_LOCATIONS_5"
		];

		pr _phrasesIncite = [
			localize "STR_INCITE_1",
			localize "STR_INCITE_2",
			localize "STR_INCITE_3",
			localize "STR_INCITE_4",
			localize "STR_INCITE_5",
			localize "STR_INCITE_6",
			localize "STR_INCITE_7",
			localize "STR_INCITE_8",
			localize "STR_INCITE_9"
		];

		pr _phrasesCivilianInciteResponse = [
			localize "STR_C_INCITE_RESPONSE_1",
			localize "STR_C_INCITE_RESPONSE_2",
			localize "STR_C_INCITE_RESPONSE_3",
			localize "STR_C_INCITE_RESPONSE_4",
			localize "STR_C_INCITE_RESPONSE_5",
			localize "STR_C_INCITE_RESPONSE_6",
			localize "STR_C_INCITE_RESPONSE_7",
			localize "STR_C_INCITE_RESPONSE_8",
			// Written by Jasperdoit:
			localize "STR_C_INCITE_RESPONSE_9",
			localize "STR_C_INCITE_RESPONSE_10",
			localize "STR_C_INCITE_RESPONSE_11",
			localize "STR_C_INCITE_RESPONSE_12",
			localize "STR_C_INCITE_RESPONSE_13",
			localize "STR_C_INCITE_RESPONSE_14"
		];

		pr _phrasesScare = [
			localize "STR_SCARE_1",
			localize "STR_SCARE_2",
			localize "STR_SCARE_3",
			localize "STR_SCARE_4",
			localize "STR_SCARE_5",
			localize "STR_SCARE_6"
		];

		pr _phrasesIntel = [
			localize "STR_INTEL_1",
			localize "STR_INTEL_2",
			localize "STR_INTEL_3"
		];

		pr _phrasesAskHelp = [
			localize "STR_ASK_HELP_1",
			localize "STR_ASK_HELP_2"
		];

		pr _phrasesAgreeHelp = [
			localize "STR_AGREE_HELP_1",
			localize "STR_AGREE_HELP_2"
		];

		pr _phrasesDontSupportResistance = [
			localize "STR_DONT_SUPPORT_1",
			localize "STR_DONT_SUPPORT_2",
			localize "STR_DONT_SUPPORT_3"
		];

		pr _phrasesDontKnowIntel = [
			localize "STR_DONT_KNOW_1",
			localize "STR_DONT_KNOW_2",
			localize "STR_DONT_KNOW_3"
		];

		pr _array = [
			//NODE_SENTENCE("", TALKER_PLAYER, g_phrasesPlayerStartDialogue),
			NODE_SENTENCE("", TALKER_NPC, [localize "STR_NODE_C_SD_1" ARG localize "STR_NODE_C_SD_2" ARG localize "STR_NODE_C_SD_3"]),
			
			// Options: 
			NODE_OPTIONS("node_options", ["opt_locations" ARG "opt_intel" ARG "opt_incite" ARG "opt_askContribute" ARG "opt_scare" ARG "opt_time" ARG "opt_bye"]),

			// Option: ask about military locations
			NODE_OPTION("opt_locations", _phrasesPlayerAskMilitaryLocations),
			NODE_CALL_METHOD("", "makeTalkersSuspicious", [SUSP_BOOST_AMOUNT]),
			NODE_CALL("", "subroutineTellLocations"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: ask about intel
			NODE_OPTION("opt_intel", selectRandom _phrasesIntel),
			NODE_CALL_METHOD("", "makeTalkersSuspicious", [SUSP_BOOST_AMOUNT]),
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
			NODE_CALL_METHOD("", "makeTalkersSuspicious", [SUSP_BOOST_AMOUNT]), // Must place it to the end, otherwise isIncited always returns true
			NODE_SENTENCE("", TALKER_PLAYER, localize "STR_NODE_P_TITO"), // Tell it to others!
			NODE_JUMP("", "node_options"),

			NODE_SENTENCE("node_alreadyIncited", TALKER_NPC, localize "STR_NODE_C_DANGEROUS_TO_DISCUSS"),
			NODE_CALL_METHOD("", "makeTalkersSuspicious", [SUSP_BOOST_AMOUNT]), // Must place it to the end, otherwise isIncited always returns true
			NODE_JUMP("", "node_options"),

			// Option: ask for contribution
			NODE_OPTION("opt_askContribute", selectRandom _phrasesAskHelp),
			NODE_CALL_METHOD("", "makeTalkersSuspicious", [SUSP_BOOST_AMOUNT]),
			NODE_JUMP_IF("", "node_alreadyContributed", "hasContributed", []),
			NODE_JUMP_IF("", "node_giveBuildResources", "supportsResistance", []),
			NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesDontSupportResistance),
			NODE_JUMP("", "node_anythingElse"),

			NODE_CALL_METHOD("node_giveBuildResources", "giveBuildResources", []),
			NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesAgreeHelp),
			NODE_JUMP("", "node_anythingElse"),

			NODE_SENTENCE("node_alreadyContributed", TALKER_NPC, localize "STR_NODE_C_NO_MORE_RESOURCE"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: scare civilian
			NODE_OPTION("opt_scare", _phrasesScare),
			NODE_CALL_METHOD("", "makeTalkersSuspicious", [SUSP_BOOST_AMOUNT]),
			NODE_CALL_METHOD("", "scareCivilian", []),
			NODE_END(""),

			// Option: ask about time
			NODE_OPTION("opt_time", localize "STR_NODE_P_ASK_TIME"),
			NODE_SENTENCE_METHOD("", TALKER_NPC, "sentenceTime"),
			NODE_SENTENCE("", TALKER_PLAYER, localize "STR_NODE_P_THANKS"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: leave
			NODE_OPTION("opt_bye", localize "STR_NODE_P_BYE"),
			NODE_SENTENCE("", TALKER_NPC, [localize "STR_NODE_C_BYE_1" ARG localize "STR_NODE_C_BYE_2" ARG localize "STR_NODE_C_BYE_3"]),
			NODE_END(""),

			// Genertic 'Anything else?' reply after the end of some option branch
			NODE_SENTENCE("node_anythingElse", TALKER_NPC, localize "STR_NODE_C_ANYMORE"),
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
			{ CALLM0(_x, "isBuilt") } &&	// Don't tell about places which aren't built
			{
				(random 10 < 5) ||
				{_type == LOCATION_TYPE_POLICE_STATION}
				// If it's very close, civilians will surely tell about it
			}
		};

		OOP_INFO_1("  Locations known by civilian: %1", _locsCivKnows);

		_a = [];
		_a pushBack NODE_SENTENCE("subroutineTellLocations", TALKER_NPC, [localize "STR_NODE_C_GATHER_1" ARG localize "STR_NODE_C_GATHER_2" ARG localize "STR_NODE_C_GATHER_3"]);
		
		if (count _locsCivKnows == 0) then {
			pr _str = localize "STR_NODE_C_GATHER_NO";
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _str);
		} else {
			pr _str = localize "STR_NODE_C_GATHER_YES";
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _str);

			{ // forEach _locsCivKnows;
				pr _loc = _x;
				pr _type = CALLM0(_loc, "getType");
				pr _locPos = CALLM0(_loc, "getPos");
				pr _bearing = _unit getDir _locPos;
				pr _distance = _unit distance2D _locPos;
				pr _bearings = [localize "STR_NODE_DIR_N", localize "STR_NODE_DIR_NE", localize "STR_NODE_DIR_E", localize "STR_NODE_DIR_SE", localize "STR_NODE_DIR_S", localize "STR_NODE_DIR_SW", localize "STR_NODE_DIR_W", localize "STR_NODE_DIR_NW"];
				pr _bearingID = (round (_bearing/45)) % 8;

				// Strings
				pr _typeString = CALLSM1("Location", "getTypeString", _type);
				pr _bearingString = _bearings select _bearingID;
				pr _distanceString = if(_distance < 400) then {
					selectRandom [localize "STR_NODE_L400_1", localize "STR_NODE_L400_2", localize "STR_NODE_L400_3", localize "STR_NODE_L400_4"]
				} else {
					if (_distance < 1000) then {
						selectRandom [localize "STR_NODE_L1000_1", localize "STR_NODE_L1000_2", localize "STR_NODE_L1000_3", localize "STR_NODE_L1000_4"];
					} else {
						selectRandom [localize "STR_NODE_M1000_1", localize "STR_NODE_M1000_2", localize "STR_NODE_M1000_3", localize "STR_NODE_M1000_4"];
					};
				};
				pr _intro = selectRandom [	localize "STR_NODE_C_INFO_INTRO_1",
											localize "STR_NODE_C_INFO_INTRO_2",
											localize "STR_NODE_C_INFO_INTRO_3",
											localize "STR_NODE_C_INFO_INTRO_4",
											localize "STR_NODE_C_INFO_INTRO_5",
											localize "STR_NODE_C_INFO_INTRO_6",
											localize "STR_NODE_C_INFO_INTRO_7",
											localize "STR_NODE_C_INFO_INTRO_8",
											localize "STR_NODE_C_INFO_INTRO_9"];

				pr _posString = if (_type == LOCATION_TYPE_POLICE_STATION) then {
					pr _locCities = CALLSM1("Location", "getLocationsAtPos", _locPos) select {
						CALLM0(_x, "getType") == LOCATION_TYPE_CITY
					};
					if (count _locCities > 0) then {
						format [localize "STR_NODE_AT", CALLM0(_locCities select 0, "getName")];
					} else {
						format [localize "STR_NODE_TO", _bearingString];
					};
				} else {
					format [localize "STR_NODE_TO", _bearingString];
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
				localize "STR_NODE_C_INFO_OUTRO_1",
				localize "STR_NODE_C_INFO_OUTRO_2",
				localize "STR_NODE_C_INFO_OUTRO_3"
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
		_a pushBack NODE_SENTENCE("subroutineTellIntel", TALKER_NPC, [localize "STR_NODE_C_GATHER_1" ARG localize "STR_NODE_C_GATHER_2" ARG localize "STR_NODE_C_GATHER_3"]);

		pr _phrasesIntelSource = [
			localize "STR_NODE_C_INFO_INTRO_5",
			localize "STR_NODE_C_INFO_INTRO_10",
			localize "STR_NODE_C_INFO_INTRO_11",
			localize "STR_NODE_C_INFO_INTRO_12",
			localize "STR_NODE_C_INFO_INTRO_13"
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
					pr _text = format [localize "STR_NODE_INFO_INTEL", selectRandom _phrasesIntelSource, localize _intelNameStr, _dateStr];
					_a pushBack NODE_SENTENCE("", TALKER_NPC, _text);
					_a pushBack NODE_CALL_METHOD("", "revealIntel", [_intel]);
				};
			} forEach _intelArray;

			// Civilian: I must go
			_strMustGo = selectRandom [
				localize "STR_NODE_C_INFO_OUTRO_4",
				localize "STR_NODE_C_INFO_OUTRO_5",
				localize "STR_NODE_C_INFO_OUTRO_6",
				localize "STR_NODE_C_INFO_OUTRO_7",
				localize "STR_NODE_C_INFO_OUTRO_8",
				localize "STR_NODE_C_INFO_OUTRO_9"
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
					localize "STR_NODE_C_ASK_TIME_NO_1",
					localize "STR_NODE_C_ASK_TIME_NO_2",
					localize "STR_NODE_C_ASK_TIME_NO_3"
				];
		} else {
			format [localize "STR_NODE_C_ASK_TIME_YES", [_time, "HH:MM"] call BIS_fnc_timeToString];
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

	METHOD(makeTalkersSuspicious)
		params [P_THISOBJECT, P_NUMBER("_amount")];

		// Boost player's suspiciousness
		pr _player = T_GETV("unit1");
		private _args = [_player, _amount];
		REMOTE_EXEC_CALL_STATIC_METHOD("undercoverMonitor", "boostSuspicion", _args, _player, false);
		
		// Make civilian suspicious so cops will try to arrest him
		pr _civ = T_GETV("unit0");
		UNDERCOVER_SET_UNIT_SUSPICIOUS(_civ, true);

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