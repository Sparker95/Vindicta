/*
Converts a config entry from CfgGroups into an array with [catID, subcatID, classID] of units

example of _configGroup: configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "Bus_InfSquad"
*/

params [["_template", [], [[]]], ["_configGroup", configNull, [configNull]]];

private _types = [];
private _unitClassName = "";
private _count = count _configGroup - 1;
for "_i" from 0 to _count do
{
	private _item = _configGroup select _i;
	if (isClass _item) then	{
		_unitClassName = getText(_item >> "vehicle");
		private _unitClassification = [_template, _unitClassName] call t_fnc_find;
		if(!(_unitClassification isEqualTo [])) then { //If the unit's classname was found
			private _newUnitData = _unitClassification select 0;
			_types pushback _newUnitData;
		} else {
			diag_log format ["[Template] Error: fn_convertConfigGroup.sqf: unit class name was not found in template: %1", _unitClassName];
		};
	};
};

_types