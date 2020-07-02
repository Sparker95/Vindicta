params [["_num", 0, [0]]];

if (count t_classnames_array <= _num || _num < 0) then {
	diag_log format ["numberToClassname: error: can't resolve class name from ID: %1", _num];
	""
} else {
	t_classnames_array select _num
};

