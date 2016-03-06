if (!isServer) exitWith {};

//_color = getMarkerColor "objHold";
seizeMarker = _this select 0;
//switch (_color) do {
//    case "ColorBLUFOR": { seizeMarker = "blueSeize"; };
//    case "ColorOPFOR": { seizeMarker = "redSeize"; };
//    case "ColorIndependent": { seizeMarker = "greenSeize"; };
//    case "ColorCivilian": { seizeMarker = "purpleSeize"; };
//};
seizeMarker setMarkerAlpha 5;

while {objSeized} do {
    _size = getMarkerSize seizeMarker;

    if (_size select 0 >= sizeOfSpawnAO) then {
        objSeized = false;
        [] call completedObjective;
        //[] exec "scripts\objcompleted.sqf";
    } else {
        _newSize = (_size select 0) + objSizeTick;
        seizeMarker setMarkerSize [_newSize, _newSize];
        sleep objTickTime;
    };
};