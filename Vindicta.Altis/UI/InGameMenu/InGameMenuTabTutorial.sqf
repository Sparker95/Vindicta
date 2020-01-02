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

	VARIABLE("currentPageIndex");
	VARIABLE("text");
	VARIABLE("textHeadline");

	METHOD("new") {
		params [P_THISOBJECT];

		SETSV("InGameMenuTabTutorial", "instance", _thisObject);

		// Create the controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["TAB_TUTORIAL", -1];
		T_CALLM1("setControl", _group);

		T_SETV("currentPageIndex", 1); // default page index

		T_CALLM3("controlAddEventHandler", "TAB_TUT_BUTTON_NEXT", "buttonClick", "onButtonNext");
		T_CALLM3("controlAddEventHandler", "TAB_TUT_BUTTON_PREV", "buttonClick", "onButtonPrevious");

		// populate listnbox with headline names
		pr _listnbox = T_CALLM1("findControl", "TAB_TUT_LISTBOX");
		_listnbox lnbSetColumnsPos [0, 0.2];
		{ 

			// _forEachIndex + 1: ignore base class
			pr _objClassName = (configName (("true" configClasses (missionConfigFile >> "TutorialPages")) select (_forEachIndex + 1))); 
			_listnbox lnbAddRow [(getText (missionConfigFile >> "TutorialPages" >> _objClassName >> "textHeadline"))]; 

			
		} forEach ("true" configClasses (missionConfigFile >> "TutorialPages"));

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		SETSV("InGameMenuTabTutorial", "instance", nil);
	} ENDMETHOD;

	METHOD("onButtonNext") {
		params [P_THISOBJECT];

		pr _controlHeadline = T_CALLM1("findControl", "TAB_TUT_HEADLINE");
		pr _numPages = count ("true" configClasses (missionConfigFile >> "TutorialPages"));
		_controlHeadline ctrlSetText format["%1", _numPages + 1];

	} ENDMETHOD;

	METHOD("onButtonPrevious") {
		params [P_THISOBJECT];

		pr _controlHeadline = T_CALLM1("findControl", "TAB_TUT_HEADLINE");
		pr _numPages = count ("true" configClasses (missionConfigFile >> "TutorialPages"));
		_controlHeadline ctrlSetText format["%1", _numPages - 1];

	} ENDMETHOD;

	// Called before this tab is deleted but when controls still exist
	// Override for custom functionality
	/* virtual */ METHOD("beforeDelete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

ENDCLASS;