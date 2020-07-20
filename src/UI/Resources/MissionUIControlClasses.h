#include "..\..\common.h"
#include "defineCommonGrids.hpp"
#include "UIProfileColors.h"

#define MUI_TXT_SIZE_M safeZoneH*0.018

// For safezone UIs
#define MUI_TXT_SIZE_M_SZ MUI_TXT_SIZE_M

// For absolute units UIs
#define MUI_TXT_SIZE_M_ABS 0.035

#ifndef HG_MissionUIControlClassesh
#define HG_MissionUIControlClassesh 1
//Create a header guard to prevent duplicate include.

// Macro to duplicate existing classes for absolute units
#define __MUI_CLASS_ABS(class0) class class0##_ABS : class0 { sizeEx = MUI_TXT_SIZE_M_ABS; }


class MUI_BASE
{
	idc = -1;
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

	tooltipColorText[] = MUIC_WHITE;
	tooltipColorBox[] = MUIC_BLACK;
	tooltipColorShade[] = MUIC_BLACK;
};
__MUI_CLASS_ABS(MUI_BASE);


class MUI_DESCRIPTION : MUI_BASE
{
	idc = -1;
	type = CT_STATIC;

	x = 0;
	y = 0;
	w = 0;
	h = 0;

	colorBackground[] = MUIC_BLACK;
	colorText[] = MUIC_WHITE;
	style = ST_LEFT;
};
__MUI_CLASS_ABS(MUI_DESCRIPTION);


class MUI_BG_BLACKSOLID : MUI_BASE 
{
	type = CT_STATIC;
	colorBackground[] = MUIC_BLACK;
};
__MUI_CLASS_ABS(MUI_BG_BLACKSOLID);


class MUI_BG_BLACKTRANSPARENT : MUI_BASE 
{
	type = CT_STATIC;

	sizeEx = MUI_TXT_SIZE_M;
	colorBackground[] = MUIC_BLACKTRANSP;
};
__MUI_CLASS_ABS(MUI_BG_BLACKTRANSPARENT);


class MUI_BG_TRANSPARENT : MUI_BASE
{
	type = CT_STATIC;
	sizeEx = MUI_TXT_SIZE_M;
};
__MUI_CLASS_ABS(MUI_BG_TRANSPARENT);

class MUI_BG_TRANSPARENT_LEFT : MUI_BG_TRANSPARENT
{
	style = ST_LEFT;
};
__MUI_CLASS_ABS(MUI_BG_TRANSPARENT_LEFT);


class MUI_BG_TRANSPARENT_MULTILINE_LEFT : MUI_BASE
{
	type = CT_STATIC;
	sizeEx = MUI_TXT_SIZE_M;
	style = 16+0+0x200; // multi line, no rect, left alighnemt
	lineSpacing = 1; // must set it for multi line to work
	font = "RobotoCondensed";
};
__MUI_CLASS_ABS(MUI_BG_TRANSPARENT_MULTILINE_LEFT);


class MUI_BG_TRANSPARENT_MULTILINE_CENTER : MUI_BG_TRANSPARENT_MULTILINE_LEFT
{
	style = ST_CENTER + 16+0+0x200;
};
__MUI_CLASS_ABS(MUI_BG_TRANSPARENT_MULTILINE_CENTER);


class MUI_HEADLINE : MUI_BG_BLACKSOLID
{
	type = CT_STATIC;

	x = 0;
	y = 0;
	w = 0;
	h = safeZoneH * 0.026;

	sizeEx = MUI_TXT_SIZE_M;
	colorText[] = MUIC_BLACK; 
	colorBackground[] = MUIC_MISSION; 
	style = ST_LEFT;
	text = "";
	font = "PuristaMedium";
	shadow = 0;
};
__MUI_CLASS_ABS(MUI_HEADLINE);


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
	colorBackgroundDisabled[] = MUIC_TXT_DISABLED;
	colorBorder[] = MUIC_TRANSPARENT;
	colorDisabled[] = MUIC_WHITE;
	colorFocused[] = MUIC_BLACK; // same as colorBackground to disable blinking
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
	onMouseEnter = "_this#0 ctrlSetTextColor [0, 0, 0, 1];"; // Set text black
	onMouseExit = "_this#0 ctrlSetTextColor [1, 1, 1, 1];"; // Set text white
};
__MUI_CLASS_ABS(MUI_BUTTON_TXT);


