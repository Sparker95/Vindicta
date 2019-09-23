#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

CLASS("InGameMenu", "DialogBase")

	METHOD("new") {
		params [P_THISOBJECT];

		T_CALLM2("setContentSize", 0.78, 0.7);
		T_CALLM2("addTab", "InGameMenuTabCommander", "Mission");
		T_CALLM2("addTab", "InGameMenuTabCommander", "Commander");
		
	} ENDMETHOD;



ENDCLASS;