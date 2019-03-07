#include "..\macros.h"
/**
	@Author : [Utopia] Amaury
	@Creation : 1/02/17
	@Modified : 23/10/17
	@Description : creates a local marker , really simple .
	@Return : STRING - marker name
**/

params [
	["_name",str (random 100 + random 200),[""]],
	["_pos",[0,0,0],[[]]],
	["_text","",[""]],
	["_type","mil_dot",[""]],
	["_color","ColorBlack",[""]],
	["_size",[1,1],[[]]],
	["_dir",0,[0]]
];

_mark = createMarkerLocal [_name,_pos];
_mark setMarkerTextLocal _text;
_mark setMarkerTypeLocal _type;
_mark setMarkerColorLocal _color;
_mark setMarkerSizeLocal _size;
_mark setMarkerDirLocal _dir;

_mark