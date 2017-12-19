disableSerialization;

//private _display = (findDisplay 12) createDisplay "groupControlDisplay";

createDialog "groupControlDisplay";

/*
private _hcGroups = hcSelected player;
{
	player hcRemoveGroup _x;
}forEach _hcGroups;
player setVariable ["ui_hcSelected", _hcGroups, false];

_display displayAddEventHandler ["Unload",
{
	//Return groups back to player
	diag_log "Close event handler!!111";
	private _groups = player getVariable ["ui_hcSelected", []];
	{
		player hcSetGroup [_x, "noname"];
		player hcSelectGroup [_x];
	}forEach _groups;
	hcShowBar true;
}];
*/