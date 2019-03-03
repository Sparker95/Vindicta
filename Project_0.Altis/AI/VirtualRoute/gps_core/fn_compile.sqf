#include "macros.h"
/**
	@Author : [Utopia] Amaury
	@Creation : 22/10/17
	@Modified : 05/11/17
	@Description : CompileFinal a file , adding a specific header
	@Return : Code 
**/

params [
	["_path","",[""]],
	["_fileName","",[""]],
	["_disableHeader",false,[true]]
];

_fileName = format["%1.sqf",_fileName];

private _header = [format["private _thisFile = '%1';",_fileName],""] select _disableHeader;

compileFinal format["%1%2",
	_header,
	preprocessFileLineNumbers format
	["%1%2%3",
		gps_core_dir + _path,
		if (_path isEqualTo "") then {""}else{"\"},
		_fileName
	]
];