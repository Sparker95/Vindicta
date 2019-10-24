#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Location\Location.hpp"

#define pr private

CLASS("InGameMenuTabCommander", "DialogTabBase")

	METHOD("new") {
		params [P_THISOBJECT];
		gTabCommander = _thisObject;
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		gTabCommander = nil;
	} ENDMETHOD;

	METHOD("createControl") {
		params [P_THISOBJECT, ["_displayParent", displayNull, [displayNull]]];

		pr _group = _displayParent ctrlCreate ["TAB_CMDR", -1];

		pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_COMBO_LOC_TYPE");
		OOP_INFO_1("COMBO CTRL: %1", ctrlClassName _ctrl);
		_ctrl lbAdd "Camp";
		_ctrl lbAdd "Outpost";
		_ctrl lbAdd "Roadblock";
		_ctrl lbSetData [0, LOCATION_TYPE_CAMP];
		_ctrl lbSetData [1, LOCATION_TYPE_OUTPOST];
		_ctrl lbSetData [2, LOCATION_TYPE_ROADBLOCK];

		T_CALLM3("controlAddEventHandler", "TAB_CMDR_BUTTON_CREATE_LOC", "buttonClick", "onButtonCreateLocation");

		_group
	} ENDMETHOD;

	METHOD("onButtonCreateLocation") {
		params [P_THISOBJECT];

		OOP_INFO_0("ON BUTTON CREATE LOCATION");

		pr _ctrlLocName = T_CALLM1("findControl", "TAB_CMDR_EDIT_LOC_NAME");
		pr _locName = ctrlText _ctrlLocName;

		pr _ctrlLocType = T_CALLM1("findControl", "TAB_CMDR_COMBO_LOC_TYPE");
		pr _row = lbCurSel _ctrlLocType;
		
		pr _dialogObj = T_CALLM0("getDialogObject");

		// Ensure that player has enough resources
		pr _playerBuildRes = CALLSM1("Unit", "getInfantryBuildResources", player);
		OOP_INFO_1("Player's build resources: %1", _playerBuildRes);
		if (_playerBuildRes < 20) exitWith {
			CALLM1(_dialogObj, "setHintText", "You must have at least 20 build resources in your backpack!");
		};

		// Ensure proper input
		if (count _locName == 0) exitWith {
			CALLM1(_dialogObj, "setHintText", "You must specify a proper name");
		};

		if (_row < 0) exitWith {
			CALLM1(_dialogObj, "setHintText", "You must select a location type");
		};

		// Send data to cmdr at the server
		// Server might run extra checks
		pr _locType = _ctrlLocType lbData _row;
		pr _AI = CALLSM1("AICommander", "getCommanderAIOfSide", playerSide);
		pr _args = [clientOwner, getPosWorld player, _locType, _locName];
		CALLM2(_AI, "postMethodAsync", "clientCreateLocation", _args);

		CALLM1(_dialogObj, "setHintText", "Creating new location ...");
	} ENDMETHOD;

	STATIC_METHOD("showServerResponse") {
		params [P_THISCLASS, P_STRING("_text")];
		// If this tab is already closed, just throw text into system chat
		if (isNil "gTabCommander") then {
			systemChat _text;
		} else {
			pr _thisObject = gTabCommander;
			pr _dialogObj = T_CALLM0("getDialogObject");
			CALLM1(_dialogObj, "setHintText", _text);
		};
	} ENDMETHOD;

ENDCLASS;