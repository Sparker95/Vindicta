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
	VARIABLE("activeCells");

	VARIABLE("capacityMult"); // Global cpacity multiplier for all cells

	// Class name of unit to be used if a loadout is chosen
	VARIABLE("defaultCivType");

	// Array with class names or loadouts for unarmed civilians
	VARIABLE("unarmedCivTypes");

	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_cellSize"), P_STRING("_tCivilian")];

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
		T_SETV("activeCells", []);
		T_SETV("capacityMult", 1.0);

		// Prepare class names from template
		pr _t = [_tCivilian] call t_fnc_getTemplate;
		T_SETV("defaultCivType", (_t#T_INF#T_INF_default#0)); // Not a loadout!
		T_SETV("unarmedCivTypes", +(_t#T_INF#T_INF_unarmed));
	ENDMETHOD;

	METHOD(setCapacityMultiplier)
		params [P_THISOBJECT, P_NUMBER("_value")];

		T_SETV("capacityMult", _value);

	ENDMETHOD;

	// Marks a specific area to be initialized during createCivPresenceObjects call
	METHOD(markAreaForInitialization)
		params [P_THISOBJECT, P_ARRAY("_area"), P_OOP_OBJECT("_location")];

		OOP_INFO_2("markAreaForInitialization: %1, %2", _area, _location);
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
					(_gridArray#_xid) set [_yid, _location];
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
				_mrk setMarkerAlphaLocal 0.3;
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
				if (!(_x isEqualTo 0)) then { // _x has value of location at this position
					pr _args = [
						[LOGICAL_TO_WORLD(_lx, _cellSize), LOGICAL_TO_WORLD(_ly, _cellSize), 0],	// Pos
						_cellSize/2,
						_cellSize/2,
						_x
					];

					pr _cp = CALLSM("CivPresence", "tryCreateInstance", _args);
					if (!IS_NULL_OBJECT(_cp)) then {
						_columnArray set [_ly, _cp];	// Register it in grid
						CALLM2(_cp, "setUnitTypes", T_GETV("defaultCivType"), T_GETV("unarmedCivTypes"));
						OOP_INFO_2("  created object at: [%1, %2]", _lx, _ly);
					} else {
						_columnArray set [_ly, NULL_OBJECT];
						OOP_INFO_2("  failed to create object at: [%1, %2]", _lx, _ly);
					};					
				} else {
					_columnArray set [_ly, NULL_OBJECT];
				};
			} forEach _columnArray;
		} forEach T_GETV("gridArray");

		T_SETV("initialized", true);
	ENDMETHOD;

	// Starts periodic processing of this object
	METHOD(start)
		params [P_THISOBJECT];
		T_CALLM0("process");
	ENDMETHOD;

	// Maps players to cells they occupy
	// Returns array of [x, y] where x, y are logical positions of grid
	METHOD(calculateActiveCells)
		params [P_THISOBJECT];
		FIX_LINE_NUMBERS()

		pr _cellSize = T_GETV("cellSize");

		pr _objects = allPlayers;
		//pr _objects = allUnits select {side group _x == WEST};
		pr _ws2 = WORLD_SIZE/2;
		pr _area = [[_ws2, _ws2, 0], _ws2, _ws2, 0, true, -1]; // center, a, b, angle, rectangle, z
		_objects = _objects select {(_x inArea _area) && {(speed _x) < 60}}; // Ignore objects which are moving too fast

		// Calculate cells occupied by objects
		pr _occupiedCells = _objects apply {
			pr _pos = (getPosASL _x) vectorAdd ((velocity vehicle _x) vectorMultiply TIME_INTERPOLATE);
			[floor ((_pos#0)/_cellSize), floor ((_pos#1)/_cellSize)]
		};

		// Extend each cell with nearby cells
		pr _activeCells = +_occupiedCells;
		{
			_x params ["_px", "_py"];
			_activeCells pushBack [_px-1, _py];
			_activeCells pushBack [_px+1, _py];
			_activeCells pushBack [_px, _py-1];
			_activeCells pushBack [_px, _py+1];
			_activeCells pushBack [_px-1, _py-1];
			_activeCells pushBack [_px-1, _py+1];
			_activeCells pushBack [_px+1, _py-1];
			_activeCells pushBack [_px+1, _py+1];
		} forEach _occupiedCells;

		// Leave only unique elements
		_activeCells = _activeCells arrayIntersect _activeCells;

		// Remove cells which are outside of the map
		pr _gridSize = T_GETV("gridSize");
		_activeCells = _activeCells select {
			_x params ["_px", "_py"];
			(_px >= 0) && (_px < _gridSize) && (_py >= 0) && (_py < _gridSize)
		};

		_activeCells
	ENDMETHOD;

	
	METHOD(process)
		params [P_THISOBJECT];

		OOP_INFO_0("process");

		pr _currentActiveCells = T_GETV("activeCells");

		OOP_INFO_1("  current active cells: %1", _currentActiveCells);

		pr _newActiveCells = T_CALLM0("calculateActiveCells");
		pr _cellsDisable = _currentActiveCells - _newActiveCells;	// Cells to disable this time
		pr _cellsEnable = _newActiveCells - _currentActiveCells; 	// Cells to enable this time

		OOP_INFO_1("  cells will be disabled: %1", _cellsDisable);
		OOP_INFO_1("  cells will be enabled:  %1", _cellsEnable);

		pr _gridArray = T_GETV("gridArray");
		
		// Disalbe civ presence objects
		{
			_x params ["_lx", "_ly"];
			pr _cp = _gridArray#_lx#_ly;
			if (!IS_NULL_OBJECT(_cp)) then {
				CALLM1(_cp, "enable", false);
				CALLM0(_cp, "commitSettings");
			};
		} forEach _cellsDisable;

		// Change global multiplier if needed
		pr _commitAllActive = false;
		if ((count _newActiveCells) != (count _currentActiveCells)) then {
			
			// Calculate multiplier based on amount of active cells
			// https://www.desmos.com/calculator/tdfjjxrqli
			pr _mult = 9 / ( (count _newActiveCells) + 8 );
			CALLSM1("CivPresence", "setMultiplierSystem", _mult);

			_commitAllActive = true;
		};

		// Enable civ presence objects
		{
			_x params ["_lx", "_ly"];
			pr _cp = _gridArray#_lx#_ly;
			if (!IS_NULL_OBJECT(_cp)) then {
				CALLM1(_cp, "enable", true);
				CALLM0(_cp, "commitSettings");
			};
		} forEach _cellsEnable;

		if (_commitAllActive) then {
			// Recommit values on all active cells
			{
				_x params ["_lx", "_ly"];
				pr _cp = _gridArray#_lx#_ly;
				if (!IS_NULL_OBJECT(_cp)) then {
					CALLM0(_cp, "commitSettings");
				};
			} forEach (_newActiveCells - _cellsEnable);
			// Don't commit enabled cells - we have already committed them previously
		};

		T_SETV("activeCells", _newActiveCells);

		// CBA will execute this after some time
		[
			{
				params ["_thisObject"];
				T_CALLM0("process");
			},
			[_thisObject],
			1.0
		] call CBA_fnc_waitAndExecute;
	ENDMETHOD;

	STATIC_METHOD(forceUpdateSettings)
		params [P_THISCLASS];
		
	ENDMETHOD;

ENDCLASS;