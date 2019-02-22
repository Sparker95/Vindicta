//Exported via Arma Dialog Creator (https://github.com/kayler-renslow/arma-dialog-creator)
#ifndef HG_CustomControlClassesh
#define HG_CustomControlClassesh 1
//Create a header guard to prevent duplicate include.

class Map_UI_text_base
{
	type = 0;
	style = 16+512;
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	sizeEx = safeZoneH*0.035;
	x = 0;
	y = 0;
	w = 0;
	h = 0;
	text = "1";
	font = "PuristaMedium";
	lineSpacing = 1;
	
};
class Map_UI_panel : Map_UI_text_base 
{
	type = 0;
	style = 0+16+512;
	colorBackground[] = {0,0,0,0.5};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	
};
class Map_UI_button : Map_UI_text_base 
{
	type = 1;
	style = 2;
	text = "";
	borderSize = 0.01;
	colorBackground[] = {0,0,0,0.5};
	colorBackgroundActive[] = {0,0.6,0,0.5};
	colorBackgroundDisabled[] = {0,0,0,0.5};
	colorBorder[] = {0,0,0,0};
	colorDisabled[] = {0,0,0,0.5};
	colorFocused[] = {0,0,0,0.5};
	colorShadow[] = {0,0,0,0};
	offsetPressedX = safeZoneW*0.005;
	offsetPressedY = safeZoneH*0.005;
	offsetX = 0;
	offsetY = 0;
	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.1,1.0};
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.1,1.0};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.1,1.0};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.1,1.0};
	
};

class Map_UI_text_scroll : RscControlsGroup
{
	type = 15;
	style = 16+512;
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	sizeEx = safeZoneH*0.035;
	x = 0;
	y = 0;
	w = 0;
	h = 0;
	text = "1";
	font = "PuristaMedium";
	lineSpacing = 1;
};
#endif
