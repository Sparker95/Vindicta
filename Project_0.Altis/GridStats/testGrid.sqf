#include "..\OOP_Light\OOP_Light.h"

gGrid = NEW("Grid", [500]);

CALLM1(gGrid, "setValueAll", 0.1);

private _pos = [10000, 10000];
CALLM2(gGrid, "setValue", _pos, -0.8);

CALLM2(gGrid, "plot", 1, true);

CALLM2(gGrid, "edit", 0.8, 1.0);