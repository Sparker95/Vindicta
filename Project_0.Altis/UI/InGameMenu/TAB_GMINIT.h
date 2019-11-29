class TAB_GMINIT : MUI_GROUP_ABS
{
	
	x = 0;
	y = 0;
	w = 0.7;
	h = 0.9;

	class Controls
	{
		class STATIC_GAME_MODE : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.02000013;
			y = 0.0700001;
			w = 0.38000013;
			h = 0.04000007;
			text = "Game Mode:";
			style = 0;
		};
		class STATIC_ENEMY_FORCE_PERCENTAGE : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.02000014;
			y = 0.22000022;
			w = 0.38000013;
			h = 0.04000007;
			text = "Enemy force percentage:";
			style = ST_LEFT;
		};
		class STATIC_MILITARY_FACTION : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.02000014;
			y = 0.12000019;
			w = 0.38000007;
			h = 0.04000007;
			text = "Military faction:";
			style = ST_LEFT;
		};
		class STATIC_CAMPAIGN_NAME : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.02000013;
			y = 0.0200001;
			w = 0.38000013;
			h = 0.04000007;
			text = "Campaign Name:";
			style = ST_LEFT;
		};
		class STATIC_POLICE_FACTION : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.02000014;
			y = 0.17000022;
			w = 0.38000007;
			h = 0.04000007;
			text = "Police faction:";
			style = ST_LEFT;
		};
		class TAB_GMINIT_EDIT_ENEMY_PERCENTAGE : MUI_EDIT_ABS 
		{
			idc = -1;
			x = 0.41000015;
			y = 0.22000015;
			w = 0.27000009;
			h = 0.04000005;
			text = "100";
			style = 0;
		};
		class TAB_GMINIT_EDIT_CAMPAIGN_NAME : MUI_EDIT_ABS 
		{
			idc = -1;
			x = 0.41000015;
			y = 0.02000018;
			w = 0.27000009;
			h = 0.04000005;
			text = "No Name";
			style = 0;
		};
		class TAB_GMINIT_COMBO_GAME_MODE : MUI_COMBOBOX_ABS 
		{
			idc = -1;
			x = 0.41000046;
			y = 0.07000031;
			w = 0.27000013;
			h = 0.0400001;
			text = "Civil War";			
		};
		class TAB_GMINIT_COMBO_ENEMY_FACTION : MUI_COMBOBOX_ABS 
		{
			idc = -1;
			x = 0.41000046;
			y = 0.12000033;
			w = 0.27000013;
			h = 0.0400001;
			text = "AAF";			
		};
		class TAB_GMINIT_COMBO_POLICE_FACTION : MUI_COMBOBOX_ABS 
		{
			idc = -1;
			x = 0.41000046;
			y = 0.17000036;
			w = 0.27000013;
			h = 0.0400001;
			text = "Standard";
		};
		
	};
	
};
