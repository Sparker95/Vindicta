params ["_posWorld"];
_array = [
	["a3\weapons_f\ammoboxes\bags\backpack_tortila.p3d",[-0.0581902,0.0182898,-0.167051],[-0.0103505,-0.0471614,0.998834],[0.865388,-0.500887,-0.0146824]],
	["a3\weapons_f\ammoboxes\bags\backpack_gorod.p3d",[0.188026,0.372782,-0.271856],[-0.178392,0.665672,0.724608],[0.146401,-0.710267,0.68854]],
	["a3\weapons_f\ammoboxes\bags\backpack_compact.p3d",[0.430233,0.0684487,-0.275234],[0.738951,0.351096,0.575051],[-0.546592,-0.186641,0.816335]],
	["a3\structures_f\items\electronics\mobilephone_smart_f.p3d",[0.0748664,0.0143836,0.246589],[-0.182304,-0.970829,0.155745],[0,0.158399,0.987375]],
	["a3\structures_f\items\electronics\portablelongrangeradio_f.p3d",[0.179969,0.198466,0.265633],[-0.763481,0.645831,0],[0,0,1]],
	["a3\props_f_orange\humanitarian\supplies\foodsack_01_full_f.p3d",[-0.233117,0.17161,0.099926],[-0.22017,-0.975462,0],[0,0,1]],
	["a3\structures_f_epa\items\food\bakedbeans_f.p3d",[0.00784981,0.505594,0.0502162],[0,1,0],[0,0,1]],
	["a3\structures_f_epa\items\food\bakedbeans_f.p3d",[-0.096032,0.524637,0.0502162],[-0.792173,0.610297,0],[0,0,1]],
	["a3\structures_f\items\electronics\survivalradio_f.p3d",[0.25785,-0.0783899,0.275459],[-0.0925049,-0.35547,0.930099],[0.209038,0.906354,0.367185]],
	["a3\props_f_orange\humanitarian\supplies\waterbottle_01_pack_f.p3d",[-0.056115,0.208231,0.242911],[0.120264,-0.992726,-0.00558023],[-0.867661,-0.107841,0.485318]]];

private _posBaseWorld = _posWorld;
{
	_x params ["_model", "_posOffset", "_vectorDir", "_vectorUp"];
	private _object = createSimpleObject [_model, _posOffset vectorAdd _posBaseWorld, false];
	_object setVectorDirAndUp [_vectorDir, _vectorUp];
} forEach _array;