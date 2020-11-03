#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"

// Dialog with 'YES' and 'NO' buttons
// Clicking on any of those will close the dialog and call a callback passed through constructor

#define OOP_CLASS_NAME DialogConfirmAction
CLASS("DialogConfirmAction", "DialogOneTabButtons")

	VARIABLE("argsYes");
	VARIABLE("argsNo");
	VARIABLE("codeYes");
	VARIABLE("codeNo");

	METHOD(new)
		params [P_THISOBJECT, P_STRING("_text"),
			P_ARRAY("_argsYes"), P_CODE("_codeYes"),
			P_ARRAY("_argsNo"), P_CODE("_codeNo")];
		// Set appearence, add buttons, ...
		T_CALLM2("setContentSize", 0.7, 0.3); // Height will be determined by text height anyway
		T_CALLM1("setHeadlineText", localize "STR_DB_TITLE");
		T_CALLM1("setHintText", "");
		T_CALLM1("createButtons", [localize "STR_DB_YES" ARG localize "STR_DB_NO"]);
		T_CALLM1("setText", _text);

		T_SETV("argsYes", _argsYes);
		T_SETV("argsNo", _argsNo);
		T_SETV("codeYes", _codeYes);
		T_SETV("codeNo", _codeNo);
	ENDMETHOD;

	public override METHOD(onButtonClick)
		params [P_THISOBJECT, P_NUMBER("_ID")];

		OOP_INFO_1("Button was clicked: %1", _ID);

		//[_thisObject] call OOP_dumpAllVariables;

		if (_ID == 0) then { // Yes
			T_GETV("argsYes") call T_GETV("codeYes");
		} else { // No
			T_GETV("argsNo") call T_GETV("codeNo");
		};

		T_CALLM0("deleteOnNextFrame");
	ENDMETHOD;

ENDCLASS;