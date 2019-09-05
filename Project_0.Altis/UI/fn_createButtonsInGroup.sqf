/*
Creates buttons in a group control.

_columnsPosRel - logical positions of each column, same as in listNbox
Returns an array of created controls.
*/

params ["_display", "_ctrlClass", "_idcBase", "_ctrlGroup", "_columnsPosRel", ["_deleteOldControls", false]];

// Delete old controls in this group control if needed
if (_deleteOldControls) then {
	{ ctrlDelete _x; } forEach ((allControls _display) select {
		(ctrlParentControlsGroup _x) isEqualTo _ctrlGroup
	});
};

private _nButtons = count _columnsPosRel;
private _cp = +_columnsPosRel;
private _d = 0.001*safeZoneW; // Some small number, offset for height and width to make it not clip out of group and trigger a scroll bar
_cp pushBack 1.0;
(ctrlPosition _ctrlGroup) params ["_grpx", "_grpy", "_grpw", "_grph"];
private _idc = _idcBase;
private _ret = [];
for "_i" from 0 to (_nButtons-1) do {
	private _btnx = _grpw * (_cp#_i);
	private _btny = 0;
	private _btnw = _grpw * ( (_cp#(_i+1)) - (_cp#_i) );
	if (_i < (_nButtons-1) ) then {
		_btnw + _d;
	} else {
		_btnw - _d;
	};
	private _btnh = _grph - _d;

	private _ctrl = _display ctrlCreate [_ctrlClass, _idc, _ctrlGroup];
	_ctrl ctrlSetPosition [_btnx, _btny, _btnw, _btnh];
	diag_log format ["Setting position: %1", [_btnx, _btny, _btnw, _btnh]];
	_ctrl ctrlSetText "<Text>";
	_ctrl ctrlCommit 0;
	_ret pushBack _ctrl;

	_idc = _idc + 1;
};

_ret