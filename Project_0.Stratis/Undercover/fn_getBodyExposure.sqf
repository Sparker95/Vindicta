#define pr private
#define MATH_PI 3.14159265359
//#define DEBUG_LINES

fnc_getVisibleSurface = {
	params ["_thetaStart", "_thetaEnd", "_alphaStart", "_alphaEnd", "_unit"];
	
	private _veh = vehicle _unit;
	private _array = [];
	private _s = 0; // Surface accumulator
	private _sMax = 0;
	
	// Calculate the point to calculate exposure of	
	private _posStartMdl = _unit worldToModel (ASLTOAGL (eyepos _unit));
	_posStartMdl = _posStartMdl vectorAdd [0, 0, -0.25]; // Little offset so that the point is at the chest level
	
	// Step of the scan grid in degrees. Tweak it to trade accuracy for performance. 
	private _d = 30;
	
	for "_theta" from _thetaStart to _thetaEnd step _d do {
		private _st = sin _theta;
		for "_alpha" from _alphaStart to _alphaEnd step _d do {
			// Vector in model space
			private _r = 4;
			private _v = [_r*(cos _alpha)*(sin _theta), _r*(sin _alpha)*(sin _theta), _r*(cos _theta)];
			
			// Pos 0 and pos 1
			private _pos0AGL = _unit modelToWorld _posStartMdl;
			private _pos1AGL = _unit modelToWorld (_posStartMdl vectorAdd _v);
			
			//private _intersect = [vehicle _unit, "FIRE"] intersect [_pos1AGL, _pos0AGL];
			//_intersectBool = ((count _intersect) > 0);
			
			private _intersect = lineIntersectsWith [AGLTOASL _pos0AGL, AGLTOASL _pos1AGL, _unit, objNull, false];
			_intersectBool = (_veh in _intersect);
			
			/*if (_intersectBool) then {
				if ((_intersect findIf {((_x select 0) find "glass") == 0}) != -1) then {
					_intersectBool = false;
					diag_log "Found glass!";
				};
			};*/
			
			#ifdef DEBUG_LINES
			
				private _color = if (!_intersectBool) then {[0, 1, 0, 1]} else {[1, 0, 0, 1]};
				
				//if (!_intersectBool) then {drawLine3D [_pos0AGL, _pos1AGL, _color];};
				drawLine3D [_pos0AGL, _pos1AGL, _color];
			
			#endif
			
			// Increase the surface accumulator
			//private _ds = _st*_d*_d; // Spherical coordinates surface element = _dAlpha*_dTheta*sin(_theta)
			_sMax = _sMax + 1;
			if (!_intersectBool) then {
				_s = _s + 1;
			};
		};
	};
	
	// Convert the result from degrees to radians
	//_s = _s*MATH_PI/180*MATH_PI/180;
	//_s = _s*MATH_PI/180/180;
	
	// Normalize the result
	//_s = _s/4/((_thetaEnd-_thetaStart)/180);
	
	// Return
	_s/_sMax
};

/*
g_surfaceUpdateTime = diag_tickTime;

timeStart = time;

// Calibrate the maximum value
private _s = 0;


onEachFrame {
	
	//[0, 360, -5, 5] call fnc_countIntersections;
	//[0, 360, 85, 95] call fnc_countIntersections;
	private _exposure = [20, 120, 0, 360] call fnc_getVisibleSurface; // Higher polusphere
	
	if (diag_tickTime - g_surfaceUpdateTime > 0.2) then {
		systemChat format ["Your exposure is: %1", _exposure];
		g_surfaceUpdateTime = diag_tickTime;
	};
	
	
	//{diag_log str _x} forEach _array;
	
	//onEachFrame {};
	
	if (time > (timeStart + 600)) then {onEachFrame {};};
};

/*
_s = 0;
_pi = 3.14;
_dTheta = 10;
_dAlpha = 10;
for "_theta" from 0 to 180 step _dTheta do {  
  for "_alpha" from 0 to 360 step _dAlpha do { 
   _ds = (sin _theta)*_dTheta*_dAlpha;
  _s = _s + _ds;
};
};
_s = _s /180/180*_pi*_pi;
_s/4/_pi
*/