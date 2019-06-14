#include "\A3\ui_f\hpp\defineCommonGrids.inc"
#include "..\..\OOP_Light\OOP_Light.h"
#include "UIProfileColors.h"

#define MUI_TXT_SIZE_XS "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.48"
#define MUI_TXT_SIZE_S "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.52"
#define MUI_TXT_SIZE_M "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.65"
#define MUI_TXT_SIZE_L "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.7"


#ifndef HG_MissionUIControlClassesh
#define HG_MissionUIControlClassesh 1
//Create a header guard to prevent duplicate include.

// #-0
class MUI_BASE
{
	type = CT_STATIC;

	x = 0;
	y = 0;
	w = 0;
	h = 0;

	sizeEx = MUI_TXT_SIZE_M;
	style = ST_CENTER;
	text = "";
	font = "PuristaMedium";

	colorBackground[] = MUIC_TRANSPARENT;
	colorText[] = MUIC_WHITE;

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


class MUI_BG_BLACKSOLID : MUI_BASE 
{
	type = CT_STATIC;

	sizeEx = MUI_TXT_SIZE_S;
	colorBackground[] = MUIC_BLACK;
};


class MUI_BG_BLACKTRANSPARENT : MUI_BASE 
{
	type = CT_STATIC;

	sizeEx = MUI_TXT_SIZE_S;
	colorBackground[] = MUIC_BLACKTRANSP;
};


class MUI_HEADLINE
{
	type = CT_STATIC;

	x = 0;
	y = 0;
	w = 0;
	h = safeZoneH * 0.026;

	sizeEx = MUI_TXT_SIZE_S;
	style = 192+2;
	text = "";
	font = "PuristaMedium";
	
	colorBackground[] = {0.702,0.102,0.102,1};	// variable, selected outpost color
	colorText[] = MUIC_WHITE;
	shadow = 1;
};


class MUI_BUTTON_TXT : RscButton
{
	type = CT_BUTTON;

	h = safeZoneH * 0.02;
	sizeEx = MUI_TXT_SIZE_M;
	style = 192+2;
	font = "PuristaLight";
	text = "";
	borderSize = 0;

	colorBackground[] = MUIC_BLACK;
	colorBackgroundActive[] = MUIC_WHITE;
	colorBackgroundDisabled[] = MUIC_BLACK;
	colorBorder[] = MUIC_TRANSPARENT;
	colorDisabled[] = MUIC_TRANSPARENT;
	colorFocused[] = MUIC_BLACK;				// same as colorBackground to disable blinking
	colorShadow[] = MUIC_TRANSPARENT;

	offsetPressedX = 0;
	offsetPressedY = 0;
	offsetX = 0;
	offsetY = 0;

	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};

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

class MUI_BUTTON_TAB : MUI_BUTTON_TXT
{
	type = CT_BUTTON;
	style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
};

// RscListNBox
class MUI_LISTNBOX : MUI_BASE 
{
	type = CT_LISTNBOX;

	style = ST_MULTI;
	columns[] = {3.0 * GUI_GRID_H, 0.0}; 
	sizeEx = MUI_TXT_SIZE_M;
	font = "PuristaMedium";

	maxHistoryDelay = 1;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 1.2 * GUI_GRID_H;
	headerHeight = 0.9 * GUI_GRID_H;

	colorActive[] = MUIC_WHITE;
	colorDisabled[] = MUIC_TRANSPARENT;
	colorSelect[] = MUIC_BLACK;
	colorSelect2[] = MUIC_BLACK;
	colorSelectBackground[] = MUIC_WHITE;
	colorSelectBackground2[] = MUIC_WHITE;

	soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect",0.09,1};

	autoScrollSpeed = -1; 
	autoScrollDelay = 5; 
	autoScrollRewind = 0;
	disableOverflow = 0;
	drawSideArrows = 0;

	idcLeft = -1; 
	idcRight = -1; 

	fade = 0;
	show = 1;
	period = 0;

	class ListScrollBar
	{
	arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
	arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
	border = "#(argb,8,8,3)color(1,1,1,1)";
	color[] = MUIC_WHITE;
	colorActive[] = MUIC_WHITE;
	colorDisabled[] = MUIC_WHITE;
	thumb = "#(argb,8,8,3)color(1,1,1,1)";		
	};
};

/*
class MUI_STRUCT_TXT : MUI_BASE 
{
	type = 13;

	size = 1;
	class Attributes
	{
		
	};
};
*/

class MUI_ST_FRAME : MUI_BASE
{
	type = CT_STATIC;

	sizeEx = MUI_TXT_SIZE_XS;
	style = ST_FRAME;
	text = "";
	font = "PuristaLight";
};

class MUI_EDIT : MUI_BASE
{
	type = CT_EDIT;

	sizeEx = MUI_TXT_SIZE_XS;
	style = ST_MULTI + ST_NO_RECT; // multi line + no border

	text = "";
	font = "PuristaMedium";
	
	autocomplete = "";
	canModify = false; 
	maxChars = 1000; 
	forceDrawCaret = false;

	colorSelection[] = MUIC_TRANSPARENT;
	colorText[] = MUIC_WHITE;
	colorDisabled[] = MUIC_TRANSPARENT; 
	colorBackground[] = MUIC_TRANSPARENT; 

	lineSpacing = 1.1 * GUI_GRID_H;
};

#endif

