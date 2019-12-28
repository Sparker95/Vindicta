/*
	@Author : https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
	@Created : --
	@Modified : --
	@Description : --
	@Return : SCALAR
*/

params ["_point", "_start", "_end"];

private _n = _end vectorDiff _start;
private _pa = _start vectorDiff _point;
private _c = _n vectorMultiply ((_pa vectorDotProduct _n) / (_n vectorDotProduct _n));
private _d = _pa vectorDiff _c;

sqrt (_d vectorDotProduct _d);