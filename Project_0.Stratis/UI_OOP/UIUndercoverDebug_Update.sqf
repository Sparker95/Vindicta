#include "..\UI_OOP\oop.h"

#define pr private

cutRsc ["UIUndercoverDebug", "PLAIN", -1, false];

// create the dialog like this:
// cutRsc ["NewDialog", "PLAIN", -1, false];

// Then activate this script like this:
// call compile preprocessfilelinenumbers "testDialogUpdate.sqf";


[] spawn {

	while {true} do {
		sleep 0.3;

		pr _suspicion = player getVariable "suspicion";
		pr _ctrl = "getOOP_Text_101_Susp" call UIUndercoverDebug;


		_ctrl ctrlSetText format ["Suspicion: %1", _suspicion];
	};
};