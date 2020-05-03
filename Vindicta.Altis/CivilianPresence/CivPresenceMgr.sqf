#include "common.h"

/*
Grid which manages other civ presence objects.
*/

// Center of grid element
#define LOGICAL_TO_WORLD(posLogical, cellSize) ((posLogical+0.5)*cellSize)

#define pr private

#define OOP_CLASS_NAME CivPresenceMgr
CLASS("CivPresenceMgr", "")

	VARIABLE("cellSize");		// Cell size in meters
	VARIABLE("gridSize");		// Integer, amount of cells
	VARIABLE("gridArray");		// Array with arrays with values

	VARIABLE("initialized");

	// CivPresence objects which are active
	VARIABLE("activeObjects");

	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_cellSize")];

		private _gridSize = ceil(WORLD_SIZE / _cellSize); //Size of the grid measured in squares
		T_SETV("gridSize", _gridSize);
		T_SETV("cellSize", _cellSize);
		
		private _gridArray = [];
		_gridArray resize _gridSize;

		// Init grid, each element is 0
		// Later will be initialized in init method
		{
			pr _a = [];
			_a resize _gridSize;
			_gridArray set [_forEachIndex, _a apply  {0}];
		} forEach _gridArray;

		T_SETV("gridArray", _gridArray);

		T_SETV("initialized", false);
		T_SETV("activeObjects", []);
	ENDMETHOD;

	// Marks a specific area to be initialized during createCivPresenceObjects call
	METHOD(markAreaForInitialization)
		params [P_THISOBJECT, P_ARRAY("_area")];

		OOP_INFO_1("markAreaForInitialization: %1", _area);
		FIX_LINE_NUMBERS()

		_area params ["_pos", "_ra", "_rb", "_angle", "_rectangle"];
		pr _radius = if (_rectangle) then { sqrt (_ra*_ra + _rb*_rb) } else { _ra max _rb};

		pr _cellsize = T_GETV("cellSize");
		pr _gridSize = T_GETV("gridSize");

		_pos params ["_x", "_y"];

		private _xID = 0 max floor((_x - _radius) / _cellSize) min (_gridSize-1);
		private _yID = 0 max floor((_y - _radius) / _cellSize) min (_gridSize-1);
		private _x2ID = (0 max ceil((_x + _radius) / _cellSize) min (_gridSize-1));
		private _y2ID = (0 max ceil((_y + _radius) / _cellSize) min (_gridSize-1));

		pr _markedGrids = [];

		OOP_INFO_4("  checking grids x:%1-%2, y:%3-%4", _xID, _x2ID, _yID, _y2ID);

		//halt;

		pr _gridArray = T_GETV("gridArray");
		for "_xid" from _xID to (_x2ID-1) do {
			for "_yid" from _yID to (_y2ID-1) do {
				pr _posWorld = [LOGICAL_TO_WORLD(_xid, _cellsize), LOGICAL_TO_WORLD(_yid, _cellsize), 0];
				if (_posWorld inArea _area) then {
					(_gridArray#_xid) set [_yid, 1];
					_markedGrids pushBack [_xid, _yid];
				//} else {
				//	OOP_INFO_2("  %1 not in area %2", _posWorld, _area);
				};

				#ifdef DEBUG_CIV_PRESENCE
				pr _mrkName = format ["%1_debug_checkedArea_%2_%3", _thisObject, _xid, _yid];
				pr _mrk = createMarkerLocal [_mrkName, _posWorld];
				_mrk setMarkerShapeLocal "ICON";
				_mrk setMarkerBrushLocal "SolidFull";
				_mrk setMarkerTypeLocal "mil_box";
				_mrk setMarkerColorLocal "ColorBlue";
				_mrk setMarkerAlphaLocal 1;
				#endif
			};
		};

		OOP_INFO_1("  marked elements: %1", _markedGrids);

	ENDMETHOD;

	// Creates civ presence object at each grid element
	METHOD(createCivPresenceObjects)
		params [P_THISOBJECT];

		OOP_INFO_0("createCivPresenceObjects");

		// Bail if already initialized
		if (T_GETV("initialized")) exitWith {
			OOP_ERROR_0("Already initialized");
		};

		pr _cellSize = T_GETV("cellSize");
		{
			pr _lx = _foreachindex;		// Logical X
			pr _columnArray = _x;
			{
				pr _ly = _foreachindex;	// Logical Y
				if (_x == 1) then {
					pr _args = [
						[LOGICAL_TO_WORLD(_lx, _cellSize), LOGICAL_TO_WORLD(_ly, _cellSize), 0],	// Pos
						_cellSize/2,
						_cellSize/2
					];

					pr _cp = NEW("CivPresence", _args);
					_column set [_ly, _cp];

					OOP_INFO_2("  created object at: [%1, %2]", _lx, _ly);
				};
			} forEach _columnArray;
		} forEach T_GETV("gridArray");

		T_SETV("initialized", true);
	ENDMETHOD;



ENDCLASS;