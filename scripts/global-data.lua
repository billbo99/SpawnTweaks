local global_data = {}

function global_data.parse_technologies()
    storage.recipe_to_tech_mapping = storage.recipe_to_tech_mapping or {}
    for _, tech in pairs(prototypes.technology) do
        for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" then
                storage.recipe_to_tech_mapping[effect.recipe] = #tech.research_unit_ingredients
            end
        end
    end
end

function global_data.find_gear_by_type(item_type, override_item_type)
    storage.gear[item_type] = {}
    local items
    if #prototypes.get_item_filtered({ { filter = "type", type = item_type } }) > 0 then
        items = prototypes.get_item_filtered({ { filter = "type", type = item_type } })
    else
        items = prototypes.get_entity_filtered({ { filter = "type", type = item_type } })
    end

    for k, v in pairs(items) do
        local game_recipes = prototypes.get_recipe_filtered({ { filter = "has-product-item", elem_filters = { { filter = "name", name = k } } } })
        if #game_recipes > 0 then
            local cost = 0
            local quantity = settings.global['SpawnTweaks-capsule_starting_amount'].value
            v_type = override_item_type or v.type
            for recipe, recipe_data in pairs(game_recipes) do
                if recipe_data.category ~= "recycling" then
                    cost = (storage.recipe_to_tech_mapping[recipe] or 1) * settings.global['SpawnTweaks-' .. v_type .. '_base_multiplyer'].value
                    if settings.global['SpawnTweaks-' .. v_type .. '_starting_amount'] then
                        quantity = settings.global['SpawnTweaks-' .. v_type .. '_starting_amount'].value or 1
                    else
                        quantity = 1
                    end
                end
            end
            if not storage.gear[v_type][k] then
                storage.gear[v_type][k] = { enabled = true, cost = cost, quantity = quantity, prototype = v }
            else
                storage.gear[v_type][k]['enabled'] = storage.gear[v_type][k]['enabled'] or true
                storage.gear[v_type][k]['cost'] = storage.gear[v_type][k]['cost'] or cost
                storage.gear[v_type][k]['quantity'] = storage.gear[v_type][k]['quantity'] or quantity
                storage.gear[v_type][k]['prototype'] = storage.gear[v_type][k]['prototype'] or v
            end
        end
    end
end

function global_data.parse_gear(action)
    if not game then return end
    storage.gear = storage.gear or {}
    global_data.find_gear_by_type("capsule")
    global_data.find_gear_by_type("land-mine", "capsule")
    global_data.find_gear_by_type("ammo")
    global_data.find_gear_by_type("gun")
    global_data.find_gear_by_type("armor")

    storage.gear['gun']['pistol'].cost = 0
    storage.gear['ammo']['firearm-magazine'].cost = 0

    if action == "init" then
        storage.gear['ammo']['cannon-shell'].enabled = false
        storage.gear['ammo']['explosive-cannon-shell'].enabled = false
        storage.gear['ammo']['uranium-cannon-shell'].enabled = false
        storage.gear['ammo']['explosive-uranium-cannon-shell'].enabled = false
        storage.gear['ammo']['artillery-shell'].enabled = false
        storage.gear['ammo']['atomic-bomb'].enabled = false
    end
end

function global_data.init()
    global_data.parse_technologies()
    global_data.parse_gear("init")
    storage.gui_locked = true
    storage.flags = {}
    storage.players = {}
end

function global_data.OnConfigurationChanged(e)
    global_data.parse_technologies()
    global_data.parse_gear("OnConfigurationChanged")
end

return global_data
