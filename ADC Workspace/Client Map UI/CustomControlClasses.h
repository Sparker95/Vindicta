#ifndef HG_CustomControlClassesh
#define HG_CustomControlClassesh 1
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
// #-0
class MUI_BASE
{
	x = 0;
	y = 0;
	w = 0;
	h = 0;
	style = 2;
	text = "1";
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	sizeEx = 0;
	blinkingPeriod = 0;
	fixedWidth = false;
	lineSpacing = 0;
	moving = false;
	onCanDestroy = "";
	onChar = "";
	onDestroy = "";
	onIMEChar = "";
	onIMEComposition = "";
	onJoystickButton = "";
	onKeyDown = "";
	onKeyUp = "";
	onKillFocus = "";
	onLoad = "";
	onMouseButtonDblClick = "";
	onMouseButtonDown = "";
	onMouseButtonUp = "";
	onMouseEnter = "";
	onMouseExit = "";
	onMouseMoving = "";
	onMouseZChanged = "";
	onSetFocus = "";
	onTimer = "";
	onVideoStopped = "";
	shadow = 0;
	tileH = 0;
	tileW = 0;
	
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
//#-0
class MUI_BG_GRAYSOLID : MUI_BASE 
{
	colorBackground[] = {0.12,0.12,0.12,1};
	sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.745);
	
};
//#-0
class MUI_BG_BLACKTRANSPARENT : MUI_BASE 
{
	colorBackground[] = {0,0,0,0.75};
	
};
//#-0
class MUI_HEADLINE : MUI_BASE 
{
	h = safeZoneH * 0.02;
	style = 2+192;
	colorBackground[] = {0.702,0.102,0.102,1};
	colorText[] = {1,1,1,1};
	
};
//#-1
class MUI_BUTTON_TXT : MUI_BASE 
{
	h = safeZoneH * 0.023;
	style = 192+2;
	borderSize = 0;
	colorBackground[] = {0,0,0,1};
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
	sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.98);
	soundClick[] = {"",0.0,0.0};
	soundEnter[] = {"",0.0,0.0};
	soundEscape[] = {"",0.0,0.0};
	soundPush[] = {"",0.0,0.0};
	shadow = 0;
	action = "";
	onButtonClick = "";
	onButtonDblClick = "";
	onButtonDown = "";
	onButtonUp = "";
	onLBDrop = "";
	onMouseButtonClick = "";
	
};
//#-1
class MUI_BUTTON_TAB : MUI_BUTTON_TXT 
{
	h = 0;
	sizeEx = 0;
	
};
class MUI_LISTBOX : MUI_BASE 
{
	colorBackground[] = {0,0,0,0.6};
	colorDisabled[] = {0,0,0,0.6};
	colorSelect[] = {1,1,1,1};
	maxHistoryDelay = 1;
	rowHeight = 1;
	soundSelect[] = {"",0.0,0.0};
	colorSelect2[] = {1,1,1,1};
	colorSelectBackground[] = {0,0,0,0.6};
	colorSelectBackground2[] = {0,0,0,0.6};
	period = 0;
	class ListScrollBar
	{
		
	};
	
};
class MUI_STRUCT_TXT : MUI_BASE 
{
	text = "";
	size = 1;
	class Attributes
	{
		
	};
	
};
#endif
