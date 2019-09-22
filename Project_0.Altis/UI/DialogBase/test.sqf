#include "..\..\OOP_Light\OOP_Light.h"

//if (!isNil "gDialogBase") then {DELETE(gDialogBase);};

private _dlg0 = NEW("DialogBase", [findDisplay 46]);
CALLM2(_dlg0, "resize", 0.3, 0.3);
private _d0 = CALLM0(_dlg0, "getDisplay");
systemChat format ["1 %1", _d0];

private _dlg1 = NEW("DialogBase", [_d0]);
CALLM2(_dlg1, "resize", 0.6, 0.6);
systemChat format ["2 %1", _d0];