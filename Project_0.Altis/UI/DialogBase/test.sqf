#include "..\..\OOP_Light\OOP_Light.h"

//if (!isNil "gDialogBase") then {DELETE(gDialogBase);};

private _dlg0 = NEW("DialogBase", [findDisplay 46]);

CALLM2(_dlg0, "setContentSize", 0.5, 0.9);


CALLM2(_dlg0, "addTab", "123", "Construction");
CALLM2(_dlg0, "addTab", "123", "User Settings");
CALLM2(_dlg0, "addTab", "123", "Admin Settings");
CALLM2(_dlg0, "addTab", "123", "Call the police");
CALLM2(_dlg0, "addTab", "123", "Rate this app");
CALLM2(_dlg0, "addTab", "123", "Uninstall arma");
CALLM2(_dlg0, "addTab", "123", "Report UFO");
CALLM2(_dlg0, "addTab", "123", "Loadout");
CALLM2(_dlg0, "addTab", "123", "Jam Satellites");
CALLM2(_dlg0, "addTab", "123", "Build Wall");
CALLM2(_dlg0, "addTab", "123", "Tab 2");
CALLM2(_dlg0, "addTab", "123", "Tab 2");
CALLM2(_dlg0, "addTab", "123", "Tab 2");


private _d0 = CALLM0(_dlg0, "getDisplay");
systemChat format ["1 %1", _d0];


/*
private _dlg1 = NEW("DialogBase", [_d0]);
CALLM2(_dlg1, "resize", 0.6, 0.6);
systemChat format ["2 %1", _d0];
*/