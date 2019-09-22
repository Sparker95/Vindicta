#include "..\..\OOP_Light\OOP_Light.h"

//if (!isNil "gDialogBase") then {DELETE(gDialogBase);};

private _dlg0 = NEW("DialogBase", [findDisplay 46]);

//CALLM2(_dlg0, "setContentSize", 0.78, 0.9);

// Multi tab test
CALLM1(_dlg0, "enableMultiTab", true);
CALLM2(_dlg0, "addTab", "DialogTabBase", "Construction");
CALLM2(_dlg0, "addTab", "DialogTabBase", "User Settings");
CALLM2(_dlg0, "addTab", "DialogTabBase", "Admin Settings");
CALLM2(_dlg0, "addTab", "DialogTabBase", "Call the police");
CALLM2(_dlg0, "addTab", "DialogTabBase", "Rate this app");
CALLM1(_dlg0, "setCurrentTab", 0);



//CALLM1(_dlg0, "setCurrentTab", 1);

//CALLM1(_dlg0, "enableMultiTab", false);

// Single tab test
/*
//CALLM1(_dlg0, "enableMultiTab", false);
CALLM2(_dlg0, "addTab", "DialogTabBase", "noname");
CALLM1(_dlg0, "setCurrentTab", 0);
//CALLM2(_dlg0, "addTab", "DialogTabBase", "noname");
*/

/*
private _dlg1 = NEW("DialogBase", [_d0]);
CALLM2(_dlg1, "resize", 0.6, 0.6);
systemChat format ["2 %1", _d0];
*/