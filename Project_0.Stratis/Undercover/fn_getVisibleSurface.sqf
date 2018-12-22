#define pr private
#define MATH_PI 3.14159265359

//#define DEBUG_LINES

params ["_thetaStart", "_thetaEnd", "_alphaStart", "_alphaEnd", "_unit"];



private _veh = vehicle _unit;
private _array = [];
private _s = 0; // Surface accumulator
private _sMax = 0;

// Calculate the point to calculate exposure of	

//_pos0 = _unit modelToWorldVisual (_unit selectionPosition "head"); // AGL
//_pos = _veh worldToModelVisual _pos0;
private _posStartMdl = _unit selectionPosition "head";

//private _posStartMdl = _unit worldToModel (ASLTOAGL (eyepos _unit));
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
		private _pos0AGL = _unit modelToWorldVisual _posStartMdl;
		private _pos1AGL = _unit modelToWorldVisual (_posStartMdl vectorAdd _v);
		
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
		private _ds = _st*_d*_d; // Spherical coordinates surface element = _dAlpha*_dTheta*sin(_theta)
		_sMax = _sMax + _ds;
		if (!_intersectBool) then {
			_s = _s + _ds;
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