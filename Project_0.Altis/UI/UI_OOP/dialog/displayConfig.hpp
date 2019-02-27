class DisplayConfig {
	idd = 1000;
	name= "DisplayConfig";
	movingEnable = false;
	enableSimulation = true;
	onLoad = "with missionNamespace do{['new', _this select 0] call oo_DisplayConfig;};";
	onUnload = "with missionNamespace do{['static', ['deconstructor',nil]] call oo_DisplayConfig;};";
	class controlsBackground {
		class OOP_MainLayer_100_100 : OOP_MainLayer {
			idc = 100;
			x = -61.9078 * pixelGrid * pixelW;
			y = -28.35 * pixelGrid * pixelH;
			w = 210.691 * pixelGrid * pixelW;
			h = 125.95 * pixelGrid * pixelH;
			class controls{
				class OOP_Picture_101_101: OOP_Picture {
					idc = 101;
					x = 73.7417 * pixelGrid * pixelW;
					y = 47.861 * pixelGrid * pixelH;
					w = 63.2072 * pixelGrid * pixelW;
					h = 30.228 * pixelGrid * pixelH;
					text = "#(rgb,8,8,3)color(0.2,0.2,0.2,0.8)";
				};
				class OOP_Text_102_102: OOP_Text {
					idc = 102;
					x = 73.7417 * pixelGrid * pixelW;
					y = 47.861 * pixelGrid * pixelH;
					w = 63.2072 * pixelGrid * pixelW;
					h = 5.03801 * pixelGrid * pixelH;
					text = "Config";
					colorBackground[] = {0, 0.96, 0.17, 1};
				};
				class OOP_TextRight_103_103: OOP_TextRight {
					idc = 103;
					x = 79.6336 * pixelGrid * pixelW;
					y = 56.1675 * pixelGrid * pixelH;
					w = 13.1682 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Name:";
				};
				class OOP_TextRight_104_104: OOP_TextRight {
					idc = 104;
					x = 79.8834 * pixelGrid * pixelW;
					y = 61.6635 * pixelGrid * pixelH;
					w = 13.1682 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Display ID:";
				};
				class editName_105: OOP_Edit {
					idc = 105;
					x = 94.8108 * pixelGrid * pixelW;
					y = 55.418 * pixelGrid * pixelH;
					w = 21.0691 * pixelGrid * pixelW;
					h = 3.7785 * pixelGrid * pixelH;
				};
				class editIDD_106: OOP_Edit {
					idc = 106;
					x = 94.8108 * pixelGrid * pixelW;
					y = 60.456 * pixelGrid * pixelH;
					w = 21.0691 * pixelGrid * pixelW;
					h = 3.7785 * pixelGrid * pixelH;
				};
				class btnValider_107: OOP_Button {
					idc = 107;
					x = 115.88 * pixelGrid * pixelW;
					y = 68.013 * pixelGrid * pixelH;
					w = 10.5345 * pixelGrid * pixelW;
					h = 5.03799 * pixelGrid * pixelH;
					text = "OK";
					action = "['static', ['btnAction_btnValider', nil]] call oo_DisplayConfig;";
				};
				class btnClose_108: OOP_Button {
					idc = 108;
					x = 86.9099 * pixelGrid * pixelW;
					y = 68.013 * pixelGrid * pixelH;
					w = 10.5345 * pixelGrid * pixelW;
					h = 5.03799 * pixelGrid * pixelH;
					text = "Close";
					action = "['static', ['btnAction_btnClose', nil]] call oo_DisplayConfig;";
				};
			};
		};
	};
	class controls {};
};

/*
["DisplayConfig",1000,[[[["73.7417 * pixelGrid * pixelW","47.861 * pixelGrid * pixelH","63.2072 * pixelGrid * pixelW","30.228 * pixelGrid * pixelH"],"#(rgb,8,8,3)color(0.2,0.2,0.2,0.8)","","","OOP_Picture",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["73.7417 * pixelGrid * pixelW","47.861 * pixelGrid * pixelH","63.2072 * pixelGrid * pixelW","5.03801 * pixelGrid * pixelH"],"Config","","","OOP_Text",true,[],[-1,-1,-1,-1],[0,0.96,0.17,1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["79.6336 * pixelGrid * pixelW","56.1675 * pixelGrid * pixelH","13.1682 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Name:","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["79.8834 * pixelGrid * pixelW","61.6635 * pixelGrid * pixelH","13.1682 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Display ID:","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["94.8108 * pixelGrid * pixelW","55.418 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","3.7785 * pixelGrid * pixelH"],"","editName","","OOP_Edit",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["94.8108 * pixelGrid * pixelW","60.456 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","3.7785 * pixelGrid * pixelH"],"","editIDD","","OOP_Edit",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["115.88 * pixelGrid * pixelW","68.013 * pixelGrid * pixelH","10.5345 * pixelGrid * pixelW","5.03799 * pixelGrid * pixelH"],"OK","btnValider","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["86.9099 * pixelGrid * pixelW","68.013 * pixelGrid * pixelH","10.5345 * pixelGrid * pixelW","5.03799 * pixelGrid * pixelH"],"Close","btnClose","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]]
*/
