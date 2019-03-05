#include "common.hpp"

/*
Class: Cell
One grid of 
*/

CLASS("Grid", "");
	VARIABLE("topLeft");
	VARIABLE("topRight");
	VARIABLE("bottomRight");
	VARIABLE("bottomLeft");

	VARIABLE("cells");

	METHOD("new") {
		params ["_thisObject", "_topLeft", "_topRight", "_bottomRight", "_bottomLeft"];
		OOP_DEBUG_1("_thisObject %1", _thisObject);
		T_SETV("topLeft", _topLeft);
		T_SETV("_topRight", _topRight);
		T_SETV("_bottomRight", _bottomRight);
		T_SETV("_bottomLeft", _bottomLeft);
	} ENDMETHOD;

	METHOD("addCell") {
		params ["_thisObject", "_cell"];
		private _cells = T_GETV("cells");
		_cells pushBack _cell;
	} ENDMETHOD;

ENDCLASS;
