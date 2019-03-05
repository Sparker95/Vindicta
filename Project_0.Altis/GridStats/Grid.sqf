#include "common.hpp"

/*
Class: Grid
Properties:
	startX: float
	startY: float
	sizeX: float
	sizeY: float
	gridArray: Array
*/

CLASS("Grid", "");
	VARIABLE("startX");
	VARIABLE("startY");
	VARIABLE("sizeX");
	VARIABLE("sizeY");
	VARIABLE("gridSizeX");
	VARIABLE("gridSizeY");
	VARIABLE("squareSize");

	VARIABLE("gridArray");

	METHOD("new") {
		params ["_thisObject", "_startX", "_startY", "_sizeX", "_sizeY", "_squareSize"];

		private _gridSizeX = floor(_sizeX / ws_squareSize); //Size of the grid measured in squares
		private _gridSizeY = floor(_sizeY / ws_squareSize);
		
		T_SETV("startX", _startX);
		T_SETV("startY", _startY);
		T_SETV("sizeX", _sizeX);
		T_SETV("sizeY", _sizeY);
		T_SETV("squareSize", squareSize);
		T_SETV("gridSizeX", _sizeY);
		T_SETV("gridSizeY", _sizeY);

		private _gridArray = [];
		for [{private _i = 0}, {_i < _startX}, {_i = _i + 1}] do //_i is x-pos
		{
			_column = [];
			for [{private _j = 0}, {_j < _startY}, {_j = _j + 1}] do //_j is y-pos
			{
				_column pushBack 0;
			};
			_gridArray pushback _column;
		};

		T_SETV("gridArray", _gridArray);
	} ENDMETHOD;

	METHOD("getGridArray") {
		private _gridArray = T_GETV("gridArray");
		_gridArray
	} ENDMETHOD;

ENDCLASS;
