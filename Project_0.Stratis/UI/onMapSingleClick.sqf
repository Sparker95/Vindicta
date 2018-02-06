/*
*/

#include "UICommanderIDC.hpp"
#include "defineCommonGrids.hpp"

diag_log format ["onMapSingleClick: %1 %2 %3 %4 %5", _this, _pos, _units, _shift, _alt];
//diag_log format ["Mouse pos: %1", _pos];

private _displayMap = findDisplay 12; //Map display
private _ctrlMap = _displayMap displayCtrl 51;
private _selectedLocation = objNull;
private _posCursor = getMousePosition;
if(!(isNil "allLocations")) then
{
	//private _ctrlMap = _displayMap displayCtrl 51; //Default map control
	//private _posWorld = (_ctrlMap ctrlMapScreenToWorld _pos) + [0];
	private _selectedLocations = allLocations select {(_x distance2D _pos) < 200};
	//diag_log format ["Locations near the cursor: %1", _selectedLocations];
	if(!(_selectedLocations isEqualTo [])) then
	{
		_selectedLocation = _selectedLocations select 0;
		//diag_log format ["Pos of selected loc: %1", getPos _selectedLocation];
		//diag_log format ["Ctrl map: %1", _ctrlMap];
		private _posScreenLoc = _ctrlMap ctrlMapWorldToScreen (getPos _selectedLocation);
		_posScreenLoc append [0];
		private _posCursor3D = _posCursor + [0];
		//diag_log format ["Distance on screen is: %1 %2 %3", _posCursor3D, _posScreenLoc, _posCursor3D distance _posScreenLoc];
		if(_posCursor3D distance _posScreenLoc > 0.02) then
		{
			_selectedLocation = objNull;
		};
	};
};

private _ctrlGroup = (player getVariable ["ui_ctrl_reinfRequest", []]); //Check if this control has already been created but hidden
if(_ctrlGroup isEqualTo []) then
{
	_ctrlGroup = controlNull;
}
else
{
	_ctrlGroup = _ctrlGroup select 0;
};

diag_log format ["onMapSingleClick: selected location: %1", [_selectedLocation] call loc_fnc_getName];

private _return;
if(_selectedLocation isEqualTo objNull) then //User didn't click on any base, don't show the menu then
{
	_ctrlGroup ctrlShow false;
	_return = false;
}
else //User clicked on location, show the menu to him
{
	if(_ctrlGroup isEqualTo controlNull) then //If the menu hasn't been created yet
	{
		_ctrlGroup = _displayMap ctrlCreate ["reinf_req_group_0", IDC_REINF_REQ_REINF_REQ_GROUP_0];
		player setVariable ["ui_ctrl_reinfRequest", [_ctrlGroup]];
	}
	else
	{	//If the manu has been created already
		if(!(ctrlShown _ctrlGroup)) then //If the menu has been hidden, show it again
		{
			_ctrlGroup ctrlShow true;
		};
	};
	_ctrlGroup ctrlSetPosition [(_posCursor select 0) - 8.5*GUI_GRID_W, (_posCursor select 1)/* + GUI_GRID_H*/];
	_ctrlGroup ctrlCommit 0.0;
	_return = true;
	player setVariable ["ui_selectedLocation", _selectedLocation];
	private _gar = [_selectedLocation] call loc_fnc_getMainGarrison;
	player setVariable ["ui_selectedGarrison", _gar];

	[clientOwner, _selectedLocation] remoteExecCall ["ui_fnc_requestLocationDataServer", 2];
	//[] call compile preprocessfilelinenumbers "UI\updateReinfRequestText.sqf";
};
_return //true if we want to override default engine handling of the mouse click on map