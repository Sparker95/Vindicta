#include "defineCommon.inc"

{
	_tag = configName _x;
	_file = getText(_x >> "file");
	{
		pr _name = configName _x;
		pr _file = _file + "\fn_" + _name + ".sqf";
		_fncName = format["JN_fnc_%1",_name];

		_fncName = compile preprocessFile _file;
	}forEach ("true" configClasses _x);
}forEach ("true" configClasses (missionConfigFile >> "cfgFunctions" >> "JN")) ;


