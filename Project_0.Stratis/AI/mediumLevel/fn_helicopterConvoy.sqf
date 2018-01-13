/*

landing a helicopter:
https://community.bistudio.com/wiki/land
_heli land mode;
"LAND" (complete stop)
"GET IN" (hovering very low, for another unit to get in)
"GET OUT" (hovering low,for another unit to get out)
"NONE" (cancel a landing) Available since ArmA 2 57463 build.


*/

{
/*
Took it from =\SNKMAN/= at https://community.bistudio.com/wiki/land
*/
	params ["_helicopter", "_helipad"];
	_helicopter flyInHeight 10;
	(group driver _helicopter) move (getPos _helipad);
	
	sleep 3;
	while { ( (alive _helicopter) && (canMove _helicopter) && !(unitReady _helicopter) ) } do
	{
		   sleep 1;
	};

	if (alive _helicopter) then
	{
		   _helicopter land "LAND";
	};
};