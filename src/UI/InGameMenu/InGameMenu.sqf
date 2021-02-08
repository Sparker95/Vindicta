#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"

#define pr private

#define OOP_CLASS_NAME InGameMenu
CLASS("InGameMenu", "DialogBase")

	METHOD(new)
		params [P_THISOBJECT];

		pr _gameModeInitialized = if(isNil "gGameManager") then {
			false
		} else {
			CALLM0(gGameManager, "isGameModeInitialized");
		};
		if (!_gameModeInitialized) then {

			T_CALLM2("addTab", "InGameMenuTabGameModeInit", localize "STR_IM_CREATE");
			T_CALLM2("addTab", "InGameMenuTabSave", localize "STR_IM_SAVE");
			T_CALLM2("addTab", "InGameMenuTabTutorial", localize "STR_IM_TUTOR");

			pr _text = format [localize "STR_IM_TITLE", call misc_fnc_getVersion];
			T_CALLM1("setHeadlineText", _text);
			T_CALLM1("setHintText", localize "STR_IM_DESC");
		} else {
			//T_CALLM2("addTab", "DialogTabBase", "Mission"localize "STR_MM_MISSION");
			T_CALLM2("addTab", "InGameMenuTabCommander", localize "STR_MM_STRAT");
			//T_CALLM2("addTab", "DialogTabBase", "Admin"localize "STR_MM_ADMIN");
			T_CALLM2("addTab", "InGameMenuTabNotes", localize "STR_MM_NOTE");
			T_CALLM2("addTab", "InGameMenuTabSave", localize "STR_MM_SAVE");
			T_CALLM2("addTab", "InGameMenuTabTutorial", localize "STR_MM_TUTOR");

			pr _text = format [localize "STR_MM_TITLE", call misc_fnc_getVersion];
			T_CALLM1("setHeadlineText", _text);
			//T_CALLM1("setHintText", localize "STR_MM_DESC"); // Not found in stringtable, but it's not important anyway
		};

		T_CALLM1("enableMultiTab", true);
		T_CALLM2("setContentSize", 0.7, 0.9);

	ENDMETHOD;

ENDCLASS;