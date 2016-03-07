if (!isServer) exitWith {};

seizeMarker = _this select 0;
seizeMarker setMarkerAlpha 5;

while {objSeized} do {
    _size = getMarkerSize seizeMarker;

    if (_size select 0 >= sizeOfSpawnAO) then {
        objSeized = false;
        [] call completedObjective;
    } else {
        _newSize = (_size select 0) + objSizeTick;
        seizeMarker setMarkerSize [_newSize, _newSize];
        sleep objTickTime;
    };
};