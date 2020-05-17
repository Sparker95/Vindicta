#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"

#define pr private

#define OOP_CLASS_NAME RadioKeyTab
CLASS("RadioKeyTab", "DialogTabBase")

	// State machine to handle comms with the server
	VARIABLE("state");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("state", 0);
		SETSV("RadioKeyTab", "instance", _thisObject);

		// Create controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["RadioKeyTab", -1];
		T_CALLM1("setControl", _group);

		// Add button event handler
		T_CALLM3("controlAddEventHandler", "BUTTON_ADD_KEY", "buttonClick", "onButtonAddKey");

		// Ask for radio keys from server
		pr _args = [playerSide, clientOwner];
		REMOTE_EXEC_CALL_STATIC_METHOD("AICommander", "staticClientRequestRadioKeys", _args, 2, false); // Call it on server
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		SETSV("RadioKeyTab", "instance", nil);
	ENDMETHOD;

	METHOD(getInstance)
		params [P_THISCLASS];
		pr _inst = GETSV(_thisClass, "instance");
		if (isNil "_inst") then {
			NULL_OBJECT
		} else {
			_inst
		};
	ENDMETHOD;


	METHOD(onButtonAddKey)
		params [P_THISOBJECT];

		// Bail if our previous response has not been processed yet
		if (T_GETV("state") != 0) exitWith {
			pr _dialogObj = T_CALLM0("getDialogObject");
			CALLM1(_dialogObj, "setHintText", "Previous key is being checked!");
		};

		// Read key from the edit box
		pr _ctrl = T_CALLM1("findControl", "EDIT_ENTER_KEY");
		pr _key = ctrlText _ctrl;
		
		// Ensure at least some input
		if (count _key == 0) exitWith {
			pr _dialogObj = T_CALLM0("getDialogObject");
			CALLM1(_dialogObj, "setHintText", "You must enter the key first!");
		};

		// Change state variable
		T_SETV("state", 1); // Waiting for server to check our key

		// Set temporary hint text...
		pr _dialogObj = T_CALLM0("getDialogObject");
		CALLM1(_dialogObj, "setHintText", "Checking key...");

		// Send data to server
		pr _args = [playerSide, clientOwner, _key, name player];
		REMOTE_EXEC_CALL_STATIC_METHOD("AICommander", "staticClientAddRadioKey", _args, 2, false);

	ENDMETHOD;

	// Show server's response
	METHOD(showResponse)
		params [P_THISOBJECT, P_STRING("_text")];

		OOP_INFO_1("SHOW RESPONSE: %1", _this);

		T_SETV("state", 0); // We can let user push the button again now

		// We are just showing hint text
		pr _dialogObj = T_CALLM0("getDialogObject");
		CALLM1(_dialogObj, "setHintText", _text);
	ENDMETHOD;

	// Lists all keys we have
	METHOD(showKeys)
	 	params [P_THISOBJECT, P_ARRAY("_keys"), P_ARRAY("_keysAddedBy")];
		
		OOP_INFO_1("SHOW KEYS: %1", _this);

		if ((count _keys) != (count _keysAddedBy)) exitWith {
			OOP_ERROR_0("Keys and keysAddedBy size mismatch");
			OOP_ERROR_1(" Keys:          %1", _keys);
			OOP_ERROR_1(" Keys added by: %1", _keysAddedBy);
		};

		pr _ctrl = T_CALLM1("findControl", "STATIC_KEYS");

		pr _endl = toString [13, 10];
		pr _str = "";
		{
			_str = _str + format ["%1 added by %2", _x, _keysAddedBy#_forEachIndex];
			_str = _str + _endl;
		} forEach _keys;

		_ctrl ctrlSetText _str;
	ENDMETHOD;

	// Called on client REMOTELY by server to show the radio keys
	// _keys - array of strings
	STATIC_METHOD(staticServerShowKeys)
		params [P_THISCLASS, P_ARRAY("_keys"), P_ARRAY("_keysAddedBy")];

		OOP_INFO_1("STATIC SERVER SHOW KEYS: %1", _this);

		pr _inst = CALLSM0(_thisClass, "getInstance");
		if (!IS_NULL_OBJECT(_inst)) then {
			_thisClass = nil;
			CALLM2(_inst, "showKeys", _keys, _keysAddedBy);
		};
	ENDMETHOD;

	// Called on client REMOTELY by server to show some response
	STATIC_METHOD(staticServerShowResponse)
		params [P_THISCLASS, P_STRING("_text")];

		OOP_INFO_1("STATIC SERVER SHOW RESPONSE: %1", _text);

		pr _inst = CALLSM0(_thisClass, "getInstance");
		if (!IS_NULL_OBJECT(_inst)) then {
			_thisClass = nil;
			CALLM1(_inst, "showResponse", _text);
		};
	ENDMETHOD;

	/*
	STATIC_METHOD(showServerResponse)
		params [P_THISCLASS, P_STRING("_text")];
		// If this tab is already closed, just throw text into system chat
		if (isNil "gTabCommander") then {
			systemChat _text;
		} else {
			pr _thisObject = gTabCommander;
			pr _dialogObj = T_CALLM0("getDialogObject");
			CALLM1(_dialogObj, "setHintText", _text);
		};
	ENDMETHOD;
	*/

ENDCLASS;