onEachFrame {
	private _co = cursorObject;
	if (isNull _co) exitWith {};
	
	private _bb = boundingBoxReal _co;
	_bb params ["_p0", "_p1"];
	_p0 params ["_x0","_y0","_z0"];
	_p1 params ["_x1","_y1","_z1"];
	(boundingCenter _co) params ["_xc", "_yc", "_zc"];
	
	private _color = [0, 1, 0, 1];
	
	// --- Lines at the box edges ---
	// Vertical lines!
	drawLine3D [_co modelToWorldVisual [_x0, _y0, _z0], _co modelToWorldVisual [_x0, _y0, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x0, _y1, _z0], _co modelToWorldVisual [_x0, _y1, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x1, _y1, _z0], _co modelToWorldVisual [_x1, _y1, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x1, _y0, _z0], _co modelToWorldVisual [_x1, _y0, _z1], _color];
	
	// More lines!
	drawLine3D [_co modelToWorldVisual [_x0, _y0, _z1], _co modelToWorldVisual [_x0, _y1, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x0, _y1, _z1], _co modelToWorldVisual [_x1, _y1, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x1, _y1, _z1], _co modelToWorldVisual [_x1, _y0, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x1, _y0, _z1], _co modelToWorldVisual [_x0, _y0, _z1], _color];

	// We need more lines!!
	drawLine3D [_co modelToWorldVisual [_x0, _y0, _z0], _co modelToWorldVisual [_x0, _y1, _z0], _color];
	drawLine3D [_co modelToWorldVisual [_x0, _y1, _z0], _co modelToWorldVisual [_x1, _y1, _z0], _color];
	drawLine3D [_co modelToWorldVisual [_x1, _y1, _z0], _co modelToWorldVisual [_x1, _y0, _z0], _color];
	drawLine3D [_co modelToWorldVisual [_x1, _y0, _z0], _co modelToWorldVisual [_x0, _y0, _z0], _color];
	
	// ---- Lines at box faces ----
	_color = [1, 0, 0, 1];
	drawLine3D [_co modelToWorldVisual [_x0, _y0, _z0], _co modelToWorldVisual [_x1, _y0, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x0, _y0, _z1], _co modelToWorldVisual [_x1, _y0, _z0], _color];
	
	drawLine3D [_co modelToWorldVisual [_x0, _y1, _z0], _co modelToWorldVisual [_x1, _y1, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x0, _y1, _z1], _co modelToWorldVisual [_x1, _y1, _z0], _color];
	
	drawLine3D [_co modelToWorldVisual [_x0, _y0, _z1], _co modelToWorldVisual [_x0, _y1, _z0], _color];
	drawLine3D [_co modelToWorldVisual [_x0, _y0, _z0], _co modelToWorldVisual [_x0, _y1, _z1], _color];
	
	drawLine3D [_co modelToWorldVisual [_x1, _y0, _z1], _co modelToWorldVisual [_x1, _y1, _z0], _color];
	drawLine3D [_co modelToWorldVisual [_x1, _y0, _z0], _co modelToWorldVisual [_x1, _y1, _z1], _color];
	
	// ---- Crosses at faces ----
	_color = [1, 0, 0, 1];
	drawLine3D [_co modelToWorldVisual [0, _y0, _z0], _co modelToWorldVisual [0, _y0, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x0, _y0, 0], _co modelToWorldVisual [_x1, _y0, 0], _color];
	
	drawLine3D [_co modelToWorldVisual [0, _y1, _z0], _co modelToWorldVisual [0, _y1, _z1], _color];
	drawLine3D [_co modelToWorldVisual [_x0, _y1, 0], _co modelToWorldVisual [_x1, _y1, 0], _color];
	
	drawLine3D [_co modelToWorldVisual [_x0, _y0, 0], _co modelToWorldVisual [_x0, _y1, 0], _color];
	drawLine3D [_co modelToWorldVisual [_x0, 0, _z0], _co modelToWorldVisual [_x0, 0, _z1], _color];
	
	drawLine3D [_co modelToWorldVisual [_x1, _y0, 0], _co modelToWorldVisual [_x1, _y1, 0], _color];
	drawLine3D [_co modelToWorldVisual [_x1, 0, _z0], _co modelToWorldVisual [_x1, 0, _z1], _color];
};