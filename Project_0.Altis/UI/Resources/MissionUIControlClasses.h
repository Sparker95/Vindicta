#include "\A3\ui_f\hpp\defineCommonGrids.inc"
#include "..\..\OOP_Light\OOP_Light.h"

#define MUI_TXT_SIZE_XS "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.4"
#define MUI_TXT_SIZE_S "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.5"
#define MUI_TXT_SIZE_M "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.65"
#define MUI_TXT_SIZE_L "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.7"


#ifndef HG_MissionUIControlClassesh
#define HG_MissionUIControlClassesh 1
//Create a header guard to prevent duplicate include.

// #-0
class MUI_BASE
{
	type = 0;
	x = 0;
	y = 0;
	w = 0;
	h = 0;
	sizeEx = MUI_TXT_SIZE_M;
	style = 2;
	text = "1";
	font = "PuristaMedium";
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,1,1,1};	
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

//#-0
class MUI_BG_BLACKSOLID : MUI_BASE 
{
	type = 0;
	colorBackground[] = {0,0,0,1};
	sizeEx = MUI_TXT_SIZE_S;
};
//#-0
class MUI_BG_BLACKTRANSPARENT : MUI_BASE 
{
	type = 0;
	colorBackground[] = {0,0,0,0.75};
	sizeEx = MUI_TXT_SIZE_S;
};
//#-0
class MUI_HEADLINE : MUI_BASE 
{
	sizeEx = MUI_TXT_SIZE_S;
	h = safeZoneH * 0.02;
	style = ST_UPPERCASE+ST_CENTER+ST_VCENTER;
	colorBackground[] = {0.702,0.102,0.102,1};
	colorText[] = {1,1,1,1};
	shadow = 1;
};
//#-1
class MUI_BUTTON_TXT : MUI_BASE 
{
	type = 1;
	h = safeZoneH * 0.023;
	style = 192+2;
	sizeEx = MUI_TXT_SIZE_M;
	font = "PuristaLight";

	borderSize = 0;
	colorBackground[] = {0,0,0,1};
	colorBackgroundActive[] = {1,1,1,1};
	colorBackgroundDisabled[] = {0,0,0,1};
	colorBorder[] = {0,0,0,0};
	colorDisabled[] = {0.5,0.5,0.5,1};
	colorFocused[] = {0,0,0,1};
	colorShadow[] = {0,0,0,0};
	offsetPressedX = 0;
	offsetPressedY = 0;
	offsetX = 0;
	offsetY = 0;
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
	onMouseEnter = "";    
    onMouseExit = "";   
};
//#-1
class MUI_BUTTON_TAB : MUI_BUTTON_TXT
{
	type = 1;
	style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
};

// RscListNBox
class MUI_LISTNBOX : MUI_BASE 
{
	type = 102;
	style = ST_MULTI;
	columns[] = {0.0, 0.0, 0.0}; 
	sizeEx = MUI_TXT_SIZE_M;
	font = "PuristaLight";

	maxHistoryDelay = 1;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 1.1 * GUI_GRID_H;
	headerHeight = 0.9 * GUI_GRID_H;

	colorDisabled[] = {0,0,0,0.6};
	colorSelect[] = {1,1,1,1};
	soundSelect[] = {"",0.0,0.0};
	colorSelect2[] = {1,1,1,1};
	colorSelectBackground[] = {0,0,0,0.6};
	colorSelectBackground2[] = {0,0,0,0.6};

	period = 0;

	autoScrollSpeed = -1; 
	autoScrollDelay = 5; 
	autoScrollRewind = 0;
	drawSideArrows = 0;

	idcLeft = -1; 
	idcRight = -1; 

	class ListScrollBar
	{
	arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
	arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
	border = "#(argb,8,8,3)color(1,1,1,1)";
	color[] = {1,1,1,0.6};
	colorActive[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.3};
	thumb = "#(argb,8,8,3)color(1,1,1,1)";		
	};
};

class MUI_STRUCT_TXT : MUI_BASE 
{
	type = 13;
	size = 1;
	class Attributes
	{
		
	};
};

class MUI_ST_FRAME : MUI_BASE
{
	type = 0;

	sizeEx = MUI_TXT_SIZE_XS;
	style = 64;
	text = "";
	font = "PuristaLight";

};

class MUI_EDIT : MUI_BASE
{
	type = 2;
	style = "16 + 512"; // multi line + no border
	font = "PuristaMedium";
	sizeEx = 0.04;
	autocomplete = "";
	canModify = false; 
	maxChars = 120; 
	forceDrawCaret = false;
	colorSelection[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	colorDisabled[] = {0,0,0,0}; 
	colorBackground[] = {0,0,0,0}; 
	text = __EVAL("Line 1" + endl + "Line 2" + endl + "Line 3"); // how to output multiline
};

class MUI_MULTILINE_TXT : MUI_EDIT
{
	type = 0;
	sizeEx = MUI_TXT_SIZE_S;
	style = 16+512;
	text = ["line1 %1 line2 %1 line3", endl];
	lineSpacing = 1;
};

#endif
