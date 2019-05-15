#ifndef HG_CustomControlClassesh
#define HG_CustomControlClassesh 1
//Create a header guard to prevent duplicate include.

// #-0
class MUI_BASE
{
	type = 0;
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
	tooltip = "No tooltip.";
	tooltipColorBox[] = {0,0,0,0.7};
	tooltipColorShade[] = {0,0,0,0};
	tooltipColorText[] = {1,1,1,1};
	
};
//#-0
class MUI_BG_GRAYSOLID : MUI_BASE 
{
	type = 0;
	colorBackground[] = {0.12,0.12,0.12,1};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.76);
	
};
//#-0
class MUI_BG_BLACKTRANSPARENT : MUI_BASE 
{
	type = 0;
	colorBackground[] = {0,0,0,0.75};
	
};
//#-0
class MUI_HEADLINE : MUI_BASE 
{
	type = 0;
	h = safeZoneH * 0.023;
	style = 0;
	colorBackground[] = {0.702,0.102,0.102,1};
	colorText[] = {1,1,1,1};
	
};
//#-1
class MUI_BUTTON_TXT : MUI_BASE 
{
	type = 1;
	h = safeZoneH * 0.02;
	borderSize = 0;
	colorBackgroundActive[] = {1,1,1,1};
	colorBackgroundDisabled[] = {0,0,0,1};
	colorBorder[] = {0,0,0,0};
	colorDisabled[] = {0.5,0.5,0.5,1};
	colorFocused[] = {1,1,1,1};
	colorShadow[] = {0,0,0,0};
	offsetPressedX = 0;
	offsetPressedY = 0;
	offsetX = 0;
	offsetY = 0;
	shadow = 0;
	
};
//#-1
class MUI_BUTTON_TAB : MUI_BUTTON_TXT 
{
	type = 1;
	h = 0;
	
};
#endif
