
jn_forceFirstPerson = false;
jn_forceFirstPersonBase = false;
jn_forceFirstPersonVehicle = false;


jn_fnc_forceFirstPerson = {

	if(!jn_forceFirstPerson && {groupId group player find "1st" == -1})exitWith{};

	if!(
		(!jn_forceFirstPersonVehicle && {!(vehicle player isEqualTo player)}) ||
		{!jn_forceFirstPersonBase && {player distance fuego < 100}}
	)then{
		[]spawn{
			sleep 0.001;
			vehicle player switchCamera "INTERNAL";
		};
	};
};

findDisplay 46 displayAddEventHandler ["KeyDown", {
	params["_display","_key"];
	if(_key in actionKeys "personView")then{
		call jn_fnc_forceFirstPerson;
	};
}];

[] spawn {
	while{true}do{
		sleep 1;
		if!(cameraView in ["INTERNAL","GUNNER"])then{
			call jn_fnc_forceFirstPerson;
		};
	};
};

jn_wasFirstpersonInCar = false;
player addEventHandler ["GetOutMan",{
	jn_wasFirstpersonInCar = cameraView in ["INTERNAL","GUNNER"];
	call jn_fnc_forceFirstPerson;
}];

player addEventHandler ["GetInMan",{
	if(!jn_wasFirstpersonInCar)then{
		vehicle player switchCamera "EXTERNAL";
	};
}];
