#include "..\common.h"

params ["_addMore"];

#define pr private

if (isNil "gPrevIntels") then {
	gPrevIntels = [];
};

private _AI = gAICommanderWest;
private _db = GETV(_AI, "intelDB");
{
	CALLM1(_db, "removeIntel", _x);
} forEach gPrevIntels;

if (!_addMore) exitWith {};

gPrevIntels = [];

for "_i" from 0 to 15 do {
	pr _intel = NEW("IntelCommanderActionPatrol", []);
	pr _waypoints = [];
	pr _locations = [];
	for "_wpid" from 0 to 4 do {
		_waypoints pushBack ([random 10000, random 10000, 0]);
		_locations pushBack (str _wpid);
	};
	SETV(_intel, "waypoints", _waypoints);
	SETV(_intel, "locations", _locations);
	SETV(_intel, "side", WEST);
	SETV(_intel, "dateDeparture", DATE_NOW);
	SETV(_intel, "garrison", "garrison123");
	SETV(_intel, "pos", [random 1000 ARG random 1000 ARG 0]);
	SETV(_intel, "posCurrent", [random 1000 ARG random 1000 ARG 0]);
	SETV(_intel, "strength", [0 ARG 0 ARG 0 ARG 0 ARG 0 ARG 0 ARG 0 ARG 0]);
	CALLM1(_db, "addIntel", _intel);

	gPrevIntels pushBack _intel;
};