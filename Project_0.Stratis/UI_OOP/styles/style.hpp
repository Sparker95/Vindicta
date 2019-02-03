////////////////
//Base Classes//
////////////////

class BaseControl
{
	idc=-1;
	x=0;
	y=0;
	w=safezoneW*0.1;
	h=safezoneH*0.1;
};

class BaseScrollBar
{
	color[] = {1,1,1,0.6};
	colorActive[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.3};
	thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
	arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
	arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
	border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	shadow = 0;
	scrollSpeed = 0.06;
	width = 0;
	height = 0;
	autoScrollEnabled = 1;
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
};

class OOP_MainLayer : BaseControl
{
	type = CT_CONTROLS_GROUP;
	idc = -1;
	style = 16;
	x = safezoneX;
	y = safezoneY;
	w = safezoneW;
	h = safezoneH; 
	class VScrollbar: BaseScrollBar {
		width = 0;
		height = 0;
		color[] = {0.25, 0.25, 0.25, 1};
		shadow = 0;
		autoScrollEnabled = 0;
		autoScrollDelay = 5;
		autoScrollSpeed = -1;
		autoScrollRewind = 0;
	};
	class HScrollbar: BaseScrollBar {
		height = 0;
		width = 0;
		color[] = {0.25, 0.25, 0.25, 1};
		shadow = 0;
		
	};
}

class OOP_SubLayer : OOP_MainLayer
{
	x = 0;
	y = 0;
	w = safezoneW/3;
	h = safezoneH/5;
};

class OOP_IGUIBack
{
	type = CT_STRUCTURED_TEXT;
	idc = -1;
	style = ST_HUD_BACKGROUND;
	text = "";
	colorText[] = { 0, 0, 0, 0};
	font = "PuristaMedium";
	sizeEx = 0;
	shadow = 0;
	x = 0.1;
	y = 0.1;
	w = 0.1;
	h = 0.1;
	size = 0.018;
	colorbackground[] = 
	{
		"(profilenamespace getvariable ['IGUI_BCG_RGB_R',0])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_G',1])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_B',1])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_A',0.8])"
	};
};

class TopBar : BaseControl{
		type=CT_STATIC;
		style=ST_LEFT;
		shadow = 1;
		colorShadow[] = {0, 0, 0, 0.5};
		font = "RobotoCondensed";
		SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		text = "";
		colorText[] = {0.72,0.78,0.99,1};
		colorBackground[] = {0.03,0.65,0,1};
		linespacing = 1;
		tooltipColorText[] = {1,1,1,1};
		tooltipColorBox[] = {1,1,1,1};
		tooltipColorShade[] = {0,0,0,0.65};
};

class OOP_Button : BaseControl
{
	type=CT_BUTTON;
	style=ST_CENTER;
	shadow=0;
	text="Button..";
	font = "RobotoCondensed";
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorText[] = {1, 1, 1, 1};
	colorDisabled[] = {0.4, 0.4, 0.4, 1};
	colorBackground[] = { 0.4, 0.4, 0.4, 1 };
	colorBackgroundActive[] = { 0.4, 0.4, 0.4, 1 };
	colorBackgroundDisabled[] = {0.95,0.95,0.95,1};
	offsetX = 0.003;
	offsetY = 0.003;
	offsetPressedX = 0.002;
	offsetPressedY = 0.002;
	colorFocused[] = {0.4, 0.4, 0.4, 1};
	colorShadow[] = {0.5,0.5,0.5,1};
	colorBorder[] = {0,0,0,1};
	borderSize = 0.0;
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
};

class OOP_Listbox : BaseControl
{
	access = 0;
	type=CT_LISTBOX;
	style = ST_LEFT;
	blinkingPeriod = 0;
	font = "RobotoCondensed";
	colorSelect[] = {1, 1, 1, 1};
	colorText[] = {1, 1, 1, 1};
	colorBackground[] = {0.28,0.28,0.28,0.28};
	colorSelect2[] = {1, 1, 1, 1};
	colorSelectBackground[] = {0.95, 0.95, 0.95, 0.5};
	colorSelectBackground2[] = {1, 1, 1, 0.5};
	colorScrollbar[] = {0.2, 0.2, 0.2, 1};
	colorPicture[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,1};
	arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
	arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
	wholeHeight = 0.45;
	rowHeight = 0.04;
	color[] = {0.7, 0.7, 0.7, 1};
	colorActive[] = {0,0,0,1};
	colorDisabled[] = {0,0,0,0.3};
	sizeEx = 0.040;
	soundSelect[] = {"",0.1,1};
	soundExpand[] = {"",0.1,1};
	soundCollapse[] = {"",0.1,1};
	maxHistoryDelay = 1;
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
	class ListScrollBar: BaseScrollBar
	{
		color[] = {1,1,1,1};
		autoScrollEnabled = 1;
	};
};

