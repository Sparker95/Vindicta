    class UIUndercoverDebug {
        idd = 1000;
        duration = 100000000;
        name= "UIUndercoverDebug";
        movingEnable = false;
        enableSimulation = true;
        onLoad = "with missionNamespace do{UIUndercoverDebug = ['new', _this select 0] call oo_UIUndercoverDebug;};";
        onUnload = "with missionNamespace do{['delete',UIUndercoverDebug] call oo_UIUndercoverDebug;};";
        class controlsBackground {
            class OOP_MainLayer_100_100 : OOP_MainLayer {
                idc = 100;
                x = -62.6667 * pixelGrid * pixelW;
                y = -27 * pixelGrid * pixelH;
                w = 213.333 * pixelGrid * pixelW;
                h = 120 * pixelGrid * pixelH;
                class controls{
                    class OOP_Text_101_Susp_101: OOP_Text {
                        idc = 101;
                        x = 0.264 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 21.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Susp: 0.2346386";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_SuspGear_102: OOP_Text {
                        idc = 102;
                        x = 21.3333 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 21.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Gear Susp: 0.236275";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_Wanted_103: OOP_Text {
                        idc = 103;
                        x = 133.333 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 13.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Wanted: false";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_Suspicious_104: OOP_Text {
                        idc = 104;
                        x = 146.667 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 16 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Suspicious: false";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_Seen_105: OOP_Text {
                        idc = 105;
                        x = 162.667 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 13.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Seen: false";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_Distance_106: OOP_Text {
                        idc = 106;
                        x = 162.667 * pixelGrid * pixelW;
                        y = 2.4 * pixelGrid * pixelH;
                        w = 32 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Distance Nearest Enemy: 135.826478";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_TimeUnseen_107: OOP_Text {
                        idc = 107;
                        x = 176 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 18.6667 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Time Unseen: 120";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_Captive_108: OOP_Text {
                        idc = 108;
                        x = 194.667 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 18.6667 * pixelGrid * pixelW;
                        h = 4.8 * pixelGrid * pixelH;
                        text = "Not captive";
                        colorText[] = {0.61, 0.81, 1, 1};
                        colorBackground[] = {0.8, 0.04, 0.14, 1};
                        tooltipColorText[] = {0.61, 0.81, 1, 1};
                    };
                    class OOP_Text_101_InVeh_110: OOP_Text {
                        idc = 110;
                        x = 0.264 * pixelGrid * pixelW;
                        y = 2.4 * pixelGrid * pixelH;
                        w = 21.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "In vehicle: false";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_InVehMil_111: OOP_Text {
                        idc = 111;
                        x = 21.3333 * pixelGrid * pixelW;
                        y = 2.4 * pixelGrid * pixelH;
                        w = 21.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "In military vehicle: false";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_SuspVeh_112: OOP_Text {
                        idc = 112;
                        x = 42.6667 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 21.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Vehicle Susp: 0.236275";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_SuspGear_0_0_113: OOP_Text {
                        idc = 113;
                        x = 64 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 21.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Vehicle Susp: 0.236275";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_InVehCiv_114: OOP_Text {
                        idc = 114;
                        x = 42.6667 * pixelGrid * pixelW;
                        y = 2.4 * pixelGrid * pixelH;
                        w = 21.3333 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "In civilian vehicle: false";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_BodyExp_115: OOP_Text {
                        idc = 115;
                        x = 85.3333 * pixelGrid * pixelW;
                        y = 0.198 * pixelGrid * pixelH;
                        w = 24 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Body Exposure: 0.23627579";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_LastSpottedTimes_116: OOP_Text {
                        idc = 116;
                        x = 64 * pixelGrid * pixelW;
                        y = 2.4 * pixelGrid * pixelH;
                        w = 98.6667 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Last Spotted Times: [137.83, 136.99, 132.91, 139.54, 142.41, 132.90]";
                        colorBackground[] = {0, 0, 0, 1};
                    };
                    class OOP_Text_101_Blank_117: OOP_Text {
                        idc = 117;
                        x = 0.264 * pixelGrid * pixelW;
                        y = 4.8 * pixelGrid * pixelH;
                        w = 213.069 * pixelGrid * pixelW;
                        h = 2.4 * pixelGrid * pixelH;
                        text = "Add more text here...";
                        colorText[] = {0, 0, 0, 1};
                        colorBackground[] = {1, 1, 1, 1};
                        tooltipColorText[] = {0, 0, 0, 1};
                    };
                };
            };
        };
        class controls {};
    };