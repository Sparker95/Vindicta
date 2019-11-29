#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define __CLASS_NAME "InGameMenuTabGameModeInit"

#define pr private

CLASS(__CLASS_NAME, "DialogTabBase")

	STATIC_VARIABLE("instance");

	METHOD("new") {
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", _thisObject);

		// Create controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["TAB_GMINIT", -1];
		T_CALLM1("setControl", _group);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", nil);

	} ENDMETHOD;

ENDCLASS;