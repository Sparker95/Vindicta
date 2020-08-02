#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\common.h"

/*
Class: Snek
Snake video game

Author: Sparker
*/

#define pr private

#define DIR_UP		0
#define DIR_LEFT	1
#define DIR_RIGHT	2
#define DIR_DOWN	3

// Distance between segments
#define GRID_SIZE 1000
#define GRID_SIZE_HALF 500

// Width and height of segment when it is drawn
#define SEGMENT_SIZE 900
#define SEGMENT_SIZE_HALF 450

// Width and height of eyes
#define EYE_SIZE 300
#define EYE_SIZE_HALF 150

#define SNEK_DELAY 0.1

#define OOP_CLASS_NAME SnekSegment
CLASS("SnekSegment", "")

	VARIABLE("x");
	VARIABLE("y");
	
	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_x"), P_NUMBER("_y")];
		
		T_SETV("x", _x);
		T_SETV("y", _y);
		T_CALLM0("draw");
	ENDMETHOD;
	
	METHOD(delete)
		params [P_THISOBJECT];
		T_CALLM0("undraw");
	ENDMETHOD;
	
	// Initial drawing of segment
	public virtual METHOD(draw)
	ENDMETHOD;
	
	// Deletion of segment from display
	public virtual METHOD(undraw)
	ENDMETHOD;
	
	// Setting position of segment
	public virtual METHOD(setPos)
		params [P_THISOBJECT, P_NUMBER("_x"), P_NUMBER("_y")];
	ENDMETHOD;
	
ENDCLASS;

#define OOP_CLASS_NAME SnekTail
CLASS("SnekTail", "SnekSegment")
	
	public override METHOD(draw)
		params [P_THISOBJECT];
		pr _x = T_GETV("x");
		pr _y = T_GETV("y");
		
		pr _mrk = createMarkerLocal [_thisObject, [GRID_SIZE*_x + GRID_SIZE_HALF, GRID_SIZE*_y + GRID_SIZE_HALF, 0]];
		_mrk setMarkerShapeLocal "RECTANGLE";
		_mrk setMarkerBrushLocal "SolidFull";
		_mrk setMarkerSizeLocal [SEGMENT_SIZE_HALF, SEGMENT_SIZE_HALF];
		_mrk setMarkerColorLocal "ColorGUER";
		_mrk setMarkerAlphaLocal 1;
	ENDMETHOD;
	
	public override METHOD(undraw)
		params [P_THISOBJECT];
		deleteMarkerLocal _thisObject;
	ENDMETHOD;
	
	public override METHOD(setPos)
		params [P_THISOBJECT, P_NUMBER("_x"), P_NUMBER("_y")];
		T_SETV("x", _x);
		T_SETV("y", _y);
		
		_thisObject setMarkerPosLocal [GRID_SIZE*_x + GRID_SIZE_HALF, GRID_SIZE*_y + GRID_SIZE_HALF, 0];
	ENDMETHOD;
ENDCLASS;

