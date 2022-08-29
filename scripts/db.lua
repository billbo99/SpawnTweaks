local DB = {}

function DB.ParseAmmoByCategory()
    global.AmmoByCategory = global.AmmoByCategory or {}
    for name, _ in pairs(game.ammo_category_prototypes) do
        global.AmmoByCategory[name] = {}
    end

    for name, data in pairs(game.get_filtered_item_prototypes({ { filter = "type", type = "ammo" } })) do
        if data.get_ammo_type() then
            local record = { name = name, proto = data }
            local key = data.get_ammo_type().category
            table.insert(global.AmmoByCategory[key], record)
        end
    end

    for name, data in pairs(game.get_filtered_item_prototypes({ { filter = "type", type = "capsule" } })) do
        if data.capsule_action and data.capsule_action.attack_parameters and data.capsule_action.attack_parameters.ammo_type then
            local record = { name = name, proto = data }
            local key = data.capsule_action.attack_parameters.ammo_type.category
            table.insert(global.AmmoByCategory[key], record)
        end
    end
end

function DB.CreateGlobals()
    global.print_colour = { r = 255, g = 255, b = 0 }
    DB.ParseAmmoByCategory()
end

function DB.OnConfigurationChanged(e)
    DB.CreateGlobals()
end

function DB.OnInit()
    DB.CreateGlobals()
end

function DB.OnLoad(e)
end

return DB
