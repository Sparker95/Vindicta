params ["_template", "_cat", "_subCat", "_params", ["_defaultReturn", 0]];
private _fn =  _template#_cat#_subCat;
if(!isNil "_fn") then {
	_params call _fn
} else {
	_defaultReturn
}