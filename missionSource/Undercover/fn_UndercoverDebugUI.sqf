/*
Displays a number of variables on screen for debugging
*/


		params["_unit"];
		systemChat "Loading undercover debug UI.";
		

		private _display = (findDisplay 46);

		// TEXT BOX ORDER IN READING DIRECTION: TOP LEFT TO TOP RIGHT, THEN BOTTOM LEFT TO BOTTOM RIGHT

		// TOP LEFT
		private _panel = _display ctrlCreate ["RscText", -1];
		_panel ctrlSetPosition [-0.7, -0.4, 0.4, 0.05];
		_panel ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel ctrlSetTextColor [1, 1, 1, 1];
		_panel ctrlSetFont "PuristaBold";
		_panel ctrlSetText "UNDEFINED";
		_panel ctrlCommit 0;

		private _panel2 = _display ctrlCreate ["RscText", -1];
		_panel2 ctrlSetPosition [-0.4, -0.4, 0.4, 0.05];
		_panel2 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel2 ctrlSetTextColor [1, 1, 1, 1];
		_panel2 ctrlSetFont "PuristaBold";
		_panel2 ctrlSetText "UNDEFINED";
		_panel2 ctrlCommit 0;

		private _panel3 = _display ctrlCreate ["RscText", -1];
		_panel3 ctrlSetPosition [-0.2, -0.4, 0.4, 0.05];
		_panel3 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel3 ctrlSetTextColor [1, 1, 1, 1];
		_panel3 ctrlSetFont "PuristaBold";
		_panel3 ctrlSetText "UNDEFINED";
		_panel3 ctrlCommit 0;

		private _panel4 = _display ctrlCreate ["RscText", -1];
		_panel4 ctrlSetPosition [0.0, -0.4, 0.4, 0.05];
		_panel4 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel4 ctrlSetTextColor [1, 1, 1, 1];
		_panel4 ctrlSetFont "PuristaBold";
		_panel4 ctrlSetText "UNDEFINED";
		_panel4 ctrlCommit 0;

		private _panel5 = _display ctrlCreate ["RscText", -1];
		_panel5 ctrlSetPosition [0.25, -0.4, 0.4, 0.05];
		_panel5 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel5 ctrlSetTextColor [1, 1, 1, 1];
		_panel5 ctrlSetFont "PuristaBold";
		_panel5 ctrlSetText "UNDEFINED";
		_panel5 ctrlCommit 0;

		private _panel6 = _display ctrlCreate ["RscText", -1];
		_panel6 ctrlSetPosition [0.5, -0.4, 0.4, 0.05];
		_panel6 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel6 ctrlSetTextColor [1, 1, 1, 1];
		_panel6 ctrlSetFont "PuristaBold";
		_panel6 ctrlSetText "UNDEFINED";
		_panel6 ctrlCommit 0;

		private _panel8 = _display ctrlCreate ["RscText", -1];
		_panel8 ctrlSetPosition [0.73, -0.4, 0.4, 0.05];
		_panel8 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel8 ctrlSetTextColor [1, 1, 1, 1];
		_panel8 ctrlSetFont "PuristaBold";
		_panel8 ctrlSetText "UNDEFINED";
		_panel8 ctrlCommit 0;

		private _panel7 = _display ctrlCreate ["RscText", -1];
		_panel7 ctrlSetPosition [1.5, -0.4, 0.4, 0.05];
		_panel7 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel7 ctrlSetTextColor [1, 1, 1, 1];
		_panel7 ctrlSetFont "PuristaBold";
		_panel7 ctrlSetText "UNDEFINED";
		_panel7 ctrlCommit 0;

		private _panel9 = _display ctrlCreate ["RscText", -1];
		_panel9 ctrlSetPosition [-0.7, -0.35, 0.4, 0.05];
		_panel9 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel9 ctrlSetTextColor [1, 1, 1, 1];
		_panel9 ctrlSetFont "PuristaBold";
		_panel9 ctrlSetText "UNDEFINED";
		_panel9 ctrlCommit 0;

		private _panel10 = _display ctrlCreate ["RscText", -1];
		_panel10 ctrlSetPosition [-0.4, -0.35, 0.4, 0.05];
		_panel10 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel10 ctrlSetTextColor [1, 1, 1, 1];
		_panel10 ctrlSetFont "PuristaBold";
		_panel10 ctrlSetText "UNDEFINED";
		_panel10 ctrlCommit 0;

		private _panel11 = _display ctrlCreate ["RscText", -1];
		_panel11 ctrlSetPosition [-0.2, -0.35, 0.4, 0.05];
		_panel11 ctrlSetBackgroundColor [0.0, 0.0, 0.0, 1];
		_panel11 ctrlSetTextColor [1, 1, 1, 1];
		_panel11 ctrlSetFont "PuristaBold";
		_panel11 ctrlSetText "UNDEFINED";
		_panel11 ctrlCommit 0;

 

		while { true } do {

			sleep 0.2;

			private _var = _unit getVariable "suspicion";
			if (isNil "_var") then { _var = "undefined"};
			_var = str _var;
			_var = formatText["Suspicion: %1", _var];
			_var = str _var;
			_panel ctrlSetText _var;
			_panel ctrlCommit 0;

			private _var2 = _unit getVariable "suspGear";
			if (isNil "_var2") then { _var2 = "undefined"};
			_var2 = str _var2;
			_var2 = formatText["Susp. Gear: %1", _var2];
			_var2 = str _var2;
			_panel2 ctrlSetText _var2;
			_panel2 ctrlCommit 0;

			private _var3 = _unit getVariable "bWanted";
			if (isNil "_var3") then { _var3 = "undefined"};
			_var3 = str _var3;
			_var3 = formatText["Wanted: %1", _var3];
			_var3 = str _var3;
			_panel3 ctrlSetText _var3;
			_panel3 ctrlCommit 0;

			private _var4 = _unit getVariable "timeUnseen";
			if (isNil "_var4") then { _var4 = "undefined"};
			_var4 = str _var4;
			_var4 = formatText["Time unseen: %1", _var4];
			_var4 = str _var4;
			_panel4 ctrlSetText _var4;
			_panel4 ctrlCommit 0;

			private _var5 = _unit getVariable "bSuspicious";
			if (isNil "_var5") then { _var5 = "undefined"};
			_var5 = str _var5;
			_var5 = formatText["Suspicious: %1", _var5];
			_var5 = str _var5;
			_panel5 ctrlSetText _var5;
			_panel5 ctrlCommit 0;

			private _var6 = _unit getVariable "bSeen";
			if (isNil "_var6") then { _var6 = "undefined"};
			_var6 = str _var6;
			_var6 = formatText["Spotted: %1", _var6];
			_var6 = str _var6;
			_panel6 ctrlSetText _var6;
			_panel6 ctrlCommit 0;

			private _var8 = _unit getVariable "nearestEnemyDist";
			if (isNil "_var8") then { _var8 = "undefined"};
			_var8 = str _var8;
			_var8 = formatText["Distance nearest unit: %1", _var8];
			_var8 = str _var8;
			_panel8 ctrlSetText _var8;
			_panel8 ctrlCommit 0;

			private _var9 = _unit getVariable "bInMilVeh";
			if (isNil "_var9") then { _var9 = "undefined"};
			_var9 = str _var9;
			_var9 = formatText["Mil veh: %1", _var9];
			_var9 = str _var9;
			_panel9 ctrlSetText _var9;
			_panel9 ctrlCommit 0;

			private _var10 = _unit getVariable "bInVeh";
			if (isNil "_var10") then { _var10 = "undefined"};
			_var10 = str _var10;
			_var10 = formatText["In vehicle: %1", _var10];
			_var10 = str _var10;
			_panel10 ctrlSetText _var10;
			_panel10 ctrlCommit 0;

			private _var11 = _unit getVariable "suspGearVeh";
			if (isNil "_var11") then { _var11 = "undefined"};
			_var11 = str _var11;
			_var11 = formatText["SuspGearVeh: %1", _var11];
			_var11 = str _var11;
			_panel11 ctrlSetText _var11;
			_panel11 ctrlCommit 0;

			if (captive _unit) then { 
				_panel7 ctrlSetText "INCOGNITO";
				_panel7 ctrlSetBackgroundColor [0.3, 1.0, 0.3, 1];
				_panel7 ctrlSetTextColor [0, 0, 0, 1];
				_panel7 ctrlCommit 0;
			} else { 
				_panel7 ctrlSetText "OVERT";
				_panel7 ctrlSetTextColor [1, 1, 1, 1];
				_panel7 ctrlSetBackgroundColor [1.0, 0.3, 0.3, 1];
				_panel7 ctrlCommit 0;
			 
			};
		};

