/*
Adds a new, not-yet-existant unit to the garrison based on provided category, subcategory and classid.

Usage:
[_lo, catID, subcatID, classnameID, _groupID] - to add a unit with specific category, subcategory and classnameID
[_lo, catID, subcatID, -1, _groupID] - to add a unit with specific category, subcategory. Classname is randomly selected from the template for this subcategory.

_groupID - the ID of the group this unit will join. -1 if the unit isn't assigned to any group, but it's allowed only for vehicles.

_returnArray - after the unit is added, its unitID will be written to this array. Use gar_fnc_requestDone to wait until the unit has been added.
*/

#include "garrison.hpp"

params ["_lo", "_template", "_catID", "_subcatID", "_classID", "_groupID", ["_returnArray", []], ["_debug", true]];

//Check validity of IDs
private _valid = false;
if(_classID == -1) then
{
	if(([_template, _catID, _subcatID, 0] call t_fnc_isValid)) then
	{
		_valid = true;
	};
}
else
{
	if(([_template, _catID, _subcatID, _classID] call t_fnc_isValid)) then
	{
		_valid = true;
	};
};

if(!_valid) exitWIth {
	diag_log format ["fn_addNewUnit.sqf: garrison: %1, error: wrong classname data: %2", _lo getVariable ["g_name", ""], [_catID, _subcatID, _classID]];
};

//If a random class was requested to be added
private _class = "";
if(_classID == -1) then
{
	private _classData = [_template, _catID, _subcatID] call t_fnc_selectRandom;
	_class = _classData select 0;
}
else
{
	_class = [_template, _catID, _subcatID, _classID] call t_fnc_select;
};

//Add it to the queue
private _queue = _lo getVariable ["g_threadQueue", []];
private _newUnitData = [_catID, _subcatID, _class, _groupID];
_queue pushBack [G_R_ADD_NEW_UNIT, _newUnitData, _returnArray];

private _hThread = _lo getVariable ["g_threadHandle", nil];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID