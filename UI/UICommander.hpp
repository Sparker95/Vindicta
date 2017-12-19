//==== Commander's controls at map view ====

#include "UICommanderIDC.hpp"

class RscButton_0: RscButton //Button with redefined colors
{
	//colorText[] =	{1,1,1,1};
	//colorDisabled[] = {	1,1,1,0.25}; //Text color if control is disabled (via ctrlEnable)
	colorBackground[] = {0, 0, 0, 0.2}; //Mouse pointer NOT over button
	//colorBackgroundDisabled[] = {0,0,0,0.5}; //Background color if control is disabled
	colorBackgroundActive[] ={0,0,0,0.5}; //Background color if "active" (i.e. mouse pointer is over it).

	//Alternating background color. While the control has focus (but without the mouse pointer being over it) the background will cycle between 'colorFocused' and 'colorBackground'. If both are the same, then the color will be steady.
	colorFocused[] ={0, 0, 0, 0.2};

	colorShadow[] ={0,0,0,0};
	colorBorder[] ={0,0,0,1};

	//Style: left alignment
	style = ST_LEFT;
};

#define RscButton RscButton_0

class RscTextMulti: RscText
{
	style = ST_MULTI;// + ST_UP + ST_LEFT;
	lineSpacing = 1;
};


//==== REINFORCEMENT REQUEST ==============================
//==== REINFORCEMENT REQUEST ==============================
//==== REINFORCEMENT REQUEST ==============================
//==== REINFORCEMENT REQUEST ==============================
//==== REINFORCEMENT REQUEST ==============================
//==== REINFORCEMENT REQUEST ==============================
//==== REINFORCEMENT REQUEST ==============================





/*


////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Sparker, v1.063, #Tyqade)
////////////////////////////////////////////////////////

class reinf_req_group_0: RscControlsGroup
{
	idc = IDC_REINF_REQ_REINF_REQ_GROUP_0;
	x = -0.5 * GUI_GRID_W + GUI_GRID_X;
	y = -0.5 * GUI_GRID_H + GUI_GRID_Y;
	w = 8.5 * GUI_GRID_W;
	h = 14 * GUI_GRID_H;
	class Controls
	{
		class IGUIBack_2201: IGUIBack
		{
			idc = IDC_REINF_REQ_IGUIBACK_2201;
			x = 0.5 * GUI_GRID_W;
			y = 0.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 12 * GUI_GRID_H;
		};
		class button_0: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_0;
			text = "Tank"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 1.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'tank' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_1: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_1;
			text = "APC"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 2.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'apc' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_2: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_2;
			text = "IFV"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 3.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'ifv' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_3: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_3;
			text = "MRAP"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 4.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'mrap' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_4: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_4;
			text = "Helicopter"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 5.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'helicopter' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_5: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_5;
			text = "Plane"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 6.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'plane' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_6: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_6;
			text = "Infantry (crew)"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 7.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'inf_crew' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_7: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_7;
			text = "Infantry (patrol)"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 8.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'inf_patrol' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_8: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_8;
			text = "Infantry (Idle)"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 9.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'inf_idle' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_9: RscButton_0
		{
			idc = IDC_REINF_REQ_BUTTON_9;
			text = "Artillery"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 10.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'artillery' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class RscButton_1610: RscButton_0
		{
			idc = IDC_REINF_REQ_RSCBUTTON_1610;
			text = "Truck"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 11.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'truck' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class checkbox_0: RscCheckbox
		{
			idc = IDC_REINF_REQ_CHECKBOX_0;
			text = "add passengers"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 0.5 * GUI_GRID_H;
			w = 1 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class RscText_1000: RscText
		{
			idc = IDC_REINF_REQ_RSCTEXT_1000;
			text = "+ infantry"; //--- ToDo: Localize;
			x = 2 * GUI_GRID_W;
			y = 0.5 * GUI_GRID_H;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
	};
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////
*/



////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Sparker, v1.063, #Tupota)
////////////////////////////////////////////////////////

