#include "UICommanderIDC.hpp"
#include "defineCommonGrids.hpp"

private _loc = player getVariable ["ui_selectedLocation", objNull];

//[clientOwner, _loc, _this] remoteExecCall ["ui_fnc_requestReinfServer", 2];

disableSerialization;

//Show the listbox
private _ctrlListbox = (findDisplay 12) displayCtrl IDC_REINF_REQ_REINF_REQ_LISTBOX_0;
if(isNull _ctrlListbox) then
{
	_ctrlListbox = (findDisplay 12) ctrlCreate ["reinf_req_listbox_0", IDC_REINF_REQ_REINF_REQ_LISTBOX_0];
};

private _pos = ctrlPosition ((finddisplay 12) displayCtrl IDC_REINF_REQ_REINF_REQ_GROUP_0);
_ctrlListbox ctrlSetPosition [(_pos select 0) + 8.5*GUI_GRID_W, (_pos select 1) + 0.5*GUI_GRID_H];
_ctrlListbox ctrlCommit 0.0;

//Add items to the LB
{
	_ctrlListbox lbAdd _x;
}forEach ["Item 0\newline", "Item 1", "Item 2"];

_ctrlListbox ctrlShow true;

[_loc] spawn
{
	private _loc = _this select 0;
	sleep 1;
	//[] call compile preprocessfilelinenumbers "UI\updateReinfRequestText.sqf";
	[clientOwner, _loc] remoteExecCall ["ui_fnc_requestLocationDataServer", 2];
};