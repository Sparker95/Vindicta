
params ["_start", "_end", "_color", "_size", "_id"];

// calculate line
private _dist = sqrt(((_end select 0)-(_start select 0))^2+((_end select 1)-(_start select 1))^2) * 0.5;

//if(_dist <= 0.001) exitWith { objNull };

private _ang = ((_end select 0)-(_start select 0)) atan2 ((_end select 1)-(_start select 1));
private _center = [(_start select 0)+sin(_ang)*_dist,(_start select 1)+cos(_ang)*_dist];

// deleteMarker _id;

// create marker
createMarkerLocal [_id, _center];

// define marker
_id setMarkerDirLocal _ang;
_id setMarkerPosLocal _center;
_id setMarkerShapeLocal "RECTANGLE";
_id setMarkerBrushLocal "SOLID";
_id setMarkerColorLocal _color;
_id setMarkerSizeLocal [_size, _dist];

// return marker
_id