class reinf_req_group_0: RscControlsGroup
{
	idc = IDC_REINF_REQ_REINF_REQ_GROUP_0;
	x = 0 * GUI_GRID_W + GUI_GRID_X;
	y = 0 * GUI_GRID_H + GUI_GRID_Y;
	w = 8.5 * GUI_GRID_W;
	h = 12.5 * GUI_GRID_H;
	class Controls
	{
		class button_0: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_0;
			text = "Tank"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 0.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'tank' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_1: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_1;
			text = "APC"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 1.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			action = "'APC' call compile preprocessfilelinenumbers 'UI\reinfRequestbuttonPressed.sqf';";
		};
		class button_2: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_2;
			text = "IFV"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 2.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class button_3: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_3;
			text = "MRAP"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 3.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class button_4: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_4;
			text = "Helicopter"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 4.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class button_5: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_5;
			text = "Plane"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 5.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class button_6: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_6;
			text = "Infantry (crew)"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 6.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class button_7: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_7;
			text = "Infantry (patrol)"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 7.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class button_8: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_8;
			text = "Infantry (Idle)"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 8.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class button_9: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_9;
			text = "Artillery"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 9.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class button_10: RscButton
		{
			idc = IDC_REINF_REQ_BUTTON_10;
			text = "Truck"; //--- ToDo: Localize;
			x = 0.5 * GUI_GRID_W;
			y = 10.5 * GUI_GRID_H;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
	};
};
class reinf_req_listbox_0: RscListbox
{
	idc = IDC_REINF_REQ_REINF_REQ_LISTBOX_0;
	text = "Select unit"; //--- ToDo: Localize;
	x = 8 * GUI_GRID_W + GUI_GRID_X;
	y = 0 * GUI_GRID_H + GUI_GRID_Y;
	w = 9.5 * GUI_GRID_W;
	h = 11 * GUI_GRID_H;
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////





/* #Bohypa
$[
	1.063,
	["REINF_REQ",[[0,0,1,1],0.025,0.04,"GUI_GRID"],0,1,0],
	[2300,"reinf_req_group_0",[2,"",["0 * GUI_GRID_W + GUI_GRID_X","0 * GUI_GRID_H + GUI_GRID_Y","8.5 * GUI_GRID_W","12.5 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1600,"button_0",[2300,"Tank",["0.5 * GUI_GRID_W","0.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1601,"button_1",[2300,"APC",["0.5 * GUI_GRID_W","1.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1602,"button_2",[2300,"IFV",["0.5 * GUI_GRID_W","2.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1603,"button_3",[2300,"MRAP",["0.5 * GUI_GRID_W","3.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1604,"button_4",[2300,"Helicopter",["0.5 * GUI_GRID_W","4.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1605,"button_5",[2300,"Plane",["0.5 * GUI_GRID_W","5.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1606,"button_6",[2300,"Infantry (crew)",["0.5 * GUI_GRID_W","6.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1607,"button_7",[2300,"Infantry (patrol)",["0.5 * GUI_GRID_W","7.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1608,"button_8",[2300,"Infantry (Idle)",["0.5 * GUI_GRID_W","8.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1609,"button_9",[2300,"Artillery",["0.5 * GUI_GRID_W","9.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1610,"button_10",[2300,"Truck",["0.5 * GUI_GRID_W","10.5 * GUI_GRID_H","8 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1500,"reinf_req_listbox_0",[2,"Select unit",["8 * GUI_GRID_W + GUI_GRID_X","0 * GUI_GRID_H + GUI_GRID_Y","9.5 * GUI_GRID_W","11 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]]
]
*/









//==== GROUP DATA ======================================
//==== GROUP DATA ======================================
//==== GROUP DATA ======================================
//==== GROUP DATA ======================================
//==== GROUP DATA ======================================
//==== GROUP DATA ======================================
//==== GROUP DATA ======================================


////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Sparker, v1.063, #Tovata)
////////////////////////////////////////////////////////

class group_data_group_0: RscControlsGroup
{
	idc = IDC_GROUP_DATA_GROUP_DATA_GROUP_0;
	x = 0.739062 * safezoneW + safezoneX;
	y = 0.075 * safezoneH + safezoneY;
	w = 0.255 * safezoneW;
	h = 0.85 * safezoneH;
	class Controls
	{
		class back_0: IGUIBack
		{
			idc = IDC_GROUP_DATA_BACK_0;
			x = 0.00531249 * safezoneW;
			y = 1.2666e-008 * safezoneH;
			w = 0.244375 * safezoneW;
			h = 0.85 * safezoneH;
		};
		class text_1: RscText
		{
			idc = IDC_GROUP_DATA_TEXT_1;
			text = "Group composition:"; //--- ToDo: Localize;
			x = 0.010625 * safezoneW;
			y = 1.2666e-008 * safezoneH;
			w = 0.23375 * safezoneW;
			h = 0.034 * safezoneH;
		};
		class text_0: RscTextMulti
		{
			idc = IDC_GROUP_DATA_TEXT_0;
			text = "Put text here"; //--- ToDo: Localize;
			x = 0.010625 * safezoneW;
			y = 0.034 * safezoneH;
			w = 0.23375 * safezoneW;
			h = 0.816 * safezoneH;
		};
	};
};
class group_data_group_1: RscControlsGroup
{
	idc = IDC_GROUP_DATA_GROUP_DATA_GROUP_1;
	x = 0.18125 * safezoneW + safezoneX;
	y = 0.891 * safezoneH + safezoneY;
	w = 0.549844 * safezoneW;
	h = 0.102 * safezoneH;
	class Controls
	{
		class group_data_button_0: RscButton
		{
			idc = IDC_GROUP_DATA_GROUP_DATA_BUTTON_0;
			text = "Get in"; //--- ToDo: Localize;
			x = 0.00796875 * safezoneW;
			y = 0.017 * safezoneH;
			w = 0.0796875 * safezoneW;
			h = 0.068 * safezoneH;
			action = "'get in' call compile preprocessfilelinenumbers 'UI\groupDataButtonPressed.sqf';";
		};
		class group_data_button_1: RscButton
		{
			idc = IDC_GROUP_DATA_GROUP_DATA_BUTTON_1;
			text = "Get out"; //--- ToDo: Localize;
			x = 0.103594 * safezoneW;
			y = 0.017 * safezoneH;
			w = 0.0796875 * safezoneW;
			h = 0.068 * safezoneH;
			action = "'get out' call compile preprocessfilelinenumbers 'UI\groupDataButtonPressed.sqf';";
		};
		class group_data_button_2: RscButton
		{
			idc = IDC_GROUP_DATA_GROUP_DATA_BUTTON_2;
			text = "Smth else"; //--- ToDo: Localize;
			x = 0.199219 * safezoneW;
			y = 0.017 * safezoneH;
			w = 0.0796875 * safezoneW;
			h = 0.068 * safezoneH;
		};
		class group_data_button_3: RscButton
		{
			idc = IDC_GROUP_DATA_GROUP_DATA_BUTTON_2;
			text = "Smth else"; //--- ToDo: Localize;
			x = 0.294844 * safezoneW;
			y = 0.017 * safezoneH;
			w = 0.0796875 * safezoneW;
			h = 0.068 * safezoneH;
		};
	};
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////


/* #Tovata
$[
	1.063,
	["group_data",[[0,0,1,1],0.025,0.04,"GUI_GRID"],0,1,0],
	[2300,"group_data_group_0",[1,"",["0.739062 * safezoneW + safezoneX","0.075 * safezoneH + safezoneY","0.255 * safezoneW","0.85 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[2200,"back_0",[2300,"",["0.00531249 * safezoneW","1.2666e-008 * safezoneH","0.244375 * safezoneW","0.85 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1000,"text_1",[2300,"Group composition:",["0.010625 * safezoneW","1.2666e-008 * safezoneH","0.23375 * safezoneW","0.034 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1001,"text_0",[2300,"Put text here",["0.010625 * safezoneW","0.034 * safezoneH","0.23375 * safezoneW","0.816 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[2301,"group_data_group_1",[1,"",["0.18125 * safezoneW + safezoneX","0.891 * safezoneH + safezoneY","0.549844 * safezoneW","0.102 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1604,"group_data_button_0",[2301,"Get in",["0.00796875 * safezoneW","0.017 * safezoneH","0.0796875 * safezoneW","0.068 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1605,"group_data_button_1",[2301,"Get out",["0.103594 * safezoneW","0.017 * safezoneH","0.0796875 * safezoneW","0.068 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1606,"group_data_button_2",[2301,"Smth else",["0.199219 * safezoneW","0.017 * safezoneH","0.0796875 * safezoneW","0.068 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1607,"group_data_button_3",[2301,"Smth else",["0.294844 * safezoneW","0.017 * safezoneH","0.0796875 * safezoneW","0.068 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]]
]
*/








//==== GROUP CONTROL ==================================
//==== GROUP CONTROL ==================================
//==== GROUP CONTROL ==================================
//==== GROUP CONTROL ==================================
//==== GROUP CONTROL ==================================
//==== GROUP CONTROL ==================================

class groupControlDisplay {
    idd = IDC_GROUP_CONTROL_DISPLAY;                   // set to -1, if don't require a unique ID
    movingEnable = 1;           // the dialog can be moved with the mouse
    enableSimulation = 1;       // freeze the game
    controlsBackground[] = { }; // not necessary
    objects[] = { };            // not necessary
    class controls
    {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Sparker, v1.063, #Vyhoqe)
		////////////////////////////////////////////////////////

