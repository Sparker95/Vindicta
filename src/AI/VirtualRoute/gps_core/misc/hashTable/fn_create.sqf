#include "..\..\macros.h"
/**
	@Author : [Utopia] Amaury
	@Creation : 12/05/17
	@Modified : 27/12/17
	@Description : don't like to do that but we can now store strings without performance issues
**/

params [["_name","temp",[""]]];

_loc = createLocation ["fakeTown",[0,0,0],0,0];
_loc setName _name;

_loc