#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"
#include "..\..\Location\Location.hpp"

#define pr private

#define OOP_CLASS_NAME InGameMenuTabTutorial
CLASS("InGameMenuTabTutorial", "DialogTabBase")

	METHOD(new)
		params [P_THISOBJECT];

		SETSV("InGameMenuTabTutorial", "instance", _thisObject);

		// Create the controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["TAB_TUTORIAL", -1];
		T_CALLM1("setControl", _group);

		T_CALLM3("controlAddEventHandler", "TAB_TUT_BUTTON_NEXT", "buttonClick", "onButtonNext");
		T_CALLM3("controlAddEventHandler", "TAB_TUT_BUTTON_PREV", "buttonClick", "onButtonPrevious");
	
		// listnbox
		pr _listnbox = T_CALLM1("findControl", "TAB_TUT_LISTBOX");
		T_CALLM3("controlAddEventHandler", "TAB_TUT_LISTBOX", "LBSelChanged", "onListboxSelChanged");
		_listnbox lnbSetColumnsPos [0, 0.2]; // remove space in front of list item
		_listnbox lnbDeleteRow 0;

		// populate listnbox with headline names
		{ 
			// _forEachIndex + 1: ignore base class
			pr _objClassName = (configName (("true" configClasses (missionConfigFile >> "TutorialPages")) select (_forEachIndex + 1)));
			_listnbox lnbAddRow [(getText (missionConfigFile >> "TutorialPages" >> _objClassName >> "textHeadline"))];
		} forEach("configName (inheritsFrom _x) == 'TutBasePage'" configClasses (missionConfigFile >> "TutorialPages"));
		// We must omit the base class

		_listnbox lnbSetCurSelRow 0;

	ENDMETHOD;


	METHOD(delete)
		params [P_THISOBJECT];

		SETSV("InGameMenuTabTutorial", "instance", nil);
	ENDMETHOD;


	METHOD(drawPageWithIndex)
		params [P_THISOBJECT, P_NUMBER("_index")];

		if (_index <= -1) exitWith {};

		// get values from tutorial pages config
		pr _objClassName = (configName (("true" configClasses (missionConfigFile >> "TutorialPages")) select (_index + 1)));
		pr _headlineText = (getText (missionConfigFile >> "TutorialPages" >> _objClassName >> "textHeadline"));
		pr _text = (getText (missionConfigFile >> "TutorialPages" >> _objClassName >> "text"));
		pr _imagePath = (getText (missionConfigFile >> "TutorialPages" >> _objClassName >> "imagePath"));

		// set headline and text on control
		pr _headlineTextCtrl = T_CALLM1("findControl", "TAB_TUT_HEADLINE");
		pr _textCtrl = T_CALLM1("findControl", "TAB_TUT_TEXT");

		_headlineTextCtrl ctrlSetText _headlineText;
		_textCtrl ctrlSetText _text;

		// set image path, uses default image if no image is specified
		pr _imageCtrl = T_CALLM1("findControl", "TAB_TUT_PICTURE");
		_imageCtrl ctrlSetText _imagePath;

	ENDMETHOD;


	METHOD(onListboxSelChanged)
		params [P_THISOBJECT];

		pr _listnbox = T_CALLM1("findControl", "TAB_TUT_LISTBOX");
		pr _index = lnbCurSelRow _listnbox;
		T_CALLM1("drawPageWithIndex", _index);

	ENDMETHOD;

	METHOD(onButtonNext)
		params [P_THISOBJECT];

		// get current listbox index
		pr _listnbox = T_CALLM1("findControl", "TAB_TUT_LISTBOX");
		pr _index = lnbCurSelRow _listnbox;

		if (_index <= -1) exitWith { _listnbox lnbSetCurSelRow 0; };

		// if possible, advance a row
		if !((_index) >= (((lnbSize _listnbox)#0) - 1)) then {
			_listnbox lnbSetCurSelRow (_index + 1);
		};

		
	ENDMETHOD;


	METHOD(onButtonPrevious)
		params [P_THISOBJECT];

		// get current listbox index
		pr _listnbox = T_CALLM1("findControl", "TAB_TUT_LISTBOX");
		pr _index = lnbCurSelRow _listnbox;

		if (_index <= -1) exitWith { _listnbox lnbSetCurSelRow 0; };

		// if possible, go back a row
		if !(_index == 0) then {
			_listnbox lnbSetCurSelRow (_index - 1);
		};

	ENDMETHOD;


	// Called before this tab is deleted but when controls still exist
	// Override for custom functionality
	/* virtual */ METHOD(beforeDelete)
		params [P_THISOBJECT];

	ENDMETHOD;

ENDCLASS;