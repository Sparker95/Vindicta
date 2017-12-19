/*
Functions like set- or get-value stay here.
*/

gar_fnc_setName =
{
	/*
	Sets the name of this garrison. Currently name is used only for debug.
	*/
	params ["_lo", "_name"];
	_lo setVariable ["g_name", _name];
};

gar_fnc_setSide =
{
	/*
	Sets the side of this garrison
	*/
	params ["_lo", "_side"];
	_lo setVariable ["g_side", _side];
};

gar_fnc_getSide =
{
	params ["_lo"];
	private _return = _lo getVariable ["g_side", []];
	_return
};

gar_fnc_setLocation =
{
	/*
	Sets the location object of this garrison
	*/
	params ["_lo", "_location"];
	_lo setVariable ["g_location", _location];
};

gar_fnc_setTemplate =
{
	/*
	Sets the template array of this garrison. By default no template is specified.
	*/
	params ["_lo", "_template"];
	_lo setVariable ["g_template", _template];
};

gar_fnc_getTemplate =
{
	params ["_lo"];
	private _return = _lo getVariable ["g_template", []];
	_return
};

gar_fnc_isSpawned =
{
	params ["_lo"];
	private _return = _lo getVariable ["g_spawned", []];
	_return
};

gar_fnc_getAllGroupHandles =
{
	/*
	Returns group handles of all groups in this garrison.
	*/
	params ["_lo"];
	private _hGs = [];
	private _hG = grpNull;
	private _groups = _lo getVariable ["g_groups", []];
	{
		_hG = _x select 1;
		if(!(_hG isEqualTo grpNull)) then
		{
			_hGs pushback _hG;
		};
	}forEach _groups;
	_hGs
};