#define OOP_CLASS_NAME SnekHead
CLASS("SnekHead", "SnekSegment")
	
	VARIABLE("direction");
	
	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_x"), P_NUMBER("_y"), P_NUMBER("_direction")];
		
		T_SETV("direction", _direction);
	ENDMETHOD;
	
	METHOD(setDirection)
		params [P_THISOBJECT, P_NUMBER("_direction")];
		T_SETV("direction", _direction);
	ENDMETHOD;
	
	public override METHOD(draw)
		params [P_THISOBJECT];
		pr _x = T_GETV("x");
		pr _y = T_GETV("y");
		
		pr _mrk = createMarkerLocal [_thisObject, [GRID_SIZE*_x + GRID_SIZE_HALF, GRID_SIZE*_y + GRID_SIZE_HALF, 0]];
		_mrk setMarkerShapeLocal "RECTANGLE";
		_mrk setMarkerBrushLocal "SolidFull";
		_mrk setMarkerSizeLocal [SEGMENT_SIZE_HALF, SEGMENT_SIZE_HALF];
		_mrk setMarkerColorLocal "ColorGreen";
		_mrk setMarkerAlphaLocal 1;
		
		pr _mrk = createMarkerLocal [_thisObject+"_left", [GRID_SIZE*_x + GRID_SIZE_HALF, GRID_SIZE*_y + GRID_SIZE_HALF, 0]];
		_mrk setMarkerShapeLocal "RECTANGLE";
		_mrk setMarkerBrushLocal "SolidFull";
		_mrk setMarkerSizeLocal [EYE_SIZE_HALF, EYE_SIZE_HALF];
		_mrk setMarkerColorLocal "ColorBlue";
		_mrk setMarkerAlphaLocal 1;
		
		pr _mrk = createMarkerLocal [_thisObject+"_right", [GRID_SIZE*_x + GRID_SIZE_HALF, GRID_SIZE*_y + GRID_SIZE_HALF, 0]];
		_mrk setMarkerShapeLocal "RECTANGLE";
		_mrk setMarkerBrushLocal "SolidFull";
		_mrk setMarkerSizeLocal [EYE_SIZE_HALF, EYE_SIZE_HALF];
		_mrk setMarkerColorLocal "ColorBlue";
		_mrk setMarkerAlphaLocal 1;
		
		T_CALLM0("updateEyesPos");
		
	ENDMETHOD;
	
	public override METHOD(undraw)
		params [P_THISOBJECT];
		deleteMarkerLocal _thisObject;
		deleteMarkerLocal (_thisObject + "_left");
		deleteMarkerLocal (_thisObject + "_right");
	ENDMETHOD;
	
	public override METHOD(setPos)
		params [P_THISOBJECT, P_NUMBER("_x"), P_NUMBER("_y")];
		T_SETV("x", _x);
		T_SETV("y", _y);
		
		_thisObject setMarkerPosLocal [GRID_SIZE*_x + GRID_SIZE_HALF, GRID_SIZE*_y + GRID_SIZE_HALF, 0];
		
		T_CALLM0("updateEyesPos");
	ENDMETHOD;
	
	METHOD(updateEyesPos)
		params [P_THISOBJECT];
		
		pr _x = T_GETV("x");
		pr _y = T_GETV("y");
		pr _dir = T_GETV("direction");
		
		pr _mrkLeft = _thisObject + "_left";
		pr _mrkRight = _thisObject + "_right";
		
		switch (_dir) do {
			case DIR_UP: {
				_mrkLeft setMarkerPosLocal [_x*GRID_SIZE - SEGMENT_SIZE_HALF + GRID_SIZE_HALF, _y*GRID_SIZE + GRID_SIZE_HALF, 0];
				_mrkRight setMarkerPosLocal [_x*GRID_SIZE + SEGMENT_SIZE_HALF + GRID_SIZE_HALF, _y*GRID_SIZE + GRID_SIZE_HALF, 0];
			};
			case DIR_DOWN: {
				_mrkLeft setMarkerPosLocal [_x*GRID_SIZE + SEGMENT_SIZE_HALF + GRID_SIZE_HALF, _y*GRID_SIZE + GRID_SIZE_HALF, 0];
				_mrkRight setMarkerPosLocal [_x*GRID_SIZE - SEGMENT_SIZE_HALF + GRID_SIZE_HALF, _y*GRID_SIZE + GRID_SIZE_HALF, 0];
			};
			case DIR_RIGHT: {
				_mrkLeft setMarkerPosLocal [_x*GRID_SIZE + GRID_SIZE_HALF, _y*GRID_SIZE + SEGMENT_SIZE_HALF + GRID_SIZE_HALF, 0];
				_mrkRight setMarkerPosLocal [_x*GRID_SIZE + GRID_SIZE_HALF, _y*GRID_SIZE - SEGMENT_SIZE_HALF + GRID_SIZE_HALF, 0];
			};
			case DIR_LEFT: {
				_mrkLeft setMarkerPosLocal [_x*GRID_SIZE + GRID_SIZE_HALF, _y*GRID_SIZE - SEGMENT_SIZE_HALF + GRID_SIZE_HALF, 0];
				_mrkRight setMarkerPosLocal [_x*GRID_SIZE + GRID_SIZE_HALF, _y*GRID_SIZE + SEGMENT_SIZE_HALF + GRID_SIZE_HALF, 0];
			};
		};
		
	ENDMETHOD;
	
