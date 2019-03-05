#include "common.hpp"

/*
Class: Cell
One Cell of a grid 
*/

CLASS("Cell", "");
	// parent grid of this cell
	VARIABLE("grid");

	VARIABLE("topLeft");
	VARIABLE("topRight");
	VARIABLE("bottomRight");
	VARIABLE("bottomLeft");

	VARIABLE("datas");
	VARIABLE("datas");
	VARIABLE("datas");
	VARIABLE("datas");

	METHOD("new") {
		params ["_thisObject", "_topLeft", "_topRight", "_bottomRight", "_bottomLeft"];
		OOP_DEBUG_1("_thisObject %1", _thisObject);
		T_SETV("topLeft", _topLeft);
		T_SETV("_topRight", _topRight);
		T_SETV("_bottomRight", _bottomRight);
		T_SETV("_bottomLeft", _bottomLeft);
	} ENDMETHOD;

ENDCLASS;
