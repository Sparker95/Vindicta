diag_log format ["group data button: %1", _this];

_hcGroups = hcSelected player;
//private _hcGroups = player getVariable ["ui_hcSelected", []];
if(count _hcGroups > 0) then
{
	[_hcGroups, _this] remoteExec ["ui_fnc_groupDataButtonPressedServer", 2];
};
