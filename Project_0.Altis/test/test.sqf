
fn = { if(false) then { diag_log "blah"; } else { }; };
private _rval = [] call fn;
