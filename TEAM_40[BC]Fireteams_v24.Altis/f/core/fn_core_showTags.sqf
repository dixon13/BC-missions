_target = cursorObject;
if (isNull _target) exitWith {false};
_return = false;
_return = if ((player distance _target < 15) && (isNull objectParent player) && (_target isKindOf "Man") && (side _target == side player) && (alive _target)) then {
    _nameString = format ["<t size='0.375' shadow='2' font='TahomaB' color='#ba9d00'>%2<br/><t size='0.5'>%1</t></t>",name _target,groupID (group _target)];
    [_nameString,0,1,0,0,0,4] spawn BIS_fnc_dynamicText;
    true
};
_return
