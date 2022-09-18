local translation = require("__flib__.translation")

-- local main_gui = require("scripts.gui.main.base")
local Gui = require("scripts.gui")
local Func = require("scripts.func")
local constants = require("constants")
local util = require("__core__.lualib.util")
local on_tick = require("scripts.on-tick")

local player_data = {}

function player_data.init(player)
    local data = {
        flags = {
            can_open_gui = false,
            gui_open = false,
            show_message_after_translation = true,
            translate_on_join = true
        },
        gun = { Primary = "pistol", Secondary = "None" },
        ammo = { Primary = "firearm-magazine", Secondary = "None" },
        capsule = "None",
        armor = "None",
        gui = {},
        settings = {},
        frames = {},
        translations = util.table.deepcopy(constants.empty_translation_table)
    }
    global.players[player.name] = data

    player_data.refresh(player, global.players[player.name])
end

function player_data.update_settings(player, player_table)
    local mod_settings = player.mod_settings
    local settings = {}
    player_table.settings = settings
end

function player_data.start_translations(player_index)
    translation.add_requests(player_index, global.strings)
    on_tick.register()
end

function player_data.refresh(player, player_table)
    -- close GUI
    Gui.close(player)

    -- set flags
    player_table.flags.can_open_gui = false

    -- update settings
    player_data.update_settings(player, player_table)

    -- run translations
    player_table.translations = util.table.deepcopy(constants.empty_translation_table)
    if player.connected then
        player_data.start_translations(player.index)
    else
        player_table.flags.translate_on_join = true
    end

    player_data.update_settings(player, player_table)
end

function player_data.ClearPlayerInventories(player)
    if player.get_inventory(defines.inventory.character_ammo) then
        player.get_inventory(defines.inventory.character_ammo).clear()
    end
    if player.get_inventory(defines.inventory.character_guns) then
        player.get_inventory(defines.inventory.character_guns).clear()
    end
end

function player_data.GiveExtraGear(player)
    if settings.global["SpawnTweaks-get-starting-gear"].value then
        local items = Func.Split(settings.global["SpawnTweaks-extra-respawn-gear"].value, " +")
        for _, item in pairs(items) do
            local parts = Func.Split(item, ":")
            if game.item_prototypes[parts[1]] and type(tonumber(parts[2])) == "number" then
                player.insert { name = parts[1], count = tonumber(parts[2]) }
            end
        end
    end
end

function player_data.GiveGear(player)
    local name = player.name
    player_data.ClearPlayerInventories(player)

    if global.players[name] then
        if global.players[name]['armor'] and global.players[name]['armor'] ~= "None" then
            player.insert { name = global.players[name]['armor'], count = 1 }
        end
        if global.players[name]['gun'] and global.players[name]['gun']['Primary'] and global.players[name]['gun']['Primary'] ~= "None" then
            local item = global.players[name]['gun']['Primary']
            player.insert { name = item, count = global.gear["gun"][item].quantity or 1 }
        end
        if global.players[name]['ammo'] and global.players[name]['ammo']['Primary'] and global.players[name]['ammo']['Primary'] ~= "None" then
            local item = global.players[name]['ammo']['Primary']
            player.insert { name = item, count = global.gear["ammo"][item].quantity or 1 }
        end
        if global.players[name]['gun'] and global.players[name]['gun']['Secondary'] and global.players[name]['gun']['Secondary'] ~= "None" then
            local item = global.players[name]['gun']['Secondary']
            player.insert { name = item, count = global.gear["gun"][item].quantity or 1 }
        end
        if global.players[name]['ammo'] and global.players[name]['ammo']['Secondary'] and global.players[name]['ammo']['Secondary'] ~= "None" then
            local item = global.players[name]['ammo']['Secondary']
            player.insert { name = item, count = global.gear["ammo"][item].quantity or 1 }
        end
        if global.players[name]['capsule'] and global.players[name]['capsule'] ~= "None" then
            local item = global.players[name]['capsule']
            player.insert { name = item, count = global.gear["capsule"][item].quantity or 1 }
        end
    end

    player_data.GiveExtraGear(player)
end

return player_data
