local DB = {}

function DB.ParseAmmoByCategory()
    storage.AmmoByCategory = storage.AmmoByCategory or {}
    for name, _ in pairs(prototypes.ammo_category) do
        storage.AmmoByCategory[name] = {}
    end

    for name, data in pairs(prototypes.get_item_filtered({ { filter = "type", type = "ammo" } })) do
        if data.get_ammo_type() then
            local record = { name = name, proto = data }
            local key = data.ammo_category.name
            table.insert(storage.AmmoByCategory[key], record)
        end
    end

    for name, data in pairs(prototypes.get_item_filtered({ { filter = "type", type = "capsule" } })) do
        if data.capsule_action and data.capsule_action.attack_parameters and data.capsule_action.attack_parameters.ammo_type then
            local record = { name = name, proto = data }
            local key = data.capsule_action.attack_parameters.ammo_categories[1]
            table.insert(storage.AmmoByCategory[key], record)
        end
    end
end

function DB.CreateGlobals()
    storage.print_colour = { r = 255, g = 255, b = 0 }
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
