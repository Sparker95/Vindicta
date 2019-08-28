#include "..\Resources\defineCommonGrids.hpp"
#include "..\Resources\ClientMapUI\ClientMapUI_Macros.h"

// delete prev controls
{
	systemChat format ["Deleting ctrl id %1   idd map: %2", _x, IDD_MAP];
	ctrlDelete ((finddisplay 12) displayCtrl _x);
} forEach [IDC_GCOM_ACTION_LISTNBOX, IDC_GCOM_ACTION_LISTNBOX_BG];

_bg = ((finddisplay 12)) ctrlCreate ["CMUI_GCOM_ACTION_LISTBOX_BG", IDC_GCOM_ACTION_LISTNBOX_BG];
_lb = ((finddisplay 12)) ctrlCreate ["CMUI_GCOM_ACTION_LISTBOX", IDC_GCOM_ACTION_LISTNBOX];
_lb lnbAddRow ["Move"];
_lb lnbAddRow ["Attack"];
_lb lnbAddRow ["Join"];
_lb lnbAddRow ["Patrol"];
_lb lnbAddRow ["<Close>"];

// Set height
_config = missionconfigfile >> "CMUI_GCOM_ACTION_LISTBOX" >> "rowHeight";
_rowHeight = if (isText _config) then {
call compile (getText _config)
} else {
getNumber _config
};

_nRows = (lnbSize _lb) select 0;
_height = _nRows*_rowHeight;
{
_x ctrlSetPositionH _height;
_x ctrlCommit 0;
} forEach [_lb, _bg];
