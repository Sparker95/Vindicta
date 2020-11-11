#include "..\common.hpp"
#include "..\..\Location\Location.hpp"

#define OOP_CLASS_NAME DialoguePolice
CLASS("DialoguePolice", "Dialogue")

	// Bearing where the player pointed at
	VARIABLE("bearing");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("bearing", 0);
	ENDMETHOD;

	protected override METHOD(getNodes)
		params [P_THISOBJECT, P_OBJECT("_unit0"), P_OBJECT("_unit1")];

		pr _sentenceOfficerHello = selectRandom [
			localize "STR_O_HELLO_1",
			localize "STR_O_HELLO_2",
			localize "STR_O_HELLO_3",
			localize "STR_O_HELLO_4",
			localize "STR_O_HELLO_5",
			localize "STR_O_HELLO_6",
			localize "STR_O_HELLO_7"
		];

		pr _sentenceOfficerBye = selectRandom [
			localize "STR_O_BYE_1",
			localize "STR_O_BYE_2",
			localize "STR_O_BYE_3",
			localize "STR_O_BYE_4",
			localize "STR_O_BYE_5"
		];

		pr _sentenceThanksForReport = selectRandom [
			localize "STR_O_THANKS_1",
			localize "STR_O_THANKS_2"
		];

		pr _activities = [
			localize "STR_P_ACTIVITIES_1",
			localize "STR_P_ACTIVITIES_2",
			localize "STR_P_ACTIVITIES_3",
			localize "STR_P_ACTIVITIES_4",
			localize "STR_P_ACTIVITIES_5"
		];

		pr _array = [
			//NODE_SENTENCE("", TALKER_PLAYER, g_phrasesPlayerStartDialogue),
			NODE_SENTENCE("", TALKER_NPC, _sentenceOfficerHello),
			
			// Options: 
			NODE_OPTIONS("options", ["opt_wherePoliceStation" ARG "opt_reportActivity" ARG "opt_bye"]),

			// Option: ask where is the police station
			NODE_OPTION("opt_wherePoliceStation", localize "STR_P_WHERE_POLICESTATION"),
			NODE_SENTENCE_METHOD("", TALKER_NPC, "sentencePoliceStation"),
			NODE_SENTENCE("", TALKER_PLAYER, localize "STR_NODE_P_THANKS"),
			NODE_JUMP("", "anythingElse"),

			// Option: report activity to officer
			NODE_OPTION("opt_reportActivity", localize "STR_P_REPORT"),
			NODE_SENTENCE("", TALKER_NPC, localize "STR_O_REPORT_FOLLOWUP_1"),
			NODE_OPTIONS("", ["opt_report0" ARG "opt_report1" ARG "opt_report2" ARG "opt_report3" ARG "opt_report4"]),

			NODE_OPTION("opt_report0", _activities select 0), NODE_JUMP("", "reportPos"),
			NODE_OPTION("opt_report1", _activities select 1), NODE_JUMP("", "reportPos"),
			NODE_OPTION("opt_report2", _activities select 2), NODE_JUMP("", "reportPos"),
			NODE_OPTION("opt_report3", _activities select 3), NODE_JUMP("", "reportPos"),
			NODE_OPTION("opt_report4", _activities select 4), NODE_JUMP("", "reportPos"),

			NODE_SENTENCE("reportPos", TALKER_NPC, localize "STR_O_REPORT_FOLLOWUP_2"),
			NODE_OPTIONS("", ["opt_tellBearing" ARG "opt_followMe"]),

				NODE_CALL_METHOD("opt_tellBearing", "playPlayerGesture", []), // Player points with his arm somewhere
				NODE_OPTION("", localize "STR_P_REPORT_POINTAT"),
				NODE_CALL_METHOD("", "reportActivity", []),
				NODE_SENTENCE("", TALKER_NPC, _sentenceThanksForReport),
				NODE_END(""),

				NODE_OPTION("opt_followMe", localize "STR_P_REPORT_LEADWAY"),
				NODE_SENTENCE("", TALKER_NPC, localize "STR_O_REPORT_LEADWAY"),			
				NODE_CALL_METHOD("", "follow", []),
				NODE_END(""),

			// Option: leave
			NODE_OPTION("opt_bye", localize "STR_NODE_P_BYE"),
			NODE_SENTENCE("", TALKER_NPC, _sentenceOfficerBye),
			NODE_END(""),

			// Generic 'Anything else?' reply after the end of some option branch
			NODE_SENTENCE("anythingElse", TALKER_NPC, localize "STR_NODE_C_ANYMORE"),
			NODE_JUMP("", "options") // Go back to options
		];

		_array;
	ENDMETHOD;

	// Player will point with finger
	// At this moment his bearing is recorded
	METHOD(playPlayerGesture)
		params [P_THISOBJECT];

		pr _player = T_GETV("unit1");
		pr _bearing = direction _player;
		T_SETV("bearing", _bearing);
		OOP_INFO_1("Recorded bearing: %1", _bearing);

		// Play action for player
		"ace_gestures_point" remoteExecCall ["ace_gestures_fnc_playSignal", T_GETV("remoteClientID")];
	ENDMETHOD;

	// Add point of interest to unit's group AI
	METHOD(reportActivity)
		params [P_THISOBJECT];

		pr _dist = 300;
		pr _player = T_GETV("unit1");
		pr _bearing = T_GETV("bearing");
		pr _pos = _player getPos [_dist, _bearing];
		OOP_INFO_1("Adding point of interest: %1", _pos);
		pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", T_GETV("unit0"));
		pr _group = CALLM0(_unit, "getGroup");
		pr _groupAI = CALLM0(_group, "getAI");
		ASSERT_MSG(!IS_NULL_OBJECT(_groupAI), "Group AI is not null");
		CALLM1(_groupAI, "addPointOfInterest", _pos);
		CALLM2(_groupAI, "setEscortTarget", objNull, 0);
	ENDMETHOD;

	// Police officer tells where his police station is
	METHOD(sentencePoliceStation)
		params [P_THISOBJECT];
		pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", T_GETV("unit0"));
		pr _garrison = CALLM0(_unit, "getGarrison");
		pr _loc = CALLM0(_garrison, "getLocation");
		if (IS_NULL_OBJECT(_loc)) then {
			"I don't know.";
		} else {
			pr _locPos = CALLM0(_loc, "getPos");
			pr _bearing = T_GETV("unit0") getDir _locPos;
			pr _bearingString = _bearing call misc_fnc_bearingString;
			pr _distance = T_GETV("unit0") distance2D _locPos;
			_distance = 10 * (round (_distance / 10));
			format ["It is %1 meters %2 from here.", _distance, _bearingString];
		};
	ENDMETHOD;

	METHOD(follow)
		params [P_THISOBJECT];
		pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", T_GETV("unit0"));
		pr _group = CALLM0(_unit, "getGroup");
		pr _groupAI = CALLM0(_group, "getAI");
		ASSERT_MSG(!IS_NULL_OBJECT(_groupAI), "Group AI is not null");
		CALLM2(_groupAI, "setEscortTarget", T_GETV("unit1"), 5*60); // object, duration
	ENDMETHOD;

ENDCLASS;