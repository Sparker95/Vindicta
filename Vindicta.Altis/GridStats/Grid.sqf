#include "common.hpp"

/*
Class: Grid
2D array of numbers (like a black and white image).
Each grid occupies whole map and starts at [0, 0].

Authors: Sparker(initial author), Sen(code porting)
*/

#ifndef _SQF_VM
#define WORLD_SIZE worldSize
#else
#define WORLD_SIZE 20000
#endif

#define pr private

#define OOP_CLASS_NAME Grid
CLASS("Grid", "Storable");
	
	// EH ID of mission event handler
	STATIC_VARIABLE("mapSingleClickEH");
	// Grid object which we are currently editing with mouse
	STATIC_VARIABLE("currentGrid");
	STATIC_VARIABLE("currentValue");
	STATIC_VARIABLE("currentScale");
	
	VARIABLE("cellSize");		// Cell size in meters
	VARIABLE("gridSize");		// Integer, amount of cells
	VARIABLE("gridArray");		// Array with arrays with values
	VARIABLE("defaultValue");	// Default value

	/*
	Method: new
	Constructor
	
	Parameters: _cellSize
	
	_cellSize - cell size in meters. Each cell is square. And flat.
	*/

	METHOD(new)
		params [P_THISOBJECT, ["_cellSize", 500], ["_defaultValue", 0, GRID_ELEMENT_TYPES]];

		private _gridSize = ceil(WORLD_SIZE / _cellSize); //Size of the grid measured in squares
		T_SETV("gridSize", _gridSize);
		T_SETV("cellSize", _cellSize);
		T_SETV("defaultValue", _defaultValue);
		
		private _gridArray = [];
		_gridArray resize _gridSize;
		private _initCode = if (_defaultValue isEqualType []) then {
			{
				+_defaultValue	// Make a deep copy if an array was passed
			}
		} else {
			{
				_defaultValue	// For number or string, just make a basic copy
			}
		};
		{
			pr _a = [];
			_a resize _gridSize;
			_gridArray set [_forEachIndex, _a apply  _initCode];
		} forEach _gridArray;

		T_SETV("gridArray", _gridArray);
	ENDMETHOD;

	/*
	Method: getGridArray
	Returns the underlying 2D array.
	
	Returns: Array
	*/
	METHOD(getGridArray)
		params [P_THISOBJECT];
		T_GETV("gridArray")
	ENDMETHOD;
	
	/*
	Method: getCellSize
	Returns cell size of this grid.
	
	Returns: Number
	*/
	METHOD(getCellSize)
		params [P_THISOBJECT];
		T_GETV("cellSize")
	ENDMETHOD;

	/*
	Method: getGridSize
	Returns grid size - integer number, amount of cells in this grid
	*/
	METHOD(getGridSize)
		params [P_THISOBJECT];
		T_GETV("gridSize");
	ENDMETHOD;

	// - - - - Setting values - - - -

	/*
	Method: setValueAll
	Sets all elements to constant value
	
	Parameters: _value
	
	_value - Number
	
	Returns: nil
	*/
	METHOD(setValueAll)
		params [P_THISOBJECT, ["_value", 0, GRID_ELEMENT_TYPES]];
		
		pr _gridArray = T_GETV("gridArray");
		pr _n = count _gridArray;
		{
			pr _a = [];
			_a resize _n;
			_gridArray set [_forEachIndex, _a apply {_value}];
		} forEach _gridArray;
	ENDMETHOD;
	
	/*
	Method: setValue
	Sets value of element specified by world coordinates
	
	Parameters: _pos, _value
	
	_pos - array, position: [x, y] or [x, y, z], but only x and y matter.
	_value - Number
	
	Returns: nil
	*/
	
	METHOD(setValue)
		params [P_THISOBJECT, P_ARRAY("_pos"), ["_value", 0, GRID_ELEMENT_TYPES]];
	
		_pos params ["_x", "_y"];
		
		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");
	
		pr _xID = floor(_x / _cellSize);
		pr _yID = floor(_y / _cellSize);
		
		(_array select _xID) set [_yID, _value];
	
	ENDMETHOD;

	/*
	Method: addValue
	Adds value to element specified by world coordinates
	
	Parameters: _pos, _value
	
	_pos - array, position: [x, y] or [x, y, z], but only x and y matter.
	_value - Number
	
	Returns: new value of the element.
	*/
	
	METHOD(addValue)
		params [P_THISOBJECT, P_ARRAY("_pos"), ["_value", 0, [0, []]]];
	
		_pos params ["_x", "_y"];
		
		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");
	
		pr _xID = floor(_x / _cellSize);
		pr _yID = floor(_y / _cellSize);
		
		pr _v = (_array select _xID) select _yID;
		if(_v isEqualType 0) then {
			_v = _v + _value;
		} else {
			_v = +_v;
			{
				_v set [_forEachIndex, (_v select _forEachIndex) + _x];
			} forEach _value;
		};
		(_array select _xID) set [_yID, _v];

		_v
	ENDMETHOD;

	/*
	Method: findValue
	Checks if there is a given value in this grid.
	
	Parameters: _value
	
	Returns: Bool
	*/
	METHOD(findValue)
		params [P_THISOBJECT, ["_value", 0, GRID_ELEMENT_TYPES]];

		pr _gridArray = T_GETV("gridArray");
		pr _index = _gridArray findIf {
			pr _index0 = _x findIf {_x isEqualTo _value};
			_index0 != -1
		};

		_index != -1
	ENDMETHOD;

	METHOD(applyRect)
		params [P_THISOBJECT, P_ARRAY("_pos"), P_ARRAY("_size"), P_CODE("_fnApplyRect")];

		_pos params ["_x", "_y"];
		_size params ["_w", "_h"];

		private _gridArray = T_GETV("gridArray");
		private _cellSize = T_GETV("cellSize");
		private _gridSize = T_GETV("gridSize");
		private _xID = 0 max floor(_x / _cellSize) min (_gridSize-1);
		private _yID = 0 max floor(_y / _cellSize) min (_gridSize-1);

		// This is a bit awkward using ceil and then -1. It is intended to ensure that a rect that is 
		// entirely out of bounds doesn't still draw a line down the edge of the map, as it would if 
		// it was floor and no -1 (due to the stupid inclusive for loops)
		private _x2ID = (0 max ceil((_x + _w) / _cellSize) min (_gridSize-1)) - 1;
		private _y2ID = (0 max ceil((_y + _h) / _cellSize) min (_gridSize-1)) - 1;

		for "_i" from _xID to _x2ID do {
			private _row = _gridArray#_i;
			for "_j" from _yID to _y2ID do {
				[_i, _j, _row] call _fnApplyRect;
			};
		};
	ENDMETHOD;

	METHOD(applyCircle)
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_radius"), P_CODE("_fnApplyCircle")];

		private _gridArray = T_GETV("gridArray");
		private _cellSize = T_GETV("cellSize");

		// Wrap the default fn with some special behaviour for circles: calculate distance to center and
		// only call into _fn if we are inside the circle. Pass dist so it can be used for falloff or whatever.
		private _circleWrapperFn = {
			params ["_i", "_j", "_row"];
			private _pos = [(_i + 0.5) * _cellSize, (_j + 0.5) * _cellSize, 0];
			private _dist = _pos distance _center;
			// Might want to do some kind of coverage here?
			if(_dist <= _radius + _cellSize * 0.5) then {
				[_i, _j, _dist, _row] call _fnApplyCircle;
			};
		};

		private _pos = [_center#0 - _radius, _center#1 - _radius];
		private _size = [_radius * 2, _radius * 2];
		T_CALLM("applyRect", [_pos ARG _size ARG _circleWrapperFn]);
	ENDMETHOD;

	// Set value to max of the current and new values
	METHOD(maxRect)
		params [P_THISOBJECT, P_ARRAY("_pos"), P_ARRAY("_size"), ["_value", 0, [0, []]]];
		private _fnMax =
			if(_value isEqualType 0) then {
				{
					params ["_i", "_j", "_row"];
					_row set [_j, _row#_j max _value];
				}
			} else {
				{
					params ["_i", "_j", "_row"];
					private _origVal = _row#_j;
					{
						_origVal set [_forEachIndex, (_origVal select _forEachIndex) max _x];
					} forEach _value;
				}
			};
		
		T_CALLM("applyRect", [_pos ARG _size ARG _fnMax]);
	ENDMETHOD;

	// Set value to max of the current and new values in a circle
	METHOD(maxCircle)
		params [P_THISOBJECT, P_ARRAY("_center"), P_ARRAY("_radius"), ["_value", 0, [0, []]]];
		private _fnMax =
			if(_value isEqualType 0) then {
				{
					params ["_i", "_j", "_dist", "_row"];
					_row set [_j, _row#_j max _value];
				}
			} else {
				{
					params ["_i", "_j", "_dist", "_row"];
					private _origVal = _row#_j;
					{
						_origVal set [_forEachIndex, (_origVal select _forEachIndex) max _x];
					} forEach _value;
				}
			};
		T_CALLM("applyCircle", [_center ARG _radius ARG _fnMax]);
	ENDMETHOD;
	// - - - - - Getting values - - - - -

	/*
	Method: getValue
	Gets value of the element specified by world coordinates
	
	Parameters: _pos
	
	_pos - array, position: [x, y] or [x, y, z], but only x and y matter.
	
	Returns: Number, value of the element.
	*/
	METHOD(getValue)
		params [P_THISOBJECT, P_ARRAY("_pos")];

		_pos params ["_x", "_y"];

		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");

		pr _xID = floor(_x / _cellSize);
		pr _yID = floor(_y / _cellSize);

		pr _v = (_array select _xID) select _yID;

		_v
	ENDMETHOD;

	/*
	Method: getValueSafe
	Same as getValue, but ensures that coordinates are within range.

	If not, default value is returned.
	*/
	METHOD(getValueSafe)
		params [P_THISOBJECT, P_ARRAY("_pos")];

		_pos params ["_x", "_y"];

		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");
		pr _gridSize = T_GETV("gridSize");

		pr _xID = floor(_x / _cellSize);
		pr _yID = floor(_y / _cellSize);

		if (_xID < 0 || _xID >= _gridSize) exitWith {T_GETV("defaultValue")};
		if (_yID < 0 || _yID >= _gridSize) exitWith {T_GETV("defaultValue")};

		pr _v = (_array select _xID) select _yID;

		_v
	ENDMETHOD;

	/*
	Method: getMaxValueCircle
	Gets max value found within the circle

	! ! WARNING It's slow, extremely slow, consider using alternative functions instead ! !
	For example, getMaxValueSquareNumber

	
	Parameters: _center, _radius
	
	_center - array, position: [x, y] or [x, y, z], but only x and y matter.
	_radius - number, radius of the circle
	
	Returns: Number or Array, max value found within the circle
	*/
	METHOD(getMaxValueCircle)
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_radius")];

		private _defaultValue = T_GETV("defaultValue");
		if(_defaultValue isEqualType 0) then {
			private _maxVal = -1000000;
			private _fnMax = { 
				params ["_i", "_j", "_dist", "_row"];
				_maxVal = _row#_j max _maxVal;
			};
			T_CALLM("applyCircle", [_center ARG _radius ARG _fnMax]);
			_maxVal
		} else {
			private _maxVal = _defaultValue apply { -1000000 };
			private _fnMax = {
				params ["_i", "_j", "_dist", "_row"];
				private _origVal = _row#_j;
				{
					_maxVal set [_forEachIndex, (_origVal select _forEachIndex) max _x];
				} forEach _maxVal;
			};
			T_CALLM("applyCircle", [_center ARG _radius ARG _fnMax]);
			_maxVal
		};
	ENDMETHOD;

	// Gets max value at square area centered at _pos as having full width of 2*_halfSize
	METHOD(getMaxValueSquareNumber)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_halfSize")];
		
		_pos params ["_x", "_y"];

		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");

		pr _xID = floor(_x / _cellSize);
		pr _yID = floor(_y / _cellSize);
		pr _nCells = round (_halfSize/_cellSize);	// Nubmer of cells to capture on each side
		pr _xIDStart = (_xID - _nCells) max 0;
		pr _yIDStart = (_yID - _nCells) max 0;
		pr _nCellsSelect = 1 + 2 * _nCells;

		pr _maxx = [];
		{
			pr _col = _x;
			pr _max = selectMax (_col select [_yIDStart, _nCellsSelect]);
			_maxx pushBack _max;
		} forEach (_array select [_xIDStart, _nCellsSelect]);

		selectMax _maxx

	ENDMETHOD;

	/*
	Method: getValueCircleSum
	Gets total value found within the circle
	
	Parameters: _center, _radius
	
	_center - array, position: [x, y] or [x, y, z], but only x and y matter.
	_radius - number, radius of the circle
	
	Returns: Number or Array, total value found within the circle
	*/
	METHOD(getValueCircleSum)
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_radius")];

		private _defaultValue = T_GETV("defaultValue");
		if(_defaultValue isEqualType 0) then {
			private _sumVal = 0;
			private _fnMax = { 
				params ["_i", "_j", "_dist", "_row"];
				_sumVal = _row#_j + _sumVal;
			};
			T_CALLM("applyCircle", [_center ARG _radius ARG _fnMax]);
			_sumVal
		} else {
			private _sumVal = _defaultValue apply { 0 };
			private _fnMax = {
				params ["_i", "_j", "_dist", "_row"];
				private _origVal = _row#_j;
				{
					_sumVal set [_forEachIndex, (_origVal select _forEachIndex) + _x];
				} forEach _sumVal;
			};
			T_CALLM("applyCircle", [_center ARG _radius ARG _fnMax]);
			_sumVal
		};
	ENDMETHOD;

	// Gets sum value at square area centered at _pos as having full width of 2*_halfSize
	METHOD(getValueSquareSum)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_halfSize")];
		
		_pos params ["_x", "_y"];

		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");

		pr _xID = floor(_x / _cellSize);
		pr _yID = floor(_y / _cellSize);
		pr _nCells = round (_halfSize/_cellSize);	// Nubmer of cells to capture on each side
		pr _xIDStart = (_xID - _nCells) max 0;
		pr _yIDStart = (_yID - _nCells) max 0;
		pr _nCellsSelect = 1 + 2 * _nCells;

		pr _sum = 0;
		{
			pr _col = _x;
			{
				_sum = _sum + _x;
			} forEach (_col select [_yIDStart, _nCellsSelect]);
			//pr _max = selectMax (_col select [_yIDStart, _nCellsSelect]);
		} forEach (_array select [_xIDStart, _nCellsSelect]);
		_sum
	ENDMETHOD;
	// - - - - - Image processing - - - -

	METHOD(apply)
		params [P_THISOBJECT, P_CODE("_fn"), P_ARRAY("_args")];

		private _gridArray = T_GETV("gridArray");
		private _cellSize = T_GETV("cellSize");
		private _gridSize = T_GETV("gridSize");

		private _xID = 0;
		private _yID = 0;

		// This is a bit awkward using ceil and then -1. It is intended to ensure that a rect that is 
		// entirely out of bounds doesn't still draw a line down the edge of the map, as it would if 
		// it was floor and no -1 (due to the stupid inclusive for loops)
		private _x2ID = (_gridSize-1);
		private _y2ID = (_gridSize-1);

		for "_i" from _xID to _x2ID do {
			private _row = _gridArray#_i;
			for "_j" from _yID to _y2ID do {
				private _val = _row#_j;
				private _newVal = [[_i, _j], _val, _args] call _fn;
				_row set [_j, _newVal];
			};
		};
	ENDMETHOD;

	METHOD(fade)
		params [P_THISOBJECT, P_NUMBER("_factor")];
		private _defaultValue = T_GETV("defaultValue");
		private _fadeFn =
			if(_defaultValue isEqualType 0) then {
				{
					params ["_pos", "_val"];
					_val * _factor
				}
			} else {
				{
					params ["_pos", "_val"];
					_val apply { _x * _factor}
				}
			};
		T_CALLM("apply", [_fadeFn]);
	ENDMETHOD;
	
	/*
	Method: filter
	Filters the grid through a kernel (2D array).
	
	Parameters: _kernel
	
	_kernel - square 2D array with numbers (coefficients). Size should be odd.
	
	Returns: Nothing
	*/
	METHOD(filter)
		params [P_THISOBJECT, P_ARRAY("_kernel")];

		pr _kSize = count _kernel;
		pr _kOffset = floor (_kSize / 2); // Kernel offset

		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");

		pr _nCellsX = ceil(WORLD_SIZE / _cellSize); //Size of the grid measured in squares
		pr _nCellsY = ceil(WORLD_SIZE / _cellSize);

		// Make a copy of the grid
		pr _arrayCopy = +_array;

		private _defaultValue = T_GETV("defaultValue");
		if(_defaultValue isEqualType 0) then {
			for "_xID" from _kOffset to (_nCellsX-_kOffset-1) do {
				for "_yID" from _kOffset to (_nCellsY-_kOffset-1) do {
					pr _acc = 0;
					
					// Do filtering
					pr _kxID = 0; // Indexes of kernel
					pr _kyID = 0;
					for "_fxID" from (_xID - _kOffset) to (_xID + _kOffset) do {
						_kyID = 0;
						for "_fyID" from (_yID - _kOffset) to (_yID + _kOffset) do {
							_acc = _acc + (_arrayCopy#_fxID#_fyID) * (_kernel#_kxID#_kyID);
							_kyID = _kyID + 1;
						};
						_kxID = _kxID + 1;
					};

					// Write the accumulated value
					(_array select _xID) set [_yID, _acc];
				};
			};
		} else {
			for "_xID" from _kOffset to (_nCellsX-_kOffset-1) do {
				for "_yID" from _kOffset to (_nCellsY-_kOffset-1) do {
					pr _acc = _defaultValue apply { 0 };
					
					// Do filtering
					pr _kxID = 0; // Indexes of kernel
					pr _kyID = 0;
					for "_fxID" from (_xID - _kOffset) to (_xID + _kOffset) do {
						_kyID = 0;
						for "_fyID" from (_yID - _kOffset) to (_yID + _kOffset) do {
							private _origVal = (_arrayCopy#_fxID#_fyID);
							private _coeff =  (_kernel#_kxID#_kyID);
							{
								_acc set [_forEachIndex, (_acc select _forEachIndex) + _x * _coeff];
							} forEach _origVal;
						};
						_kxID = _kxID + 1;
					};

					// Write the accumulated value
					(_array select _xID) set [_yID, _acc];
				};
			};
		};

		nil
	ENDMETHOD;

	METHOD(smooth5x5)
		params [P_THISOBJECT];
		private _kernel = [
			[1 / 273, 4 / 273, 7 / 273, 4 / 273, 1 / 273],
			[4 / 273, 16 / 273, 26 / 273, 16 / 273, 4 / 273],
			[7 / 273, 26 / 273, 41 / 273, 26 / 273, 7 / 273],
			[4 / 273, 16 / 273, 26 / 273, 16 / 273, 4 / 273],
			[1 / 273, 4 / 273, 7 / 273, 4 / 273, 1 / 273]
		];
		T_CALLM("filter", [_kernel]);
	ENDMETHOD;
	
	
	// - - - - - Plotting grids - - - - -
	/*
	Method: plot
	Plots the grid on the map.
	
	Parameters: _scale
	
	_scale - value which will result to alpha 1.0.
	_plotZero - bool, optional, default false. If true, zero values will be plotted as green squares.
	_brush - brush to use when drawing, default "SolidFull"
	_colors - array[3], optional, default ["ColorGreen", "ColorRed", "ColorBlue"]. Colors to use for zero, positive and negative respectively
	
	Returns: nil
	*/
	METHOD(plot)
		params [P_THISOBJECT, 
			["_scale", 1, [1]], 
			["_plotZero", false, [false]], 
			["_brush", "SolidFull", [""]],
			["_colors", ["ColorGreen", "ColorRed", "ColorBlue"], [[]], 3],
			["_alphaRange", [0.02, 0.5], [[]]]
		];

		T_CALLM0("unplot");

		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");
		pr _halfSize = _cellSize * 0.5;
		pr _n = count _array - 1;

		private _defaultValue = T_GETV("defaultValue");
		private _getValFn =
			if(_defaultValue isEqualType 0) then {
				{
					_this
				}
			} else {
				{
					private _val = 0;
					{
						_val = _val + _x;
					} foreach _this;
					_val
				}
			};

		for "_x" from 0 to _n do {
			pr _col = _array select _x;
			for "_y" from 0 to _n do {
				pr _val = (_col select _y) call _getValFn;

				if(_val != 0 or _plotZero) then {
					// Create marker
					pr _mrkName = format ["%1x%2y%3", _thisObject, _x, _y];
					pr _mrk = createMarkerLocal [_mrkName, [_cellSize*_x + _halfSize, _cellSize*_y + _halfSize, 0]];
					_mrk setMarkerShapeLocal "RECTANGLE";
					_mrk setMarkerBrushLocal _brush;
					_mrk setMarkerSizeLocal [_halfSize, _halfSize];
					
					// Set marker color and alpha
					if (_val == 0 && _plotZero) then {
						// Zero
						_mrk setMarkerColorLocal _colors#0;
						_mrk setMarkerAlphaLocal _alphaRange#0;
					} else {
						if (_val > 0) then {
							// Positive
							pr _alpha = ((_val/_scale) max _alphaRange#0) min _alphaRange#1;
							_mrk setMarkerColorLocal _colors#1;
							_mrk setMarkerAlphaLocal _alpha;
						} else {
							// Negative
							pr _alpha = ((-_val/_scale) max _alphaRange#0) min _alphaRange#1;
							_mrk setMarkerColorLocal _colors#2;
							_mrk setMarkerAlphaLocal _alpha;
						};
					};
				};
			};
		};
		
	ENDMETHOD;
	
	/*
	Method: unplot
	Removes markers of a previously plotted grid
	
	Returns: nil
	*/
	
	METHOD(unplot)
		params [P_THISOBJECT];
		
		pr _array = T_GETV("gridArray");
		pr _n = count _array - 1;
		
		for "_x" from 0 to _n do {
			pr _col = _array select _x;
			for "_y" from 0 to _n do {
				pr _mrkName = format ["%1x%2y%3", _thisObject, _x, _y];
				deleteMarkerLocal _mrkName;
			};
		};
	ENDMETHOD;
	
	/*
	Method: plotCell
	Plots a single cell of a grid
	
	Parameters: _pos
	
	_pos - [x, y] position, in meters
	
	Returns: nil
	*/
	
	METHOD(plotCell)
		params [P_THISOBJECT, P_ARRAY("_pos"), ["_scale", 1, [1]], ["_plotZero", false]];
		
		_pos params ["_x", "_y"];
		
		// Convert coordinates to cell IDs
		pr _cellSize = T_GETV("cellSize");
		pr _x = floor(_x / _cellSize);
		pr _y = floor(_y / _cellSize);
		
		pr _mrkName = format ["%1x%2y%3", _thisObject, _x, _y];
		
		// Delete old marker
		deleteMarkerLocal _mrkName;
		
		// Plot the marker again
		pr _array = T_GETV("gridArray");
		pr _halfSize = _cellSize * 0.5;
		
		private _defaultValue = T_GETV("defaultValue");

		pr _val =
			if(_defaultValue isEqualType 0) then {
				(_array select _x) select _y
			} else {
				private _v = 0;
				{
					_v = _v + _x;
				} foreach ((_array select _x) select _y);
				_v
			};
		
		// Create marker
		pr _mrk = createMarkerLocal [_mrkName, [_cellSize*_x + _halfSize, _cellSize*_y + _halfSize, 0]];
		_mrk setMarkerShapeLocal "RECTANGLE";
		_mrk setMarkerBrushLocal "SolidFull";
		_mrk setMarkerSizeLocal [_halfSize, _halfSize];
		
		// Set marker color and alpha
		if (_val == 0 && _plotZero) then {
			// Zero
			_mrk setMarkerColorLocal "ColorGreen";
			_mrk setMarkerAlphaLocal 0.1;
		} else {
			if (_val > 0) then {
				// Positive
				pr _alpha = ((_val/_scale) max 0.1) min 1.0;
				_mrk setMarkerColorLocal "ColorRed";
				_mrk setMarkerAlphaLocal _alpha;
			} else {
				// Negative
				pr _alpha = ((-_val/_scale) max 0.1) min 1.0;
				_mrk setMarkerColorLocal "ColorBlue";
				_mrk setMarkerAlphaLocal _alpha;
			};
		};
		
	ENDMETHOD;
	
	// // - - - - - Manipulating values - - - - - -	
	// METHOD(edit)
	// 	params [P_THISOBJECT, ["_value", 1.0], ["_scale", 1.0]];
		
	// 	// Unplot previous grid
	// 	pr _grid = GETSV("Grid", "currentGrid");
	// 	if (!isNil "_grid") then {
	// 		if (_grid != "") then {
	// 			CALLM0(_grid, "unplot");
	// 		};
	// 	};
		
	// 	SETSV("Grid", "currentGrid", _thisObject);
	// 	SETSV("Grid", "currentValue", _value);
	// 	SETSV("Grid", "currentScale", _scale);
		
	// 	// Plot the grid
	// 	T_CALLM2("plot", _scale, true);
		
	// 	// Remove previous EH if it exists
	// 	pr _eh = GETSV("Grid", "mapSingleClickEH");
	// 	if (!isNil "_eh") then {
	// 		removeMissionEventHandler ["MapSingleClick", _eh];
	// 	};
		
	// 	// Hint instructions
	// 	hint "Click: set value\nShift+click: set to 0\nClick outside of map: finish editing";
		
	// 	// Add new EH
	// 	_eh = addMissionEventHandler ["MapSingleClick", {
	// 		params ["_units", "_pos", "_alt", "_shift"];
			
	// 		_pos params ["_x", "_y"];
			
	// 		pr _grid = GETSV("grid", "currentGrid");
			
	// 		if (_x < 0 || _y < 0 || _x > WORLD_SIZE || _y > WORLD_SIZE) exitWith {
	// 			pr _eh = GETSV("Grid", "mapSingleClickEH");
	// 			removeMissionEventHandler ["MapSingleClick", _eh];
	// 			systemChat format ["Finished editing %1", _grid];
	// 			SETSV("Grid", "currentGrid", nil);

	// 			hint "Finished editing";
	// 		};
			
	// 		pr _value = GETSV("grid", "currentValue");
	// 		pr _scale = GETSV("grid", "currentScale");
			
	// 		if (_shift) then { _value = 0 };
			
	// 		CALLM2(_grid, "setValue", _pos, _value);
	// 		CALLM3(_grid, "plotCell", _pos, _scale, true);
	// 		//CALLM2(_grid, "plot", _scale, true);
	// 	}];
		
	// 	SETSV("Grid", "mapSingleClickEH", _eh);
	
	// ENDMETHOD;

	/*
	Method: copyFrom
	Sets values to this grid from another grid.
	
	Parameters: _grid
	
	_grid - the <Grid> to copy from
	
	Returns: reference to this grid.
	*/	
	METHOD(copyFrom)
		params [P_THISOBJECT, P_OOP_OBJECT("_grid")];

		pr _gridArray = T_GETV("gridArray");
		pr _gridArray1 = GETV(_grid, "gridArray");

		// Bail if sizes are different
		if (count _gridArray != count _gridArray1) exitWith {
			OOP_ERROR_2("Wrong grid sizes: %1, %2", _thisObject, _grid);
		};

		pr _nx = count _gridArray;
		pr _ny = count (_gridArray select 0);
		for "_xID" from 0 to (_nx-1) do {
			_gridArray set [_xID, +(_gridArray1 select _xID)];
		};

		_thisObject
	ENDMETHOD;

	// - - - - - STORAGE - - - - - -

	// This is perfectly storable, we just serialize everything
	/* override */ METHOD(serializeForStorage)
		params [P_THISOBJECT];
		SERIALIZE_ALL(_thisObject);
	ENDMETHOD;

	/* override */ METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial")];
		DESERIALIZE_ALL(_thisObject, _serial);
		true
	ENDMETHOD;

ENDCLASS;


#ifdef _SQF_VM

["Grid.new", {
	private _grid = NEW("Grid", [500, 33]);
	private _class = OBJECT_PARENT_CLASS_STR(_grid);
	["Object exists", !(isNil "_class")] call test_Assert;
	["cellSize correct", GETV(_grid, "cellSize") == 500] call test_Assert;
	["gridSize correct", GETV(_grid, "gridSize") == ceil(WORLD_SIZE / 500)] call test_Assert;
	["defaultValue correct", GETV(_grid, "defaultValue") == 33] call test_Assert;
}] call test_AddTest;

["Grid.setValueAll", {
	private _grid = NEW("Grid", [500, 33]);
	CALLM(_grid, "setValueAll", [1]);
	private _grid = CALLM0(_grid, "getGridArray");
	["Value correct", _grid#0#0 == 1] call test_Assert;
}] call test_AddTest;

["Grid.setValue", {
	private _grid = NEW("Grid", [500, 33]);
	CALLM(_grid, "setValue", [[0 ARG 0] ARG 1]);
	private _grid = CALLM0(_grid, "getGridArray");
	["Value correct", _grid#0#0 == 1] call test_Assert;
}] call test_AddTest;

["Grid.getMaxValueCircle", {
	private _grid = NEW("Grid", [500, 33]);
	//CALLM(_grid, "setValue", [[0 ARG 0] ARG 1]);
	//private _grid = CALLM0(_grid, "getGridArray");
	private _m = CALLM(_grid, "getMaxValueCircle", [[0 ARG 0 ARG 0] ARG 500]);
	["Value correct", _m == 33] call test_Assert;
}] call test_AddTest;

["Grid.getMaxValueCircle(array)", {
	private _grid = NEW("Grid", [500, [0,1,2,3]]);
	//CALLM(_grid, "setValue", [[0 ARG 0] ARG 1]);
	//private _grid = CALLM0(_grid, "getGridArray");
	private _m = CALLM(_grid, "getMaxValueCircle", [[0 ARG 0 ARG 0] ARG 500]);
	["Value correct", _m isEqualTo [0,1,2,3]] call test_Assert;
}] call test_AddTest;

["Grid.getMaxValueSquareNumber", {
	private _grid = NEW("Grid", [500, 0]);
	CALLM(_grid, "setValue", [[5000 ARG 3000] ARG 66]);
	//private _grid = CALLM0(_grid, "getGridArray");
	private _m = CALLM(_grid, "getMaxValueSquareNumber", [[6000 ARG 4000 ARG 0] ARG 2000]);
	["Value correct", _m == 66] call test_Assert;
	private _m = CALLM(_grid, "getMaxValueSquareNumber", [[9000 ARG 7000 ARG 0] ARG 2000]);
	["Value correct", _m == 0] call test_Assert;
}] call test_AddTest;

#endif