// special override for sorting buttons for CMUI
class MUI_BUTTON_LISTNBOX : MUI_BUTTON_TXT 
{
    IDC = -1; 
	font = "RobotoCondensed";
	style = ST_LEFT;
};
__MUI_CLASS_ABS(MUI_BUTTON_LISTNBOX);


// Dummy button with no visuals
class MUI_BUTTON_DUMMY : MUI_BUTTON_TXT
{
	// Disable all colors
	colorBackground[] = {0,0,0,0};
	colorBackgroundActive[] = {0,0,0,0};
	colorBackgroundDisabled[] = {0,0,0,0};
	colorBorder[] = {0,0,0,0};
	colorDisabled[] = {0,0,0,0};
	colorFocused[] = {0,0,0,0};
	colorShadow[] = {0,0,0,0};
};


// Checkbox-like button with custom event handlers to toggle its colors
class MUI_BUTTON_TXT_CHECKBOX_LIKE : MUI_BG_BLACKSOLID
{
	sizeEx = MUI_TXT_SIZE_M;
	style = 192+2;
	font = "PuristaLight";
	text = "";

	colorBackground[] = MUIC_BLACK;
	colorBackgroundActive[] = MUIC_BLACK;
	colorBackgroundDisabled[] = MUIC_BLACK;

	onLoad = "[_this select 0] call ui_fnc_buttonCheckboxInit;";
	//onUnload = "'ui.rpt' ofstream_write (format ['Unload %1', _this]);";
};
__MUI_CLASS_ABS(MUI_BUTTON_TXT_CHECKBOX_LIKE);


// Button with text that behaves like it's a checkbox
// This control type is trash, don't use it
// Can't set BG color when mouse if over it, wtf
class MUI_BUTTON_TXT_CHECKBOX : RscTextCheckBox
{
	type = CT_CHECKBOXES;
	style = 2;
	h = safezoneh * 0.02;
	colorText[] = MUIC_WHITE; //  text color of the unchecked checkbox
	colorTextSelect[] = {0.13, 0.7, 0.29, 1}; // text color of the checked checkbox
	color[] = {0, 0, 0,1}; // unknown

	colorBackground[] = {1,0,0,1}; // background color when checkbox is not in focus (doesn't matter if checked or not)
	colorSelectedBg[] = {0,1,0,1}; // background color when checkbox is in focus (doesn't matter if checked or not)  !! doesn't seem to work !!

	onMouseEnter = "(_this select 0) ctrlSetBackgroundColor [1,1,1,1]; (_this select 0) ctrlSetTextColor [0,0,0,1];";
	onMouseExit = "(_this select 0) ctrlSetBackgroundColor [0,0,0,0]; (_this select 0) ctrlSetTextColor [1,1,1,1];";

	colorSelect[] = {0, 0, 0, 0}; // unknown
	colorTextDisable[] = {0, 0, 0, 1};
	colorDisable[] = {0, 0, 0, 1};
	tooltipColorText[] = MUIC_WHITE;
	tooltipColorBox[] = MUIC_BLACK;
	tooltipColorShade[] = MUIC_BLACK;

