/*
Finds to which category and subcategory this classname belongs

Return value: an array of arrays like: - for each match
[_cat, _subcat, _classID]
_cat - category
_subcat - subcategory
_classID - ID of the class in the subcategory
*/

params ["_template", "_class"];

private _catID = 0;
private _subcatID = 0;
private _classID = 0;
private _count2 = 0;
private _count3 = 0;
private _found = false;
private _return = [];
private _item = "";

while {_catID < T_SIZE} do
{
	_cat = _template select _catID;
	if (! (isNil "_cat")) then
	{
		if (_cat isEqualType []) then {
			_count2 = count _cat;
			_subcatID = 0;
			while {_subcatID < _count2} do
			{
				_subcat = _cat select _subcatID;
				if(!(isNil "_subcat")) then
				{
					_count3 = count _subcat;
					_classID = 0;
					while {_classID < _count3} do
					{
						//diag_log format ["%1 %2 %3", _catID, _subcatID, _classID];
						_item = _subcat select _classID;
						//diag_log format ["item: %1", _item];
						if(typeName _item isEqualTo typeName _class) then
						{
							if ( _item == _class && _subcatID != 0) then //If it's not a default class
							{
								_return pushback [_catID, _subcatID, _classID];
								//_found = true;
							};
						};

						//if(_found) exitWith {};
						_classID = _classID + 1;
					};
				};
				//if(_found) exitWith {};
				_subcatID = _subcatID + 1;
			};
		};
	};
	//if(_found) exitWith {};
	_catID = _catID + 1;
};

_return
