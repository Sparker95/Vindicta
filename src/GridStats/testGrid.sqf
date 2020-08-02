#include "..\common.h"

if(!isNil "gGrid") then {
	CALLM0(gGrid, "unplot");
	DELETE(gGrid);
};

gGrid = NEW("Grid", [500]);

//CALLM1(gGrid, "setValueAll", 0.1);

private _pos = [10000, 10000];
CALLM2(gGrid, "setValue", _pos, 1.0);

private _pos = [10000, 13000];
CALLM2(gGrid, "setValue", _pos, 1.0);

private _kernel = [[0.5, 0.5, 0.5], [0.5, 1.0, 0.5], [0.5, 0.5, 0.5]];
CALLM1(gGrid, "filter", _kernel);
CALLM1(gGrid, "filter", _kernel);
//CALLM1(gGrid, "filter", _kernel);

CALLM2(gGrid, "plot", 1, true);

//CALLM2(gGrid, "edit", 0.8, 1.0);