	font = "RobotoCondensed";
	sizeEx = MUI_TXT_SIZE_M;
	rows = 1;
	columns = 1;
	strings[] =
	{
		"Show intel"
	};
	checked_strings[] =
	{
		"Show intel"
	};

	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
};
__MUI_CLASS_ABS(MUI_BUTTON_TXT_CHECKBOX);


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
	rowHeight = 1.0 * GUI_GRID_H; //1.2 * GUI_GRID_H;
	headerHeight = 0.9 * GUI_GRID_H;

	colorActive[] = MUIC_WHITE;
	colorDisabled[] = MUIC_TRANSPARENT;
	colorSelect[] = MUIC_BLACK;
	colorSelect2[] = MUIC_BLACK;
	colorSelectBackground[] = MUIC_WHITE;
	colorSelectBackground2[] = MUIC_WHITE;

	tooltipColorText[] = MUIC_WHITE;
	tooltipColorBox[] = MUIC_BLACK;
	tooltipColorShade[] = MUIC_BLACK;

	soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect", 1, 1};

	autoScrollSpeed = -1; 
	autoScrollDelay = 5; 
	autoScrollRewind = 0;
	drawSideArrows = 0;
	disableOverflow = 1;

	idcLeft = -1; 
	idcRight = -1; 

	fade = 0;
	show = 1;
	period = 0;

	class ListScrollBar
	{
		width = 0; // width of ListScrollBar
		height = 0; // height of ListScrollBar
		scrollSpeed = 0.01; // scrollSpeed of ListScrollBar

		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa"; // Arrow
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa"; // Arrow when clicked on
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa"; // Slider background (stretched vertically)
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa"; // Dragging element (stretched vertically)

		color[] = {1,1,1,1}; // Scrollbar color
	};
};
__MUI_CLASS_ABS(MUI_LISTNBOX);


// Use it for the left/right button of listnboxes
class MUI_LISTNBOX_BUTTON : MUI_BUTTON_TXT
{
	width = 1.0 * GUI_GRID_H;
	height = 1.0 * GUI_GRID_H;
	text = "X";
};
__MUI_CLASS_ABS(MUI_LISTNBOX_BUTTON);


class MUI_STRUCT_TXT : RscStructuredText
{
	type = 13;
	class Attributes
	{
		font = "PuristaMedium";
		color = "#ffffff";
		colorLink = "#D09B43";
		align = "center";
		shadow = 1;
	};
};
__MUI_CLASS_ABS(MUI_STRUCT_TXT);


class MUI_ST_FRAME : MUI_BASE
{
	type = CT_STATIC;

	sizeEx = MUI_TXT_SIZE_M;
	style = ST_FRAME;
	text = "";
	font = "PuristaBold";
};
__MUI_CLASS_ABS(MUI_ST_FRAME);


class MUI_PROGRESSBAR : MUI_BASE
{
	type = CT_PROGRESS;

	style = 0;
	colorBackground[] = MUIC_TRANSPARENT;
	colorFrame[] = MUIC_BLACK;
	colorBar[] = MUIC_MISSION;
	colorText[] = MUIC_LOGO;
	shadow = 2;
	texture = "#(argb,8,8,3)color(1,1,1,1)";
};
__MUI_CLASS_ABS(MUI_PROGRESSBAR);


class MUI_EDIT : MUI_BASE
{
	type = CT_EDIT;

	sizeEx = MUI_TXT_SIZE_M;
	style = ST_MULTI + ST_NO_RECT; // multi line + no border

	text = "";
	font = "PuristaMedium";
	
	autocomplete = "";
	canModify = true; 
	maxChars = 1000; 
	forceDrawCaret = false;

	colorSelection[] = {0.13, 0.54, 0.21, 1};
	colorText[] = MUIC_WHITE;
	colorDisabled[] = MUIC_TRANSPARENT; 
	colorBackground[] = MUIC_TRANSPARENT; 

	lineSpacing = 1;
};
__MUI_CLASS_ABS(MUI_EDIT);


class MUI_GROUP : MUI_BASE
{

	deletable = 0;
	fade = 0;
	class VScrollbar
	{
		color[] = MUIC_WHITE;
		width = 0.021;
		autoScrollEnabled = 1;
	};
	class HScrollbar
	{
		color[] = MUIC_WHITE;
		height = 0.028;
	};
	class Controls
	{
	};
	type = 15;
	x = 0;
	y = 0;
	w = 1;
	h = 1;
	shadow = 0;
};
__MUI_CLASS_ABS(MUI_GROUP);


class MUI_COMBOBOX : RscCombo
{
	idc = -1;
	sizeEx = MUI_TXT_SIZE_M;
	text = "";
	style = 4;
	font = "PuristaMedium";

