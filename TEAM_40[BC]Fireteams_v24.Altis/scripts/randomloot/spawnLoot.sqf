if(!isServer) exitWith {};

// Load call parameters
_pos=	(_this select 0);
_pos0=	(_pos select 0);
_pos1=	(_pos select 1);
_pos2=	(_pos select 2);
_size=  (_this select 1);
_showLootType=	(_this select 2);
_showLootRarity=(_this select 3);

// Determine Z placement for item
_BARREL = createVehicle ["Land_BarrelEmpty_F",[_pos0,_pos1,_pos2+0.1], [], 0, "can_Collide"];
sleep 0.5;
_holder = createVehicle ["groundweaponholder",[_pos0,_pos1,(getposATL _BARREL select 2) + 0.05], [], 0, "can_Collide"];
deletevehicle _BARREL;

// Determine class of rarity
_rarity = "highly common";
_randomizeRarity =floor (random 100);
if (_randomizeRarity > (100-rarityHighlyCommon)) then {
	_rarity = "highly common";
} else { if (_randomizeRarity > (100-hundredMinusCommon)) then {
    _rarity = "common";
} else { if (_randomizeRarity > (100-hundredMinusUncommon)) then {
    _rarity = "uncommon";
} else { if (_randomizeRarity > (100-hundredMinusHighlyUncommon)) then {
    _rarity = "highly uncommon";
} else { if (_randomizeRarity > (100-hundredMinusRare)) then {
    _rarity = "rare"; 
} else { if (_randomizeRarity > (100-hundredMinusExtremelyRare)) then {
    _rarity = "extremely rare";
} else {
    // Someone can't count to 100
    _rarity = "highly common"; // Highly common type by default
}; }; }; }; }; }; // No else if statement, so we get this poor looking nested if. A switch statement might work here.

showMarker = {
	private ["_marker"];
	_marker = _this select 0;
    _id=format ["%1",_pos];
    _debug=createMarker [_id,GETPOS _holder];
    _debug setMarkerShape "ICON";
    _debug setMarkerType "hd_dot";
    _debug setMarkerColor "ColorRed";
    _txt=format ["%1",_marker];
    _debug setMarkerText _txt;
};
    
spawnItem = {
	private ["_type"];
	_type = _this select 1;
	_markerType = _type;
	switch (_type) do {
		// Spawn weapon
		case "weapon": {
			_weapon= _this select 0;
			_holder addWeaponCargoGlobal [_weapon, 1];
            // If we had wanted mags to come with the weapon
            /*
            _magazines = getArray (configFile / "CfgWeapons" / _weapon / "magazines");
			_magazineClass = _magazines call bis_fnc_selectRandom; 
			_holder addMagazineCargoGlobal [_magazineClass, 2];
            */
            _markerType = "W";
		};
		// Spawn magazines using weapon name
		case "weapon_mag": {
            // Haven't gotten this working
			/*
            _weapon= _this select 0;
			_magazines = getArray (configFile / "CfgWeapons" / _weapon / "magazines");
			_magazineClass = _magazines call bis_fnc_selectRandom; 
			_holder addMagazineCargoGlobal [_magazineClass, 2];
            */
            _markerType = "AW";
		};
		// Spawn magazines
		case "mag": {
			_magazines= _this select 0;
			_holder addMagazineCargoGlobal [_magazines, 2];
            _markerType = "A";
		};
		// Spawn items
		case "item": {
			_item= _this select 0;
			_holder addItemCargoGlobal [_item, 1];
			//_clothing= clothesLoot call bis_fnc_selectRandom;
			//_holder addItemCargoGlobal [_clothing, 1];
            _markerType = "I";
		};
		// Spawn vests
		case "vest": {
			_vest= _this select 0;
			_holder addItemCargoGlobal [_vest, 1];
            _markerType = "V";
		};
		// Spawn backpacks
		case "backpack": {
			_backpack= _this select 0;
			_holder addBackpackCargoGlobal [_backpack, 1];
            _markerType = "B";
		};
	};
    
    // Creates debugging markers if flagged on
    if (_showLootType && _showLootRarity) then {
        _markerCombined = format ["%1%2", _rarity, _markerType];
        [_markerCombined] call showMarker;
    } else {
        if (_showLootType) then {
            [_markerType] call showMarker;
        };
        if (_showLootRarity) then {
            [_rarity] call showMarker;
        };
    };

};

// Spawn selected type
switch (_rarity) do {
	case "highly common":   { _item = selectRandom itemsHighlyCommon; };
	case "common":          { _item = selectRandom itemsCommon; };
	case "uncommon":        { _item = selectRandom itemsUncommon; };
	case "highly uncommon": { _item = selectRandom itemsHighlyUncommon; };
	case "rare":            { _item = selectRandom itemsRare; };
	case "extremely rare":  { _item = selectRandom itemsExtremelyRare; };
};
_name = _item select 0;
_type = _item select 1;
[_name,_type] call spawnItem;