#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Location\Location.hpp"

#define pr private

CLASS("InGameMenuTabTutorial", "DialogTabBase")

	STATIC_VARIABLE("instance");

	METHOD("new") {
		params [P_THISOBJECT];
		
		SETSV("InGameMenuTabTutorial", "instance", _thisObject);

		// Create the controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["TAB_TUTORIAL", -1];
		T_CALLM1("setControl", _group);

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		SETSV("InGameMenuTabTutorial", "instance", nil);
	} ENDMETHOD;

	// Called before this tab is deleted but when controls still exist
	// Override for custom functionality
	/* virtual */ METHOD("beforeDelete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

ENDCLASS;