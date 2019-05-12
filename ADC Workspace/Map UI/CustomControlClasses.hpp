#ifndef HG_CustomControlClasseshpp
#define HG_CustomControlClasseshpp 1
//Create a header guard to prevent duplicate include.

class Map_UI_text_base
{
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
class CategoryTextControl
{
	style = 2;
	text = "";
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	
};
class MUI_Text_Base
{
	x = 0;
	y = 0;
	w = 0;
	h = 0;
	style = 16+512;
	text = "1";
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	sizeEx = 0;
	
};
class MUI_BG_GraySolid
{
	colorBackground[] = {0.12,0.12,0.12,1};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.76);
	
};
class MUI_BG_BlackGlass
{
	colorBackground[] = {0,0,0,0.75};
	
};
class Map_UI_panel : Map_UI_text_base 
{
	style = 0+16+512;
	colorBackground[] = {0,0,0,0.5};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	
};
class Map_UI_button : Map_UI_text_base 
{
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
class Map_UI_text_scroll : Map_UI_text_base 
{
	
};
class MUI_Button_Base : MUI_Text_Base 
{
	h = safeZoneH * 0.02;
	style = 192+2;
	text = "BUTTON";
	colorBackground[] = {0,0,0,1};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
	
};
class MUI_Button_Tab : MUI_Text_Base 
{
	w = safeZoneW * 0.044;
	h = safeZoneH * 0.068;
	style = 2;
	colorBackground[] = {0,0,0,1};
	colorText[] = {1,1,1,1};
	
};
/*
Use profile faction color for background
Use white text
*/
class MUI_Header_SideRGB : MUI_Text_Base 
{
	h = safeZoneH * 0.023;
	style = 0;
	colorBackground[] = {0.702,0.102,0.102,1};
	colorText[] = {1,1,1,1};
	
};
#endif
