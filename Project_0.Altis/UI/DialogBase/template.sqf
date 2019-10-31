#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define pr private

CLASS("MyTab", "DialogTabBase")

	METHOD("new") {
		params [P_THISOBJECT];
		
		// Example of how to create the controls for derived tab classes		
		pr _displayParent = T_CALLM0("getDisplay");
		pr _ctrl = _displayParent ctrlCreate ["MUI_BASE", -1];
		_ctrl ctrlSetPosition [0, 0, 0.5, 0.5];
		_ctrl ctrlSetBackgroundColor [0.6, 0.1, 0.1, 0.8];
		_ctrl ctrlSetText _thisObject;
		_ctrl ctrlCommit 2.0;

		T_CALLM1("setControl", _ctrl);
	} ENDMETHOD;

ENDCLASS;

CLASS("MyDialog", "DialogBase")

	METHOD("new") {
		params [P_THISOBJECT, ["_displayParent", displayNull, [displayNull]]];

		T_CALLM2("addTab", "DialogTabBase", "Mission");
		T_CALLM2("addTab", "DialogTabBase", "Admin");
		
		T_CALLM1("enableMultiTab", true);
		T_CALLM2("setContentSize", 0.78, 0.7);

	} ENDMETHOD;

ENDCLASS;