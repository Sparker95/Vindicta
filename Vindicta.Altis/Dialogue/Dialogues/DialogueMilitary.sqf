#include "..\common.hpp"
#include "..\..\Location\Location.hpp"

#define OOP_CLASS_NAME DialogueMilitary
CLASS("DialogueMilitary", "Dialogue")

	// This is a dummy dialogue for now.
	protected override METHOD(getNodes)
		params [P_THISOBJECT, P_OBJECT("_unit0"), P_OBJECT("_unit1")];

		pr _array = [
			NODE_SENTENCE("", TALKER_NPC, selectRandom g_phrasesCantTalkBusy)
		];

		_array;
	ENDMETHOD;

ENDCLASS;