	access = 0;
	type = CT_COMBO;
	h = 0.05;
	rowHeight = 0.025;
	wholeHeight = 0.25;
	colorSelect[] = MUIC_BLACK; // Text color when selected
	colorText[] = MUIC_WHITE;
	colorBackground[] = MUIC_BLACK;
	colorScrollbar[] = {1,1,1,1};
	colorDisabled[] = {0.0,0.0,0.5,0.5};
	soundSelect[] = {"",0.1,1};
	soundExpand[] = {"",0.1,1};
	soundCollapse[] = {"",0.1,1};
	maxHistoryDelay = 1.0;
	shadow = 0;
	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
	class ComboScrollBar
	{

		color[] = {1,1,1,0.6};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		thumb = "#(argb,8,8,3)color(1,1,1,1)";
		arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
		arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
		border = "#(argb,8,8,3)color(1,1,1,1)";
		shadow = 0;
	};
};
__MUI_CLASS_ABS(MUI_COMBOBOX);

class MUI_TREE
{
	/* Common properties */
	idc = -1;
	/* Add some entries */
	onLoad = "params ['_tv'];\
			_classes = 'true' configClasses (configFile >> 'CfgVehicles');\
			for '_i' from 0 to 10 do\
			{\
				_tv tvAdd [[], configName selectRandom _classes];\
				for '_j' from 0 to 10 do\
				{\
					_tv tvAdd [[_i], configName selectRandom _classes];\
					for '_k' from 0 to 10 do\
					{\
						_tv tvAdd [[_i, _j], configName selectRandom _classes];\
					};\
				};\
			};";
	moving = 0;
	type = 12;
	style = 0;
	sizeEx = MUI_TXT_SIZE_M_SZ;
	rowHeight = MUI_TXT_SIZE_M_SZ;
	font = "RobotoCondensed";
	colorText[] = {1,1,1,1};
	colorBackground[] = {0,0,0,0.8};
	colorDisabled[] = {1,1,1,0.25};
	shadow = 0;
	access = 0;

	/* CT_TREE specific properties */
	idcSearch = -1;
	colorSelect[] = {1,1,1,0.7};
	colorSelectText[] = {0,0,0,1};
	colorBorder[] = {0,0,0,0};
	colorSearch[] =
	{
		"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13])",
		"(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54])",
		"(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21])",
		"(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"
	};
	colorMarked[] = {0.2,0.3,0.7,1};
	colorMarkedText[] = {0,0,0,1};
	colorMarkedSelected[] = {0,0.5,0.5,1};
	multiselectEnabled = 0;
	colorPicture[] = {1,1,1,1};
	colorPictureSelected[] = {0,0,0,1};
	colorPictureDisabled[] = {1,1,1,0.25};
	colorPictureRight[] = {1,1,1,1};
	colorPictureRightSelected[] = {0,0,0,1};
	colorPictureRightDisabled[] = {1,1,1,0.25};
	colorArrow[] = {1,1,1,1};
	maxHistoryDelay = 1;
	colorSelectBackground[] = {0,0,0,0.5};
	colorLines[] = {0,0,0,0};
	class ScrollBar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		autoScrollDelay = 5;
		autoScrollEnabled = 0;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		color[] = {1,1,1,0.6};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		height = 0;
		scrollSpeed = 0.06;
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		width = 0;
	};
	expandedTexture = "A3\ui_f\data\gui\rsccommon\rsctree\expandedTexture_ca.paa";
	hiddenTexture = "A3\ui_f\data\gui\rsccommon\rsctree\hiddenTexture_ca.paa";
	
	borderSize = 0;
	expandOnDoubleclick = 1;

	/* CT_TREE user interface eventhandlers */
	/*
	onTreeSelChanged = "systemChat str ['onTreeSelChanged',_this]; false";
	onTreeLButtonDown = "systemChat str ['onTreeLButtonDown',_this]; false";
	onTreeDblClick = "systemChat str ['onTreeDblClick',_this]; false";
	onTreeExpanded = "systemChat str ['onTreeExpanded',_this]; false";
	onTreeCollapsed = "systemChat str ['onTreeCollapsed',_this]; false";
	onTreeMouseMove = "systemChat str ['onTreeMouseMove',_this]; false";
	onTreeMouseHold = "systemChat str ['onTreeMouseHold',_this]; false";
	onTreeMouseExit = "systemChat str ['onTreeMouseExit',_this]; false";
	*/
};

#endif

