#include "MapUI.h"

class FakeControlBase
{
	type = 15;  // group
	style = 0;
	x = 0;
	y = 0;
	w = 0; //safeZoneW;
	h = 0; //safeZoneH;
	colorBackground[] = {1,0,0,0.5};
	colorText[] = {0, 0, 0, 0};
	font = "PuristaMedium";
	sizeEx = 0.4;
	text = "";

	class VScrollbar
	{
		color[] =
		{
			1,
			1,
			1,
			1
		};
		width = 0.021;
		autoScrollEnabled = 1;
	};
	class HScrollbar
	{
		color[] =
		{
			1,
			1,
			1,
			1
		};
		height = 0.028;
	};
};

class MapUIFinal : MapUI
{
	type = 15;  // group
	style = 0;
	x = 0;
	y = 0;
	w = safezonew;
	h = safezoneh;
	colorBackground[] = {1,0,0,0.5};
	colorText[] = {0, 0, 0, 0};
	font = "PuristaMedium";
	sizeEx = 0.4;
	text = "";

	class VScrollbar
	{
		color[] =
		{
			1,
			1,
			1,
			1
		};
		width = 0.021;
		autoScrollEnabled = 1;
	};
	class HScrollbar
	{
		color[] =
		{
			1,
			1,
			1,
			1
		};
		height = 0.028;
	};
};
