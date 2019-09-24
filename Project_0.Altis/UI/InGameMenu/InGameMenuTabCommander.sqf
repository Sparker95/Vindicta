#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define pr private

CLASS("InGameMenuTabCommander", "DialogTabBase")

	METHOD("createControl") {
		params [P_THISOBJECT, ["_displayParent", displayNull, [displayNull]]];

		pr _group = _displayParent ctrlCreate ["TAB_CMDR", -1];

		pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_COMBO_LOC_TYPE");
		OOP_INFO_1("COMBO CTRL: %1", ctrlClassName _ctrl);
		_ctrl lbAdd "Camp";
		_ctrl lbAdd "Outpost";
		_ctrl lbAdd "Roadblock";

		_group
	} ENDMETHOD;

ENDCLASS;