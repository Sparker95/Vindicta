#include "defineCommon.inc"

params["_jn_type", _location];
pr _config = (missionConfigFile >> "Vehicles" >> _jn_type);
pr _type = (_config >> "type");
pr _fuel = (_config >> "fuel");
pr _repair = (_config >> "repair");

pr _vehicle = _type createVehicle _location;
_vehicle setVariable ["jn_type",_jn_type];

