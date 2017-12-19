/*
*/

//diag_log format ["onMapSingleClick: %1 %2 %3 %4 %5", _this, _pos, _units, _shift, _alt];
private _pos = getMousePosition;
//diag_log format ["Mouse pos: %1", _pos];

private _ctrlGroup = player getVariable ["ctrl_reinfRequest", controlNull];
if(_ctrlGroup isEqualTo controlNull) then
{
	private _displayMap = findDisplay 12; //Map display
	if(isNull _displayMap) exitWith
	{
		diag_log "Map display not found!";
		true
	};
	_ctrlGroup = _displayMap ctrlCreate ["reinf_req_group_0", 700];
	player setVariable ["ctrl_reinfRequest", _ctrlGroup];
}
else
{
	_ctrlGroup ctrlShow true;
};

_ctrlGroup ctrlSetPosition _pos;
_ctrlGroup ctrlCommit 0;

false