if(!isServer) exitWith {};

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

_rarityHighlyCommon = 30;
_rarityCommon = 42;
_rarityUncommon = 11;
_rarityHighlyUncommon = 11;
_rarityRare = 4; //4
_rarityExtremelyRare = 2; //1

_hundredMinusCommon = _rarityHighlyCommon + _rarityCommon;
_hundredMinusUncommon = _hundredMinusCommon + _rarityUncommon;
_hundredMinusHighlyUncommon = _hundredMinusUncommon + _rarityHighlyUncommon;
_hundredMinusRare = _hundredMinusHighlyUncommon + _rarityRare;
_hundredMinusExtremelyRare = _hundredMinusRare + _rarityExtremelyRare;

_rarity = 0;
_randomizeRarity =floor (random 100);
if (_randomizeRarity > (100-_rarityHighlyCommon)) then {
	_rarity = 0; // Highly common
} else {
	if (_randomizeRarity > (100-_hundredMinusCommon)) then {
		_rarity = 1; // Common
	} else {
		if (_randomizeRarity > (100-_hundredMinusUncommon)) then {
			_rarity = 2; // Uncommon
		} else {
			if (_randomizeRarity > (100-_hundredMinusHighlyUncommon)) then {
				_rarity = 3; // Highly uncommon
			} else {
				if (_randomizeRarity > (100-_hundredMinusRare)) then {
					_rarity = 4; // Rare
				} else {
					if (_randomizeRarity > (100-_hundredMinusExtremelyRare)) then {
						_rarity = 5; // Extremely rare
					} else {
						// Someone can't count to 100
						_rarity = 0; // Highly common type by default
					};
				};
			};
		};
	};
};

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
			//_magazines = getArray (configFile / "CfgWeapons" / _weapon / "magazines");
			//_magazineClass = _magazines call bis_fnc_selectRandom; 
			_holder addWeaponCargoGlobal [_weapon, 1];
			//_holder addMagazineCargoGlobal [_magazineClass, 2];
            _markerType = "W";
		};
		// Spawn magazines using weapon name
		case "weapon_mag": {
			//_weapon= _this select 0;
			//_magazines = getArray (configFile / "CfgWeapons" / _weapon / "magazines");
			//_magazineClass = _magazines call bis_fnc_selectRandom; 
			//_holder addMagazineCargoGlobal [_magazineClass, 2];
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
		default {hint "Let Fritz know something went wrong!"};
	};
    
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
	// Highly common
	case 0: {
		_item = selectRandom itemsHighlyCommon;
		_name = _item select 0;
		_type = _item select 1;
		[_name,_type] call spawnItem;
	};
	
	// Common
	case 1: {
		_item = selectRandom itemsCommon;
		_name = _item select 0;
		_type = _item select 1;
		[_name,_type] call spawnItem;
		
	};
	
	// Uncommon 
	case 2: {
		_item = selectRandom itemsUncommon;
		_name = _item select 0;
		_type = _item select 1;
		[_name,_type] call spawnItem;
	};
	
	// Highly uncommon
	case 3: {
		_item = selectRandom itemsHighlyUncommon;
		_name = _item select 0;
		_type = _item select 1;
		[_name,_type] call spawnItem;
	};
	
	// Rare
	case 4: {
		_item = selectRandom itemsRare;
		_name = _item select 0;
		_type = _item select 1;
		[_name,_type] call spawnItem;
	};
	
	// Extremely rare
	case 5: {
		_item = selectRandom itemsExtremelyRare;
		_name = _item select 0;
		_type = _item select 1;
		[_name,_type] call spawnItem;
	};
	default {hint "Let Fritz know something went wrong!"};
};