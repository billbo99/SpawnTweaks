local Func = require("scripts.func")

local player_data = {}

function player_data.init(player)
    if player then
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
        }
        global.players[player.name] = data
    end
end

function player_data.validate(player)
    if global.players[player.name] then
        global.players[player.name].flags.can_open_gui = false
        global.players[player.name].flags.gui_open = false
        global.players[player.name].flags.show_message_after_translation = true
        global.players[player.name].flags.translate_on_join = true
        -- global.players[player.name].gui = {}
        -- global.players[player.name].settings = {}
        -- global.players[player.name].frames = {}

        if global.players[player.name].gun.Primary and not global.gear.gun[global.players[player.name].gun.Primary] then
            global.players[player.name].gun.Primary = "pistol"
        end

        if global.players[player.name].gun.Secondary and not global.gear.gun[global.players[player.name].gun.Secondary] then
            global.players[player.name].gun.Secondary = "None"
        end

        if global.players[player.name].ammo.Primary and not global.gear.ammo[global.players[player.name].ammo.Primary] then
            global.players[player.name].ammo.Primary = "firearm-magazine"
        end

        if global.players[player.name].ammo.Secondary and not global.gear.ammo[global.players[player.name].ammo.Secondary] then
            global.players[player.name].ammo.Secondary = "None"
        end

        if global.players[player.name].capsule and not global.gear.capsule[global.players[player.name].capsule] then
            global.players[player.name].capsule = "None"
        end

        if global.players[player.name].armor and not global.gear.armor[global.players[player.name].armor] then
            global.players[player.name].armor = "None"
        end
        -- else
        --     player_data.init(player)
    end

    --     gun = { Primary = "pistol", Secondary = "None" },
    --     ammo = { Primary = "firearm-magazine", Secondary = "None" },
    --     capsule = "None",
    --     armor = "None",
    --     gui = {},
    --     settings = {},
    --     frames = {},
    -- }
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
