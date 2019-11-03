#define NAMESPACE uiNamespace
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#include "..\..\OOP_Light\OOP_Light.h"

#define pr private

CLASS("Notification", "")

	VARIABLE("control");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text"), P_STRING("_hint")];

		pr _group = (findDisplay 46) ctrlCreate ["NOTIFICATION_GROUP", -1];

		OOP_INFO_1("NEW $1", _this);
		OOP_INFO_1("  control: %1", _group);

		pr _ctrl = uiNamespace getVariable "vin_not_category";
		_ctrl ctrlSetText _category;

		pr _ctrl = uiNamespace getVariable "vin_not_text";
		_ctrl ctrlSetText _text;

		pr _ctrl = uiNamespace getVariable "vin_not_hint";
		_ctrl ctrlSetText _hint;

		#ifndef _SQF_VM
		_group ctrlSetPositionX safeZoneX;
		_group ctrlSetPositionY 0.5;
		#endif

		T_SETV("control", _group);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		pr _group = T_GETV("control");
		ctrlDelete _group;
	} ENDMETHOD;

ENDCLASS;