ENDCLASS;



#define OOP_CLASS_NAME SnekPickup
CLASS("SnekPickup", "")

	VARIABLE("x");
	VARIABLE("y");
	
	METHOD(new)
		params [P_THISOBJECT, "_x", "_y"];
		
		T_SETV("x", _x);
		T_SETV("y", _y);
		
		pr _mrk = createMarkerLocal [_thisObject, [GRID_SIZE*_x + GRID_SIZE_HALF, GRID_SIZE*_y + GRID_SIZE_HALF, 0]];
		_mrk setMarkerShapeLocal "RECTANGLE";
		_mrk setMarkerBrushLocal "SolidFull";
		_mrk setMarkerSizeLocal [SEGMENT_SIZE_HALF*0.6, SEGMENT_SIZE_HALF*0.6];
		_mrk setMarkerColorLocal "ColorRed";
		_mrk setMarkerAlphaLocal 1;
		
	ENDMETHOD;
	
	METHOD(delete)
		params [P_THISOBJECT];
		
		deleteMarkerLocal _thisObject;
	ENDMETHOD;

ENDCLASS;


#define OOP_CLASS_NAME Snek
CLASS("Snek", "")

	// Global snek object
	STATIC_VARIABLE("snek");

	VARIABLE("segments");
	VARIABLE("direction");
	VARIABLE("flagTerminate");
	
	// Event handler numbers
	VARIABLE("EH_keyDown");
	VARIABLE("EH_keyUp");
	
	// Frame counter
	VARIABLE("frameCounter");
	
	// State of shift key
	VARIABLE("shift");
	
	// Array with pickups
	VARIABLE("pickups");
	
	// Call start to start the game
	public STATIC_METHOD(start)
		params [P_THISOBJECT];
		
		OOP_INFO_0("start");
	
		pr _snek = GETSV("Snek", "snek");
		if (_snek != "") exitWith {OOP_ERROR_0("Must stop Snek before starting it again!");};
		
		// Create new Snek instance
		_snek = NEW("Snek", []);
		SETSV("Snek", "snek", _snek);

		// Hint
		hint "Snek game has been started!";

	ENDMETHOD;

	// Call stop to stop the game	
	public STATIC_METHOD(stop)
	
		OOP_INFO_0("stop");
	
		pr _snek = GETSV("Snek", "snek");
		if (_snek != "") then {
			SETV(_snek, "flagTerminate", true);
		};

		hint "Snek game has been stopped!";
	
	ENDMETHOD;

	// Returns true if the game is running
	public STATIC_METHOD(isRunning)

		GETSV("Snek", "snek") != ""

	ENDMETHOD;


	METHOD(new)
		params [P_THISOBJECT];
		
		OOP_INFO_0("NEW");
		
		T_SETV("flagTerminate", false);
		T_SETV("frameCounter", 0);
		T_SETV("shift", false);
		
		// Create head segment
		pr _args = [10, 10, DIR_RIGHT];
		pr _head = NEW("SnekHead", _args);
		
		// Initialize segments
		pr _segments = [_head];
		
		// Create tail segments
		for "_y" from 9 to 4 step -1 do {
			pr _args = [10, 10];
			pr _segment = NEW("SnekTail", _args);
			_segments pushBack _segment;
		};
		T_SETV("segments", _segments);
		
		// Initial direction
		T_SETV("direction", DIR_RIGHT);
		
		// Create pickups
		pr _pickups = [];
		T_SETV("pickups", _pickups);
		for "_i" from 0 to 3 do {
			T_CALLM0("createRandomPickup");
		};
		
		// Add event handlers
		pr _eh = (finddisplay 12) displayAddEventHandler ["KeyDown", {CALLM1(GETSV("Snek", "snek"), "onKeyDown", _this)}];
		T_SETV("EH_keyDown", _eh);
		pr _eh = (finddisplay 12) displayAddEventHandler ["KeyUp", {CALLM1(GETSV("Snek", "snek"), "onKeyUp", _this)}];
		T_SETV("EH_keyUp", _eh);
		
		// Add CBA wait and execute
		[{CALLM0(_this, "onTimer");}, _thisObject, SNEK_DELAY] call CBA_fnc_waitAndExecute;

	ENDMETHOD;
	
	METHOD(delete)
		params [P_THISOBJECT];
		
		OOP_INFO_0("DELETE");
		
		// Delete event handlers
		(finddisplay 12) displayRemoveEventHandler ["KeyDown", T_GETV("EH_keyDown")];
		(finddisplay 12) displayRemoveEventHandler ["KeyUp", T_GETV("EH_keyUp")];
		
		// Delete all segments
		pr _segments = T_GETV("segments");
		{
			DELETE(_x);
		} forEach _segments;
		
		// Delete all pickups
		{
			DELETE(_x);
		} forEach T_GETV("pickups");

		// Show score to player
		systemChat format ["Your score: %1", (count _segments) - 1];

		// Reset the global variable
		SETSV("Snek", "snek", "");
	ENDMETHOD;
	
	/*
	METHOD(addSegment)
		params [P_THISOBJECT];
		
		pr _segments = T_GETV("segments");
		pr _args = 
		_segments pushBack NEW("SnekSegment");
	ENDMETHOD;
	*/
	
	METHOD(setDirection)
		params [P_THISOBJECT, P_NUMBER("_direction")];
		
		T_SETV("direction", _direction);
		
		// Rotate the head too
		pr _head = T_GETV("segments") select 0;
		CALLM1(_head, "setDirection", _direction);
	ENDMETHOD;
	
	METHOD(createRandomPickup)
		params [P_THISOBJECT];
		
		pr _pickups = T_GETV("pickups");
		pr _args = [floor((random worldSize) / GRID_SIZE), floor((random worldSize) / GRID_SIZE)];
		pr _pickup = NEW("SnekPickup", _args);
		_pickups pushBack _pickup;
	ENDMETHOD;
	
	public event METHOD(onKeyDown)
		params [P_THISOBJECT, "_params"];
		
		OOP_INFO_1("On key down: %1", _this);
		
		_params params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
		
		pr _dir = T_GETV("direction");
		switch (_key) do {
			case  0x11: { // W
				if (_dir != DIR_DOWN) then {T_CALLM1("setDirection", DIR_UP); };
				true
			};
			
			case 0x1E: { // A
				if (_dir != DIR_RIGHT) then {T_CALLM1("setDirection", DIR_LEFT); };
				true
			};
			
			case 0x1F: { // S
				if (_dir != DIR_UP) then {T_CALLM1("setDirection", DIR_DOWN); };
				true
			};
			
			case 0x20: { // D
				if (_dir != DIR_LEFT) then {T_CALLM1("setDirection", DIR_RIGHT); };
				true
			};
			
			case 0x2A: { // Left shift
				T_SETV("shift", true);
				true
			};
			
			default {false};
		};
		
	ENDMETHOD;
	
	public event METHOD(onKeyUp)
		params [P_THISOBJECT, "_params"];
		
		_params params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
		
		if (_key == 0x2A) then { // Shift
			T_SETV("shift", false);
		};
		
		
	ENDMETHOD;
	
	public event METHOD(onTimer)
		params [P_THISOBJECT];
		
		OOP_INFO_0("ON TIMER");
		
		// Terminate the game if it was asked to be terminated
		if (T_GETV("flagTerminate")) exitWith {
			DELETE(_thisObject);
		};
		
		pr _frameCounter = T_GETV("frameCounter");
		if (_frameCounter >= 1 || (_frameCounter >= 0 && T_GETV("shift"))) then {
			T_SETV("frameCounter", 0);
		
			// Move head
			pr _dir = T_GETV("direction");
			pr _segments = T_GETV("segments");
			pr _head = _segments select 0;
			pr _x = GETV(_head, "x");
			pr _y = GETV(_head, "y");
			pr _xNew = _x;
			pr _yNew = _y;
			switch (_dir) do {
				case DIR_UP: {_yNew = _y + 1;};
				case DIR_DOWN: {_yNew = _y - 1;};
				case DIR_RIGHT: {_xNew = _x + 1;};
				case DIR_LEFT: {_xNew = _x - 1;};
			};

			// Check if new position is outside of the world boundary
			pr _posMax = floor (worldSize / SEGMENT_SIZE);
			if (_yNew < 0 || _xNew < 0 || _xNew > _posMax || _yNew > _posMax) then {
				CALLSM0("Snek", "stop");
				systemChat "You crashed into a wall!";
			};

			// Check if Snek bites its tail
			{
				pr _sx = GETV(_x, "x");
				pr _sy = GETV(_x, "y");
				if (_xNew == _sx && _yNew == _sy) exitWith {
					// Delete all segments above this segment
					pr _i = _forEachIndex;
					while {_i < (count _segments)} do {
						pr _segment = _segments deleteAt _i;
						DELETE(_segment);
					};
				};
			} forEach _segments;

			// Check if new position is on one of pickups
			pr _pickups = T_GETV("pickups");
			pr _i = 0;
			while {_i < count _pickups} do {
				pr _p = _pickups select _i;
				pr _px = GETV(_p, "x");
				pr _py = GETV(_p, "y");
				if (_px == _xNew && _py == _yNew) then {
					_pickups deleteAt _i;
					DELETE(_p);
					
					// Add one more segment to snek
					pr _lastSegment = _segments select ((count _segments) - 1);
					pr _args = [GETV(_lastSegment, "x"), GETV(_lastSegment, "y")];
					pr _segment = NEW("SnekTail", _args);
					_segments pushBack _segment;
					
					// Create a new pickup
					T_CALLM0("createRandomPickup");

					// Show score to player
					systemChat format ["Your score: %1", (count _segments) - 1];
				} else {
					_i = _i + 1;
				};
			};
			
			CALLM2(_head, "setPos", _xNew, _yNew);
			
			// Move tail segments
			pr _n = count _segments;
			pr _i = 1;
			while {_i < _n} do {
				pr _segment = _segments select _i;
				pr _xNew = _x;
				pr _yNew = _y;
				_x = GETV(_segment, "x");
				_y = GETV(_segment, "y");
				CALLM2(_segment, "setPos", _xNew, _yNew);
				
				_i = _i + 1;
			};
			
		} else {
			T_SETV("frameCounter", _frameCounter + 1);
		};
		
		// Add CBA wait and execute
		[{CALLM0(_this, "onTimer");}, _thisObject, SNEK_DELAY] call CBA_fnc_waitAndExecute;
		
	ENDMETHOD;

ENDCLASS;

SETSV("Snek", "snek", "");


// Map marker that starts the game
/*
#define OOP_CLASS_NAME MapMarkerSnek
CLASS("MapMarkerSnek", "MapMarker")

	METHOD(new)
		params [P_THISOBJECT];

		// Put the marker at the bottom left of the map
		pr _pos = [0, 0];
		T_CALLM1("setPos", _pos);
	ENDMETHOD;

	public event METHOD(onMouseButtonClick)
		params [P_THISOBJECT, "_shift", "_ctrl", "_alt"];
		
		if (CALLSM0("Snek", "isRunning")) then {
			CALLSM0("Snek", "stop");
		} else {
			CALLSM0("Snek", "start");
		};
	ENDMETHOD;


	public override event METHOD(onDraw)

	ENDMETHOD;

ENDCLASS;
*/
//NEW("MapMarkerSnek", []);