#include "..\common.hpp"
#include "..\..\Location\Location.hpp"

#define OOP_CLASS_NAME DialoguePolice
CLASS("DialoguePolice", "Dialogue")

	// We can incite civilian only once during the dialogue
	VARIABLE("incited");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("incited", false);
	ENDMETHOD;

	protected override METHOD(getNodes)
		params [P_THISOBJECT, P_OBJECT("_unit0"), P_OBJECT("_unit1")];

		pr _sentenceOfficerHello = selectRandom [
			"What's the problem?",
			"I'm on duty. Don't waste my time!",
			"Move along, I am busy! What do you want?",
			"Don't you see, I am busy over here!",
			"Go ahead, what do you want?",
			"Your face looks familiar. Did I arrest you a week ago?",
			"You look like the guy I fined a week ago!"
		];

		pr _sentenceOfficerBye = selectRandom [
			"Don't do anything funny, I'll be watching you!",
			"Report anything unusual, citizen!",
			"Stop wasting my time, citizen!",
			"Allright, now go away!",
			"I knew it was a pointless dialogue!"
		];

		pr _sentenceThanksForReport = selectRandom [
			"Good job, citizen. We will take measures.",
			"Thank you. We will do something about it."
		];

		pr _array = [
			//NODE_SENTENCE("", TALKER_PLAYER, g_phrasesPlayerStartDialogue),
			NODE_SENTENCE("", TALKER_NPC, _sentenceOfficerHello),
			
			// Options: 
			NODE_OPTIONS("options", ["opt_reportActivity" ARG "opt_bye"]),

			// Option: report activity to officer
			NODE_OPTION("opt_reportActivity", "I want to report terrorist activity nearby!"),
			NODE_SENTENCE("", TALKER_NPC, "What do you know?!"),
			NODE_OPTIONS("", ["opt_report0" ARG "opt_report1" ARG "opt_report2" ARG "opt_report3" ARG "opt_report4"]),

			NODE_OPTION("opt_report0", "Some man is giving out leaflets."),
			NODE_JUMP("", "reportPos"),
			NODE_OPTION("opt_report1", "Someone is making a political speech."),
			NODE_JUMP("", "reportPos"),
			NODE_OPTION("opt_report2", "I think there is a political meeting over there."),
			NODE_JUMP("", "reportPos"),
			NODE_OPTION("opt_report3", "I heard people talk about weapons."),
			NODE_JUMP("", "reportPos"),
			NODE_OPTION("opt_report4", "Some guys are loading strange boxes into their car."),
			NODE_JUMP("", "reportPos"),

			NODE_SENTENCE("reportPos", TALKER_NPC, "Where did you see it?"),
			NODE_OPTIONS("", ["opt_tellBearing"]),

			NODE_OPTION("opt_tellBearing", "Where I am looking at. A few city blocks this way."),
			NODE_CALL_METHOD("", "playPlayerGesture", []), // Player points with his arm somewhere
			NODE_CALL_METHOD("", "reportActivity", []),
			NODE_SENTENCE("", TALKER_NPC, _sentenceThanksForReport),
			NODE_END(""),
			
			

			// Option: leave
			NODE_OPTION("opt_bye", "Bye! I must leave now."),
			NODE_SENTENCE("", TALKER_NPC, _sentenceOfficerBye),
			NODE_END(""),

			// Genertic 'Anything else?' reply after the end of some option branch
			NODE_SENTENCE("anythingElse", TALKER_NPC, "Anything else?"),
			NODE_JUMP("", "options") // Go back to options
		];

		_array;
	ENDMETHOD;

	METHOD(playPlayerGesture)
		params [P_THISOBJECT];

		// Play action for player
		"ace_gestures_point" remoteExecCall ["ace_gestures_fnc_playSignal", T_GETV("remoteClientID")];
	ENDMETHOD;

	// Add point of interest to unit's group AI
	METHOD(reportActivity)
		params [P_THISOBJECT];

		pr _dist = 300;
		pr _player = T_GETV("unit1");
		pr _bearing = direction _player;
		pr _pos = _player getPos [_dist, _bearing];
		OOP_INFO_1("Adding point of interest: %1", _pos);
		pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", T_GETV("unit0"));
		pr _group = CALLM0(_unit, "getGroup");
		pr _groupAI = CALLM0(_group, "getAI");
		ASSERT_MSG(!IS_NULL_OBJECT(_groupAI), "Group AI is not null");
		CALLM1(_groupAI, "addPointOfInterest", _pos);
	ENDMETHOD;

ENDCLASS;