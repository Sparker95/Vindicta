steal_weapon = {	
	params["_unit", "_weapon"];
	_groundWeaponHolder = "GroundWeaponHolder" createVehicle [0,0,0];
	_groundWeaponHolder addItemCargo ["None", 1];
	_groundWeaponHolder setPos (position _unit);
	 
	_unit action ["PutWeapon",_groundWeaponHolder,_unit];
};


[] spawn{
	params["_unit","_disarm"];
	_unit = cursorObject;
	_disarm = player;


	_currentWeapon = currentWeapon _unit;
	_animation = call{
		if(_currentWeapon isequalto primaryWeapon _unit)exitWith{
			"amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" //primary
		};
		if(_currentWeapon isequalto secondaryWeapon _unit)exitWith{
			"amovpercmstpsraswlnrdnon_ainvpercmstpsraswlnrdnon_putdown" //launcher
		};
		if(_currentWeapon isequalto handgunWeapon _unit)exitWith{
			"amovpercmstpsraswpstdnon_ainvpercmstpsraswpstdnon_putdown" //pistol
		};
		if(_currentWeapon isequalto binocular _unit)exitWith{
			"amovpercmstpsoptwbindnon_ainvpercmstpsoptwbindnon_putdown" //bino
		};
		"amovpercmstpsnonwnondnon_ainvpercmstpsnonwnondnon_putdown" //non
	};
	
	waitUntil{
		_pos = (eyeDirection _disarm vectorMultiply 1.6) vectorAdd getpos _disarm;
		_unit doMove _pos;
		_unit dotarget _disarm;
		_pos_disarm = getpos _disarm;
		sleep 0.5;
		
		diag_log ["sleep",(_pos_disarm distance (getpos _disarm))];
		
		(_pos_disarm distance (getpos _disarm))<0.1 && {_pos distance getpos _unit < 0.5};
	};
	sleep 0.1;
	_unit playMove _animation;
	waitUntil {animationState _unit == _animation};
	waitUntil {animationState _unit != _animation};
	
	

	//removeWeapon
	_disarm removeWeapon currentWeapon _disarm;
	
	sleep 1;
	hint "Now move away";
	
	sleep 3;
	if(_unit distance _disarm<4)then{
		sleep 1;
		hint "Further or I shoot you";
	}
	
	sleep 3;
	
	if(_unit distance _disarm<4)then{
		_disarm addRating -20000;
	}else{
		_unit doWatch objNull;
	};

};



_unit = cursorObject;
_disarm = player;
