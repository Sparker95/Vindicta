params[["_bearing",0,[]]];
if(_bearing<0)then{_bearing = _bearing + 180};
private _bearings = ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"];
private _bearingID = (round (_bearing/45)) % 8;

_bearings select _bearingID;

