#include "..\macros.h"
/**
	@Author : [Utopia] Amaury
	@Creation : ??/11/17
	@Modified : --
	@Description : Check if points are overlapping in world space
	@Return : BOOLEAN
**/

params [
	["_recPos1",[0,0,0],[[]]],
	["_recPos2",[0,0,0],[[]]]
];

({_x inPolygon _recPos2} count _recPos1) > 0