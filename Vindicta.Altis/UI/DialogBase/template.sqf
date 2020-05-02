#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"

#define pr private

// Redefine this!
#define __CLASS_NAME "MyTab"
#define OOP_CLASS_NAME MyTab
CLASS("MyTab", "DialogTabBase")

	METHOD(new)
		params [P_THISOBJECT];

		// Create controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["TAB_GMINIT", -1];
		T_CALLM1("setControl", _group);

		SETSV(__CLASS_NAME, "instance", _thisObject);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", nil);
	ENDMETHOD;

ENDCLASS;

#define OOP_CLASS_NAME MyDialog
CLASS("MyDialog", "DialogBase")

	METHOD(new)
		params [P_THISOBJECT, ["_displayParent", displayNull, [displayNull]]];

		T_CALLM2("addTab", "DialogTabBase", "Mission");
		T_CALLM2("addTab", "DialogTabBase", "Admin");
		
		T_CALLM1("enableMultiTab", true);
		T_CALLM2("setContentSize", 0.78, 0.7);

	ENDMETHOD;

ENDCLASS;