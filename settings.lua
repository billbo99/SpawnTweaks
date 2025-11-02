data:extend(
    {
        -- runtime-global
        { name = "SpawnTweaks-get-starting-gear",       type = "bool-setting",   default_value = true,                                   setting_type = "runtime-global", order = "0010" },
        { name = "SpawnTweaks-starting-ammo",           type = "string-setting", default_value = "firearm-magazine",                     setting_type = "runtime-global", order = "0015" },
        { name = "SpawnTweaks-extra-respawn-gear",      type = "string-setting", default_value = "",                                     allow_blank = true,              setting_type = "runtime-global", order = "0020" },
        { name = "SpawnTweaks-gun_base_multiplyer",     type = "int-setting",    default_value = 15,                                     minimum_value = 0, setting_type = "runtime-global", order = "0100" },
        { name = "SpawnTweaks-ammo_base_multiplyer",    type = "int-setting",    default_value = 50,                                     minimum_value = 0, setting_type = "runtime-global", order = "0150" },
        { name = "SpawnTweaks-ammo_starting_amount",    type = "int-setting",    default_value = 20,                                     minimum_value = 0, setting_type = "runtime-global", order = "0160" },
        { name = "SpawnTweaks-armor_base_multiplyer",   type = "int-setting",    default_value = 15,                                     minimum_value = 0, setting_type = "runtime-global", order = "0300" },
        { name = "SpawnTweaks-capsule_base_multiplyer", type = "int-setting",    default_value = 50,                                     minimum_value = 0, setting_type = "runtime-global", order = "0400" },
        { name = "SpawnTweaks-capsule_starting_amount", type = "int-setting",    default_value = 5,                                      minimum_value = 0, setting_type = "runtime-global", order = "0410" },
        { name = "SpawnTweaks-welcome",                 type = "string-setting", default_value = "Welcome to the map",                   setting_type = "runtime-global", order = "0900" },
        { name = "SpawnTweaks-respawn",                 type = "string-setting", default_value = "Cloning complete ... have a nice day", setting_type = "runtime-global", order = "0901" },
        { name = "SpawnTweaks-respawn-multiplyer",      type = "double-setting", default_value = 1,                                      minimum_value = 0,               setting_type = "runtime-global", order = "0902" },
        -- { name = "SpawnTweaks-respawn-cooldown", type = "int-setting", default_value = 10, setting_type = "runtime-global", order = "0903" },
        -- startup
        { name = "SpawnTweaks-player_corpse_life",      type = "int-setting",    default_value = 15,                                     minimum_value = 0,               maximum_value = 1000000,         setting_type = "startup", order = "0100" },
        { name = "SpawnTweaks-biter_corpse_life",       type = "int-setting",    default_value = 5,                                      minimum_value = 0,               maximum_value = 1000000,         setting_type = "startup", order = "0200" },
        { name = "SpawnTweaks-healing_per_tick",        type = "double-setting", default_value = 0.15,                                   minimum_value = 0,               maximum_value = 1000000,         setting_type = "startup", order = "0300" }, -- 9hp per second
        { name = "SpawnTweaks-ticks_to_stay_in_combat", type = "int-setting",    default_value = 600,                                    minimum_value = 0,               maximum_value = 1000000,         setting_type = "startup", order = "0400" }, -- 10 seconds default
        { name = "SpawnTweaks-damage_hit_tint_r",       type = "int-setting",    default_value = -1,                                     minimum_value = -1,              maximum_value = 255,             setting_type = "startup", order = "0500" }, -- default 1
        { name = "SpawnTweaks-damage_hit_tint_g",       type = "int-setting",    default_value = -1,                                     minimum_value = -1,              maximum_value = 255,             setting_type = "startup", order = "0501" }, -- default 0
        { name = "SpawnTweaks-damage_hit_tint_b",       type = "int-setting",    default_value = -1,                                     minimum_value = -1,              maximum_value = 255,             setting_type = "startup", order = "0502" }, -- default 0
        { name = "SpawnTweaks-damage_hit_tint_a",       type = "int-setting",    default_value = -1,                                     minimum_value = -1,              maximum_value = 255,             setting_type = "startup", order = "0503" } -- default 0
    }
)
