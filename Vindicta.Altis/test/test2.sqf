call {
    diag_log format["CLASS %1 <- %2", "MessageReceiverEx", "MessageReceiver"];
    private _oop_classNameStr = "MessageReceiverEx";
    missionNamespace setVariable[("o_" + (_oop_classNameStr) + "_spm_" + ("nextID")), 0];
    private _oop_memList = [];
    private _oop_staticMemList = [];
    private _oop_parents = [];
    private _oop_methodList = [];
    private _oop_newMethodList = [];
    if ("MessageReceiver" != "") then {
        if (!(["MessageReceiver", "c:\Users\billw\Documents\Arma 3\mpmissions\Vindicta\Vindicta.Altis\common.h", 513] call OOP_assert_class)) then {
            private _msg = format["Invalid base class for %1: %2", "MessageReceiverEx", "MessageReceiver"];
            private _o_str = format["[%1.%2] ERROR: %3",
                if (!(isNil "_thisObject")) then {
                    _thisObject
                } else {
                    if (!(isNil "_thisClass")) then {
                        _thisClass
                    } else {
                        if (!(isNil "_oop_logScope")) then {
                            _oop_logScope
                        } else {
                            "NoClass"
                        }
                    }
                }, "fnc", format["Failure: %1", _msg]];
            diag_log _o_str;;
            ade_dumpCallstack;
            throw ["c:\Users\billw\Documents\Arma 3\mpmissions\Vindicta\Vindicta.Altis\common.h", 768, _msg];
        };
        _oop_parents = +(missionNamespace getVariable("o_" + ("MessageReceiver") + "_spm_" + ("parents")));
        _oop_parents pushBackUnique "MessageReceiver";
        _oop_memList = +(missionNamespace getVariable("o_" + ("MessageReceiver") + "_spm_" + ("memList")));
        _oop_staticMemList = +(missionNamespace getVariable("o_" + ("MessageReceiver") + "_spm_" + ("staticMemList")));
        _oop_methodList = +(missionNamespace getVariable("o_" + ("MessageReceiver") + "_spm_" + ("methodList")));
        private _oop_topParent = _oop_parents select((count _oop_parents) - 1); {
            private _oop_methodCode = (missionNameSpace getVariable((_oop_topParent) + "_fnc_" + (_x)));
            missionNamespace setVariable[(("MessageReceiverEx") + "_fnc_" + (_x)), _oop_methodCode];
        }
        forEach(_oop_methodList - ["new", "delete", "copy"]);
    };
    missionNamespace setVariable[("o_" + (_oop_classNameStr) + "_spm_" + ("parents")), _oop_parents];
    missionNamespace setVariable[("o_" + (_oop_classNameStr) + "_spm_" + ("memList")), _oop_memList];
    missionNamespace setVariable[("o_" + (_oop_classNameStr) + "_spm_" + ("staticMemList")), _oop_staticMemList];
    missionNamespace setVariable[("o_" + (_oop_classNameStr) + "_spm_" + ("methodList")), _oop_methodList];;
    _oop_methodList pushBackUnique "new";
    _oop_newMethodList pushBackUnique "new";
    missionNameSpace setVariable[((_oop_classNameStr) + "_fnc_" + ("new")), {}];
    _oop_methodList pushBackUnique "delete";
    _oop_newMethodList pushBackUnique "delete";
    missionNameSpace setVariable[((_oop_classNameStr) + "_fnc_" + ("delete")), {}];
    _oop_methodList pushBackUnique "copy";
    _oop_newMethodList pushBackUnique "copy";
    missionNameSpace setVariable[((_oop_classNameStr) + "_fnc_" + ("copy")), {}];
    _oop_memList pushBackUnique["oop_parent", []];
    _oop_memList pushBackUnique["oop_public", []];
};