class OOP_Text : BaseControl
{
	idc = -1;
	type=CT_STATIC;
	style=ST_LEFT;
	shadow = 1;
	colorShadow[] = {0, 0, 0, 0.5};
	font = "RobotoCondensed";
	SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	text = "text";
	colorText[] = {0.72,0.78,0.99,1};
	colorBackground[] = {0,0,0,0};
	linespacing = 1;
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
};

class OOP_TextRight : OOP_Text
{
	style=ST_RIGHT;
};

class OOP_Edit : BaseControl
{
	type = CT_EDIT;
	style = ST_LEFT + ST_FRAME;
	font = "PuristaMedium";
	shadow = 2;
	text="";
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorBackground[] = {0, 0, 0, 1};
	soundSelect[] = {"",0.1,1};
	soundExpand[] = {"",0.1,1};
	colorText[] = {0.95, 0.95, 0.95, 1};
	colorDisabled[] = {1, 1, 1, 0.50};
	autocomplete = false;
	colorSelection[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", 1};
	canModify = 1;
};
class OOP_EditMulti : OOP_Edit
{
	style = ST_LEFT + ST_MULTI;
};

class OOP_Checkbox : BaseControl
{
	access = 0;
	type = CT_CHECKBOX;
	style = ST_LEFT + ST_MULTI;
	default = 0;
	color[] = { 1, 1, 1, 0.7 }; // Texture color
	colorFocused[] = { 1, 1, 1, 1 }; // Focused texture color
	colorHover[] = { 1, 1, 1, 1 }; // Mouse over texture color
	colorPressed[] = { 1, 1, 1, 1 }; // Mouse pressed texture color
	colorDisabled[] = { 1, 1, 1, 0.2 }; // Disabled texture color
	colorBackground[] = { 0, 0, 0, 0 }; // Fill color
	colorBackgroundFocused[] = { 0, 0, 0, 0 }; // Focused fill color
	colorBackgroundHover[] = { 0, 0, 0, 0 }; // Mouse hover fill color
	colorBackgroundPressed[] = { 0, 0, 0, 0 }; // Mouse pressed fill color
	colorBackgroundDisabled[] = { 0, 0, 0, 0 }; // Disabled fill color
	textureChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";        //Texture of checked CheckBox.
	textureUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";        //Texture of unchecked CheckBox.
	textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";    //Texture of checked focused CheckBox (Could be used for showing different texture when focused).
	textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";    //Texture of unchecked focused CheckBox.
	textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	tooltip = ""; // Tooltip text
	tooltipColorShade[] = { 0, 0, 0, 1 }; // Tooltip background color
	tooltipColorText[] = { 1, 1, 1, 1 }; // Tooltip text color
	tooltipColorBox[] = { 1, 1, 1, 1 }; // Tooltip frame color
	soundClick[] = { "\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1 }; // Sound played after control is activated in format {file, volume, pitch}
	soundEnter[] = { "\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1 }; // Sound played when mouse cursor enters the control
	soundPush[] = { "\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1 }; // Sound played when the control is pushed down
	soundEscape[] = { "\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1 }; // Sound played when the control is released after pushing down
};

class OOP_Tree : BaseControl
{
	idd=-1;
	type = CT_TREE;
	style = ST_LEFT;
	default = 0; 
	blinkingPeriod = 0; 
	colorBorder[] = {0,0,0,1};
	font = "RobotoCondensed";
	sizeEx = 0.040;
	colorPicture[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,1};
	colorPictureRight[] = {1,1,1,1};
	colorPictureRightSelected[] = {1,1,1,1};
	colorPictureRightDisabled[] = {1,1,1,1};
	colorBackground[] = {0.2,0.2,0.2,1}; // Fill color
	colorSelect[] = {1,0.5,0,1}; // Selected item fill color (when multiselectEnabled is 0)
	colorMarked[] = {1,0.5,0,0.5}; // Marked item fill color (when multiselectEnabled is 1)
	colorMarkedSelected[] = {1,0.5,0,1}; // Selected item fill color (when multiselectEnabled is 1)
	shadow = 1; // Shadow (0 - none, 1 - N/A, 2 - black outline)
	colorText[] = {1,1,1,1}; // Text color
	colorSelectText[] = {1,1,1,1}; // Selected text color (when multiselectEnabled is 0)
	colorMarkedText[] = {1,1,1,1}; // Selected text color (when multiselectEnabled is 1)
	tooltip = ""; // Tooltip text
	tooltipColorShade[] = {0,0,0,1}; // Tooltip background color
	tooltipColorText[] = {1,1,1,1}; // Tooltip text color
	tooltipColorBox[] = {1,1,1,1}; // Tooltip frame color
	multiselectEnabled = 0; // Allow selecting multiple items while holding Ctrl or Shift
	expandOnDoubleclick = 1; // Expand/collapse item upon double-click
	hiddenTexture = "A3\ui_f\data\gui\rsccommon\rsctree\hiddenTexture_ca.paa"; // Expand icon
	expandedTexture = "A3\ui_f\data\gui\rsccommon\rsctree\expandedTexture_ca.paa"; // Collapse icon
	maxHistoryDelay = 1; // Time since last keyboard type search to reset it
	// Scrollbar configuration
	class ScrollBar : BaseScrollBar{
		color[] = {1,1,1,1};
		autoScrollEnabled = 1;
	};

	colorDisabled[] = {0,0,0,0}; 
	colorArrow[] = {0,0,0,0}; 
};

/*
*	New ctrl
*/
class OOP_Picture : BaseControl
{
	shadow = 0;
	type = CT_STATIC;
	style = ST_PICTURE;
	sizeEx = 0.023;
	text="#(rgb,8,8,3)color(1,1,1,1)";
	font = "PuristaMedium";
	colorBackground[] = {};
	colorText[] = {};
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
};

class OOP_PictureKeepAspect : OOP_Picture
{
	style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
};

class OOP_TextMulti : OOP_Text
{
	linespacing = 1;
	style = ST_LEFT + ST_MULTI + ST_NO_RECT;
};

class OOP_ActiveText : OOP_Text{
	type = CT_ACTIVETEXT;
	style = ST_LEFT;
	sizeEx = 0.040;
	font = "PuristaLight";
	color[] = {1, 1, 1, 1};
	colorActive[] = {1, 0.2, 0.2, 1};
	colorDisabled[] = {1, 0.2, 0.2, 1};
	soundEnter[] = {"\A3\ui_f\data\sound\onover", 0.09, 1};
	soundPush[] = {"\A3\ui_f\data\sound\new1", 0.0, 0};
	soundClick[] = {"\A3\ui_f\data\sound\onclick", 0.07, 1};
	soundEscape[] = {"\A3\ui_f\data\sound\onescape", 0.09, 1};
	action="";
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
};

class OOP_ButtonTextOnly : OOP_Button {
	colorBackground[] = {1, 1, 1, 0};
	colorBackgroundActive[] = {1, 1, 1, 0};
	colorBackgroundDisabled[] = {1, 1, 1, 0};
	colorFocused[] = {1, 1, 1, 0};
	colorShadow[] = {1, 1, 1, 0};
	borderSize = 0.0;
};

class OOP_Slider : BaseControl{
	type = CT_XSLIDER;
	style = SL_HORZ;
	color[] = {0.102,0.2,0.6,1};
	colorBase[] = {0,1,0,1};
	//Color control is focus
	colorActive[] = {1,1,1,1};
	arrowEmpty = "\A3\ui_f\data\GUI\Cfg\Slider\arrowEmpty_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\Cfg\Slider\arrowFull_ca.paa";
	thumb = "\A3\ui_f\data\GUI\Cfg\Slider\thumb_ca.paa";
	border = "\A3\ui_f\data\GUI\Cfg\Slider\border_ca.paa";
	vspacing = 0;
};

class OOP_SliderY : BaseControl{
	type = CT_XSLIDER;
	style = SL_VERT;
	colorBase[] = {0,1,0,1};
	//Color control is focus
	color[] = { 1, 1, 1, 1 }; 
    coloractive[] = { 1, 0, 0, 0.5 };

	vspacing = 0;
};

class OOP_StructuredText : OOP_Text {
	type = CT_STRUCTURED_TEXT;
	style = ST_LEFT;
	sizeEx = (((((safezoneW / safezoneH) min 1.2)/1.2)/25)*1);
	size = 0.04;
	class Attributes {
		font = "PuristaMedium";
		color = "#ffffff";
		align = "left";
		shadow = 1;
	};
};

class OOP_Progress : BaseControl
{
	type = CT_PROGRESS;
	style = ST_LEFT;
	colorBar[] = {1,1,1,1};
	colorFrame[] = {0,0,0,1};
	texture = "#(argb,8,8,3)color(1,1,1,1)";
	w = 1;
	h = 0.03;
};

class OOP_ProgressVertical : OOP_Progress
{
	style = ST_RIGHT;
};