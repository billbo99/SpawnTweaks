local Func = require("scripts.func")

local player_data = {}

function player_data.init(player)
    if player then
        local _ammo = settings.global['SpawnTweaks-starting-ammo'].value
        local data = {
            flags = {
                can_open_gui = false,
                gui_open = false,
                show_message_after_translation = true,
                translate_on_join = true
            },
            gun = { Primary = "pistol", Secondary = "None" },
            ammo = { Primary = _ammo, Secondary = "None" },
            capsule = "None",
            armor = "None",
            gui = {},
            settings = {},
            frames = {},
        }
        storage.players[player.name] = data
    end
end

function player_data.validate(player)
    if storage.players[player.name] then
        storage.players[player.name].flags.can_open_gui = false
        storage.players[player.name].flags.gui_open = false
        storage.players[player.name].flags.show_message_after_translation = true
        storage.players[player.name].flags.translate_on_join = true
        -- storage.players[player.name].gui = {}
        -- storage.players[player.name].settings = {}
        -- storage.players[player.name].frames = {}

        if storage.players[player.name].gun.Primary and not storage.gear.gun[storage.players[player.name].gun.Primary] then
            storage.players[player.name].gun.Primary = "pistol"
        end

        if storage.players[player.name].gun.Secondary and not storage.gear.gun[storage.players[player.name].gun.Secondary] then
            storage.players[player.name].gun.Secondary = "None"
        end

        if storage.players[player.name].ammo.Primary and not storage.gear.ammo[storage.players[player.name].ammo.Primary] then
            storage.players[player.name].ammo.Primary = settings.global['SpawnTweaks-starting-ammo'].value or "firearm-magazine"
        end

        if storage.players[player.name].ammo.Secondary and not storage.gear.ammo[storage.players[player.name].ammo.Secondary] then
            storage.players[player.name].ammo.Secondary = "None"
        end

        if storage.players[player.name].capsule and not storage.gear.capsule[storage.players[player.name].capsule] then
            storage.players[player.name].capsule = "None"
        end

        if storage.players[player.name].armor and not storage.gear.armor[storage.players[player.name].armor] then
            storage.players[player.name].armor = "None"
        end
    end

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
            if prototypes.item[parts[1]] and type(tonumber(parts[2])) == "number" then
                player.insert { name = parts[1], count = tonumber(parts[2]) }
            end
        end
    end
end

function player_data.GiveGear(player)
    local name = player.name
    player_data.ClearPlayerInventories(player)

    if storage.players[name] then
        if storage.players[name]['armor'] and storage.players[name]['armor'] ~= "None" then
            player.insert { name = storage.players[name]['armor'], count = 1 }
        end
        if storage.players[name]['gun'] and storage.players[name]['gun']['Primary'] and storage.players[name]['gun']['Primary'] ~= "None" then
            local item = storage.players[name]['gun']['Primary']
            player.insert { name = item, count = storage.gear["gun"][item].quantity or 1 }
        end
        if storage.players[name]['ammo'] and storage.players[name]['ammo']['Primary'] and storage.players[name]['ammo']['Primary'] ~= "None" then
            local item = storage.players[name]['ammo']['Primary']
            player.insert { name = item, count = storage.gear["ammo"][item].quantity or 1 }
        end
        if storage.players[name]['gun'] and storage.players[name]['gun']['Secondary'] and storage.players[name]['gun']['Secondary'] ~= "None" then
            local item = storage.players[name]['gun']['Secondary']
            player.insert { name = item, count = storage.gear["gun"][item].quantity or 1 }
        end
        if storage.players[name]['ammo'] and storage.players[name]['ammo']['Secondary'] and storage.players[name]['ammo']['Secondary'] ~= "None" then
            local item = storage.players[name]['ammo']['Secondary']
            player.insert { name = item, count = storage.gear["ammo"][item].quantity or 1 }
        end
        if storage.players[name]['capsule'] and storage.players[name]['capsule'] ~= "None" then
            local item = storage.players[name]['capsule']
            player.insert { name = item, count = storage.gear["capsule"][item].quantity or 1 }
        end
    end

    player_data.GiveExtraGear(player)
end

return player_data
