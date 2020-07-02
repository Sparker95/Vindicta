#include "defineCommon.inc"

params ["_vehicle"];

pr _wheels = configFile >> "CfgVehicles" >> typeOf _vehicle >> "Wheels";


if !(isClass _wheels) exitWith {[]};


(getAllHitPointsDamage _vehicle) params ["_hitPoints", "_hitPointSelections"];


_wheels = "true" configClasses _wheels;

pr _wheelHitPointsAndSelections = [];

{
    pr _wheelName = configName _x;
    pr _wheelCenter = getText (_x >> "center");
    pr _wheelBone = getText (_x >> "boneName");
    pr _wheelBoneNameResized = _wheelBone select [0, 9];

    pr _wheelHitPoint = "";
    pr _wheelHitPointSelection = "";

    {
        if ((_wheelBoneNameResized != "") && {_x find _wheelBoneNameResized == 0}) exitWith {
            _wheelHitPoint = _hitPoints select _forEachIndex;
            _wheelHitPointSelection = _hitPointSelections select _forEachIndex;
        };
    } forEach _hitPointSelections;


    if (_vehicle isKindOf "Car") then {

        if (_wheelHitPoint == "") then {
            pr _wheelCenterPos = _vehicle selectionPosition _wheelCenter;
            if (_wheelCenterPos isEqualTo [0,0,0]) exitWith {};


            pr _bestDist = 99;
            pr _bestIndex = -1;
            {
                if (_x != "") then {
                    if ((toLower (_hitPoints select _forEachIndex)) in ["hitengine", "hitfuel", "hitbody"]) exitWith {};
                    pr _xPos = _vehicle selectionPosition _x;
                    if (_xPos isEqualTo [0,0,0]) exitWith {};
                    pr _xDist = _wheelCenterPos distance _xPos;
                    if (_xDist < _bestDist) then {
                        _bestIndex = _forEachIndex;
                        _bestDist = _xDist;
                    };
                };
            } forEach _hitPointSelections;


            if (_bestIndex != -1) then {
                _wheelHitPoint = _hitPoints select _bestIndex;
                _wheelHitPointSelection = _hitPointSelections select _bestIndex;
                
            };
        };
    };

    if ((_wheelHitPoint != "") && {_wheelHitPointSelection != ""}) then {
        _wheelHitPointsAndSelections pushBack [_wheelHitPoint,_wheelHitPointSelection,_wheelCenter,TYPE_WHEEL,"Wheel"];
    };
} forEach _wheels;

_wheelHitPointsAndSelections;