#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

CLASS("InGameMenu", "DialogBase")

	METHOD("new") {
		params [P_THISOBJECT];

		T_CALLM2("addTab", "DialogTabBase", "Mission");
		T_CALLM2("addTab", "InGameMenuTabCommander", "Commander");
		T_CALLM2("addTab", "DialogTabBase", "Admin");
		T_CALLM2("addTab", "InGameMenuTabNotes", "Notes");
		
		T_CALLM1("enableMultiTab", true);
		T_CALLM2("setContentSize", 0.7, 0.9);

		T_CALLM1("setHeadlineText", "Mission Menu");
		T_CALLM1("setHintText", "Vindicta pre-alpha version");

	} ENDMETHOD;

ENDCLASS;