private _arr = [["test"]];

private _copy = +_arr;

_arr#0 set [0, "check"];

systemchat str _arr;
systemchat str _copy;