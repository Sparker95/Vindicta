build_ui_move_object = [];
build_ui_moving_object = false;

ui_fnc_moveObject = {
	//params ["_object"];

	// Maybe not necessary, just use attach status?	
	// if(_object getVariable ["ui_fnc_moveObject", false]) exitWith { false };
	// _object setVariable ["ui_fnc_moveObject", true];
	build_ui_moving_object = true;
	build_ui_move_object params ["_object", "_pos"];
	_object setPosWorld _pos;
	_object enableSimulation true;
	build_ui_move_object = [];

	private _world_pos = _object modelToWorld [0,0,0.1];
	private _relative_pos = player worldToModel _world_pos;
	private _starting_h = getCameraViewDirection player select 2;
	
	private _dir = getDir _object - getDir player; //vectorDir _object;
	private _up = vectorUp _object;
	_object enableSimulationGlobal false;
	
	_object setVariable ["build_ui_beingMoved", true];
	_object attachTo [player, _relative_pos];
	_object setDir _dir;
	//_object setVectorDirAndUp [_dir, _up];

	["SetHQObjectHeight", "onEachFrame", {
		params ["_object", "_mover", "_relative_pos", "_starting_h", "_dir", "_up"];
		private _relative_h = (getCameraViewDirection _mover select 2) - _starting_h;
		//_object setPos (_relative_pos vectorAdd [0, 0, _relative_h * vectorMagnitude _relative_pos]);
		// detach _object;
		_object attachTo [_mover, _relative_pos vectorAdd [0, 0, _relative_h * vectorMagnitude _relative_pos]];
		// _object setDir _dir;
	}, [_object, player, _relative_pos, _starting_h, _dir, _up]] call BIS_fnc_addStackedEventHandler;

	player addAction ["Drop Here", {
		params ["_target", "_caller", "_actionId", "_arguments"];
		["SetHQObjectHeight", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
		detach _arguments;
		private _pos = getPos _arguments;
		_arguments setPos [_pos select 0, _pos select 1, 0];
		_arguments enableSimulationGlobal true;
		player removeAction (_this select 2);

		build_ui_moving_object = false;
	}, _object, 0, false, true, "", ""];

	true
};

ui_fnc_enterBuildMode = {
	// cutRsc ["buildUI", "PLAIN", 2];
	
	// // FOR DEBUGGING:
	// {
	// 	_x setVariable ["P0_allowMove", true];
	// } forEach (player nearObjects 50);

	player addAction [localize "STR_BF_GRAB", {
		params ["_object"];
		
		[] call ui_fnc_moveObject;
	}, [], 0, false, false, "", "count build_ui_move_object != 0"];

	["HighlightMoveObjects", "onEachFrame", {
		if(build_ui_moving_object) exitWith {};

		if(count build_ui_move_object == 0 or {cursorObject != (build_ui_move_object select 0)}) then {
			if(count build_ui_move_object > 0) then {
				build_ui_move_object params ["_obj", "_pos"];
				_obj setPosWorld _pos;
				_obj enableSimulation true;
				build_ui_move_object = [];
			};
			
			if(cursorObject getVariable ["P0_allowMove", false]) then {
				private _pos = getPosWorld cursorObject;
				build_ui_move_object = [cursorObject, _pos];
				cursorObject enableSimulation false;
				cursorObject setPosWorld [_pos select 0, _pos select 1, (_pos select 2) + 0.02 + 0.02 * cos(time * 720)];
				_light setLightBrightness 1.0;
				_light setPosWorld [_pos select 0, _pos select 1, (_pos select 2) + 1];
				//_light lightAttachObject [cursorObject, [0,0,2]];
			};
		} else {
			if(count build_ui_move_object != 0) then {
				build_ui_move_object params ["_obj", "_pos"];
				_obj setPosWorld [_pos select 0, _pos select 1, (_pos select 2) + 0.02 + 0.02 * cos(time * 720)];
			};
		};
	}, []] call BIS_fnc_addStackedEventHandler;
};

ui_fnc_enterBuildMode = {

};