		class group_control_group_0: RscControlsGroup
		{
			idc = IDC_GROUP_CONTROL_GROUP_CONTROL_GROUP_0;
			x = 0.1;
			y = 0.12;
			w = 0.8;
			h = 0.68;
			class Controls
			{
				class IGUIBack_2200: IGUIBack
				{
					idc = IDC_GROUP_CONTROL_IGUIBACK_2200;
					x = 0.0125;
					y = 0.02;
					w = 0.775;
					h = 0.64;
				};
				class group_control_button_0: RscButton
				{
					idc = IDC_GROUP_CONTROL_GROUP_CONTROL_BUTTON_0;
					text = "Get in"; //--- ToDo: Localize;
					x = 0.025;
					y = 0.08;
					w = 0.125;
					h = 0.08;
					action = "'get in' call compile preprocessfilelinenumbers 'UI\groupDataButtonPressed.sqf';";
				};
				class group_control_button_1: RscButton
				{
					idc = IDC_GROUP_CONTROL_GROUP_CONTROL_BUTTON_1;
					text = "Get out"; //--- ToDo: Localize;
					x = 0.025;
					y = 0.18;
					w = 0.125;
					h = 0.08;
					action = "'get out' call compile preprocessfilelinenumbers 'UI\groupDataButtonPressed.sqf';";
				};
				class group_control_button_2: RscButton
				{
					idc = IDC_GROUP_CONTROL_GROUP_CONTROL_BUTTON_2;
					text = "What?"; //--- ToDo: Localize;
					x = 0.025;
					y = 0.28;
					w = 0.125;
					h = 0.08;
				};
				class RscText_1002: RscText
				{
					idc = IDC_GROUP_CONTROL_RSCTEXT_1002;
					text = "High Command Control Panel"; //--- ToDo: Localize;
					x = 0.025;
					y = 0.02;
					w = 0.75;
					h = 0.04;
				};
			};
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
    };
};




/* #Badino
$[
	1.063,
	["group_control",[[0,0,1,1],0.025,0.04,"GUI_GRID"],0,1,0],
	[2300,"group_control_group_0",[0,"",[0.1,0.12,0.8,0.68],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[2200,"",[2300,"",[0.0125,0.02,0.775,0.64],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1603,"group_control_button_0",[2300,"Get in",[0.025,0.08,0.125,0.08],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1600,"group_control_button_1",[2300,"Get out",[0.025,0.18,0.125,0.08],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1601,"group_control_button_2",[2300,"What?",[0.025,0.28,0.125,0.08],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1002,"",[2300,"High Command Control Panel",[0.025,0.02,0.75,0.04],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]]
]
*/

#undef RscButton