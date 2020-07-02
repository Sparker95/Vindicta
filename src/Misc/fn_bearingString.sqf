// Returns text from given bearing
// For instance, "north" for 10, etc.
params ["_bearing"];
private _bearings = ["North", "North-East", "East", "South-East", "South", "South-West", "West", "North-west"];
private _bearingID = (round (_bearing/45)) % 8;
private _bearingString = _bearings select _bearingID;
_bearingString;