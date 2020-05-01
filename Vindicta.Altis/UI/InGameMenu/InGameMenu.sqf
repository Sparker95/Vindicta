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

			T_CALLM2("addTab", "InGameMenuTabGameModeInit", "Create");
			T_CALLM2("addTab", "InGameMenuTabSave", "Savegames");
			T_CALLM2("addTab", "InGameMenuTabTutorial", "Tutorial");

			pr _text = format ["Mission Startup Menu  v%1", call misc_fnc_getVersion];
			T_CALLM1("setHeadlineText", _text);
			T_CALLM1("setHintText", "Load a previously saved game or create a new campaign.");
		} else {
			//T_CALLM2("addTab", "DialogTabBase", "Mission");
			T_CALLM2("addTab", "InGameMenuTabCommander", "Strategic");
			//T_CALLM2("addTab", "DialogTabBase", "Admin");
			T_CALLM2("addTab", "InGameMenuTabNotes", "Notes");
			T_CALLM2("addTab", "InGameMenuTabSave", "Savegames");
			T_CALLM2("addTab", "InGameMenuTabTutorial", "Tutorial");

			pr _text = format ["Mission Menu  v%1", call misc_fnc_getVersion];
			T_CALLM1("setHeadlineText", _text);
			T_CALLM1("setHintText", "Vindicta pre-alpha version.");
		};

		T_CALLM1("enableMultiTab", true);
		T_CALLM2("setContentSize", 0.7, 0.9);

	ENDMETHOD;

ENDCLASS;