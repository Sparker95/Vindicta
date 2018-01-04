//todo redo this

#include "UICommanderIDC.hpp";

private _si0 = 1.0; //sleep interval
private _si1 = 2.0;
private _hcGroups = [];
disableSerialization;
private _displayMap = findDisplay 12;
private _ctrlText = (_displayMap displayCtrl IDC_GROUP_DATA_TEXT_0);
while{true} do
{
	if(visibleMap) then
	{
		_hcGroups = hcSelected player;
		diag_log format ["HC selected groups: %1", _hcGroups];
		if(count _hcGroups > 0) then
		{
			[clientOwner, _hcGroups] remoteExecCall ["ui_fnc_updateGroupDataServer", 2];
			//_ctrlText ctrlSetText _text;
		}
		else
		{
			_ctrlText ctrlSetText "No group selected";
		};
		sleep _si0;
	}
	else
	{
		sleep _si1;
	};
};