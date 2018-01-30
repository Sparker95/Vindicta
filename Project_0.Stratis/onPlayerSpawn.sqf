//todo redo this crap
//it just waits until the map display is available meaning that we can manipulate the map display now

#include "UI\UICommanderIDC.hpp"

(finddisplay 12) ctrlCreate ["group_data_group_0", IDC_GROUP_DATA_GROUP_DATA_GROUP_0];
//(finddisplay 12) ctrlCreate ["group_data_group_1", IDC_GROUP_DATA_GROUP_DATA_GROUP_0];
(findDisplay 12) displayAddEventHandler["KeyDown",
{
	diag_log format ["KeyDown: %1", _this];
	if(_this select 1 == 21) then
	{
		call compile preprocessfilelinenumbers "UI\showGroupControl.sqf";
	};
	false}
];
[] spawn compile preprocessfilelinenumbers "UI\commanderUIUpdate.sqf";
