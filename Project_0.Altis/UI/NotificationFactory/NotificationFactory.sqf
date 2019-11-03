#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG
#define OFSTREAM_FILE "ui.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

/*
Class: NotificationFactory

Has methods specialized for customization of our typical notification types
*/

CLASS("NotificationFactory", "")

	// Intel about locations we have discovered
	STATIC_METHOD("createIntelLocation") {
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text"), P_STRING("_hint")];

		private _sound = "defaultNotification";
		private _picture = ""; // Default picture for now
		private _duration = 8;
		private _hint = "Check map for more info"; // Override hint!
		private _args = [_picture, _category, _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	} ENDMETHOD;

	// Intel about commander actions
	STATIC_METHOD("createIntelCommanderAction") {
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text"), P_STRING("_hint")];

		private _sound = "defaultNotification";
		private _picture = ""; // Default picture for now
		private _duration = 10;
		private _hint = "Check map for more info"; // Override hint!
		private _args = [_picture, _category, _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	} ENDMETHOD;

	// Basic UI notification
	STATIC_METHOD("createBasicUI") {
		params [P_THISOBJECT, P_NUMBER("_type"), P_STRING("_text"), P_STRING("_hint")];

		// todo we can make success/failure/info types, with different sounds and pictures! Marvis??

		private _sound = "hint";
		private _picture = ""; // Default picture for now
		private _duration = 5;
		private _args = [_picture, "INFO", _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	} ENDMETHOD;

ENDCLASS;