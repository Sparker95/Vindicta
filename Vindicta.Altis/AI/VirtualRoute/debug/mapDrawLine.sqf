/*
  Author:
   rÃ¼be

  Description:
   draws a line on the map (with rect. area-markers)

  Parameter(s):
   _this: parameters (array of array [key (string), value (any)])

          - required:
            - "start" (position)
            - "end" (position)

          - optional:
            - "id" (unique marker string, default = RUBE_createMarkerID)
            - "color" (string, default = ColorBlack)
            - "size" (number, default = 5)

  Example:
   _marker = [
      ["start", _pos],
      ["end", _pos2],
      ["color", "ColorRed"],
      ["size", 24]
   ] call RUBE_mapDrawLine;

  Returns:
   marker
*/

private ["_mrk", "_start", "_end", "_color", "_size", "_id", "_dist", "_ang", "_center"];

_mrk = "";

_start = [0,0,0];
_end = [0,0,0];

_color = "ColorBlack";
_size = 5;
_id = "";

// read parameters
{
  switch (_x select 0) do
  {
     case "start": { _start = _x select 1; };
     case "end":   { _end   = _x select 1; };
     case "color": { _color = _x select 1; };
     case "size":  { _size  = _x select 1; };
     case "id":    
     { 
        if ((typeName (_x select 1)) == "STRING") then
        {
           _id = _x select 1;
        };
     };
  };
} forEach _this;

// calculate line
_dist = sqrt(((_end select 0)-(_start select 0))^2+((_end select 1)-(_start select 1))^2) * 0.5;

//if(_dist <= 0.001) exitWith { objNull };

_ang = ((_end select 0)-(_start select 0)) atan2 ((_end select 1)-(_start select 1));
_center = [(_start select 0)+sin(_ang)*_dist,(_start select 1)+cos(_ang)*_dist];

// create marker
if (_id == "") then
{
  _id = str _center;
};
_mrk = createMarker [_id, _center];

// define marker
_mrk setMarkerDir _ang;
_mrk setMarkerPos _center;
_mrk setMarkerShape "RECTANGLE";
_mrk setMarkerBrush "SOLID";
_mrk setMarkerColor _color;
_mrk setMarkerSize [_size, _dist];

// return marker
_mrk