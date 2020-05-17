#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG
#define OFSTREAM_FILE "ui.rpt"
#include "..\..\common.h"

/*
Class: NotificationFactory

Has methods specialized for customization of our typical notification types
*/

//							  R    G    B    A
#define WHITE 				[ 1.0, 1.0, 1.0, 1.0]
#define BLACK 				[ 0.0, 0.0, 0.0, 1.0]
#define GREY 				[ 0.5, 0.5, 0.5, 1.0]
#define RED 				[ 1.0, 0.2, 0.2, 1.0]
#define YELLOW 				[ 1.0, 0.9, 0.2, 1.0]
#define BLUE 				[ 0.2, 0.2, 0.4, 1.0]
#define GREEN 				[ 0.2, 0.4, 0.2, 1.0]
#define PURPLE 				[ 0.4, 0.2, 0.4, 1.0]
#define CYAN 				[ 0.2, 0.4, 0.4, 1.0]

//							Fore	Back
#define INTEL_COLORS 		WHITE, 	BLACK
#define ACTION_COLORS 		BLACK, 	YELLOW
#define RESOURCE_COLORS 	WHITE, 	GREY
#define RADIO_COLORS 		WHITE, 	GREEN
#define SYSTEM_COLORS 		WHITE, 	PURPLE
#define HINT_COLORS 		WHITE, 	CYAN
#define CRITICAL_COLORS 	WHITE, 	RED

#define OOP_CLASS_NAME NotificationFactory
CLASS("NotificationFactory", "")

	// Intel about locations we have discovered
	STATIC_METHOD(createIntelLocation)
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text"), P_STRING("_hint")];

		private _sound = "UAV_01";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\map_ca.paa";
		private _duration = 8;
		private _hint = "Check your map for more info"; // Override hint!
		private _args = [_picture, [_category, INTEL_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Intel about commander actions
	STATIC_METHOD(createIntelCommanderAction)
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text")];

		private _sound = "UAV_02";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\infoNews_ca.paa";
		private _duration = 10;
		private _hint = "Check your map for more info"; // Override hint!
		private _args = [_picture, [_category, ACTION_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Intel about commander actions
	STATIC_METHOD(createIntelCommanderActionReminder)
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text")];

		private _sound = "Topic_Done";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\watch_ca.paa";
		private _duration = 10;
		private _hint = "Check your map for more info"; // Override hint!
		private _important = true;
		private _args = [_picture, [_category, ACTION_COLORS], _text, _hint, _duration, _sound, _important];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Resource notification
	STATIC_METHOD(createResourceNotification)
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text"), P_STRING("_hint")];

		private _sound = "defaultNotification";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\infoNews_ca.paa";
		private _duration = 5;
		private _args = [_picture, [_category, RESOURCE_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Player location notification
	STATIC_METHOD(createLocationNotification)
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text"), P_STRING("_hint")];

		private _sound = "defaultNotification";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\infoNews_ca.paa";
		private _duration = 5;
		private _args = [_picture, [_category, RESOURCE_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Player garrison notification
	STATIC_METHOD(createGarrisonNotification)
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text"), P_STRING("_hint")];

		private _sound = "defaultNotification";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\infoNews_ca.paa";
		private _duration = 5;
		private _args = [_picture, [_category, RESOURCE_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Gets called when we find a new cryptokey we didn't have yet
	STATIC_METHOD(createRadioCryptokey)
		params [P_THISOBJECT, P_STRING("_key")];

		private _sound = "UAV_03";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\radio_ca.paa";
		private _duration = 25;
		private _category = "RADIO CRYPTOKEY FOUND";
		private _text = format ["Activate it at a friendly radio station!\n%1", _key];
		private _hint = "Check notes in the in-game menu"; // Override hint!
		private _args = [_picture, [_category, RADIO_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// System notification
	STATIC_METHOD(createSystem)
		params [P_THISOBJECT, P_STRING("_text"), P_STRING("_picture")];

		private _sound = "beep_target";
		private _duration = 15;
		private _category = "SYSTEM";
		private _hint = ""; // Override hint!
		if(_picture isEqualTo "") then {
			_picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\menu_options_ca.paa"
		};
		private _args = [_picture, [_category, SYSTEM_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;
	
	// Hint notification
	STATIC_METHOD(createHint)
		params [P_THISOBJECT, P_STRING("_category"), P_STRING("_text"), P_STRING("_hint")];

		private _sound = "hint";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\menu_tutorials_ca.paa";
		private _duration = 10;
		private _args = [_picture, [_category, HINT_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Critical notification
	STATIC_METHOD(createCritical)
		params [P_THISOBJECT, P_STRING("_text")];

		private _sound = "defaultNotification";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\notification_ca.paa";
		private _duration = 15;
		private _category = "CRITICAL MISSION ERROR";
		private _hint = ""; // Override hint!
		private _args = [_picture, [_category, CRITICAL_COLORS], _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Basic UI notification
	STATIC_METHOD(createBasicUI)
		params [P_THISOBJECT, P_NUMBER("_type"), P_STRING("_text"), P_STRING("_hint")];

		// todo we can make success/failure/info types, with different sounds and pictures! Marvis??

		private _sound = "hint";
		private _picture = ""; // Default picture for now
		private _duration = 5;
		private _args = [_picture, "INFO", _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

	// Intel about us spotting something
	STATIC_METHOD(createSpottedTargets)
		params [P_THISOBJECT, P_POSITION("_pos")];
		private _sound = "UAV_04";
		private _picture = "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\binoculars_ca.paa";
		private _duration = 30;
		private _category = "ENEMY SPOTTED";
		private _text = format ["Friendly forces have detected enemies at %1", mapGridPosition _pos];
		private _hint = "Check your map for more info"; // Override hint!
		private _args = [_picture, _category, _text, _hint, _duration, _sound];
		CALLSM("Notification", "createNotification", _args);
	ENDMETHOD;

ENDCLASS;

// ["NotificationFactory", "INTEL LOCATION", "Content here", "hint here."] call NotificationFactory_fnc_createIntelLocation;
// ["NotificationFactory", "INTEL ACTION", "Content here", "hint here..."] call NotificationFactory_fnc_createIntelCommanderAction;
// ["NotificationFactory", "REMINDER", "Content here"] call NotificationFactory_fnc_createIntelCommanderActionReminder;
// ["NotificationFactory", "RESOURCE", "Content here"] call NotificationFactory_fnc_createResourceNotification;
// ["NotificationFactory", "RADIO", "Key"] call NotificationFactory_fnc_createRadioCryptokey;
// ["NotificationFactory", "Content here", "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\icon_ca.paa"] call NotificationFactory_fnc_createSystem;
// ["NotificationFactory", "HINT", "Content here", "hint here..."] call NotificationFactory_fnc_createHint;
// ["NotificationFactory", "CRITICAL", "Content here"] call NotificationFactory_fnc_createCritical;
// ["NotificationFactory", 0, "Content here", "hint here..."] call NotificationFactory_fnc_createBasicUI;
// ["NotificationFactory", [1,2,3]] call NotificationFactory_fnc_createSpottedTargets;
