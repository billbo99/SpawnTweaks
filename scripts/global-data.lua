local global_data = {}

function global_data.parse_technologies()
    global.recipe_to_tech_mapping = global.recipe_to_tech_mapping or {}
    for _, tech in pairs(game.technology_prototypes) do
        for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" then
                global.recipe_to_tech_mapping[effect.recipe] = #tech.research_unit_ingredients
            end
        end
    end
end

function global_data.find_gear_by_type(item_type, override_item_type)
    global.gear[item_type] = {}
    local items
    if #game.get_filtered_item_prototypes({ { filter = "type", type = item_type } }) > 0 then
        items = game.get_filtered_item_prototypes({ { filter = "type", type = item_type } })
    else
        items = game.get_filtered_entity_prototypes({ { filter = "type", type = item_type } })
    end

    for k, v in pairs(items) do
        local game_recipes = game.get_filtered_recipe_prototypes({ { filter = "has-product-item", elem_filters = { { filter = "name", name = k } } } })
        local cost = 0
        local quantity = settings.global['SpawnTweaks-capsule_starting_amount'].value
        v_type = override_item_type or v.type
        for recipe, recipe_data in pairs(game_recipes) do
            cost = (global.recipe_to_tech_mapping[recipe] or 1) * settings.global['SpawnTweaks-' .. v_type .. '_base_multiplyer'].value
            if settings.global['SpawnTweaks-' .. v_type .. '_starting_amount'] then
                quantity = settings.global['SpawnTweaks-' .. v_type .. '_starting_amount'].value or 1
            else
                quantity = 1
            end
        end
        if not global.gear[v_type][k] then
            global.gear[v_type][k] = { enabled = true, cost = cost, quantity = quantity, prototype = v }
        else
            global.gear[v_type][k]['enabled'] = global.gear[v_type][k]['enabled'] or true
            global.gear[v_type][k]['cost'] = global.gear[v_type][k]['cost'] or cost
            global.gear[v_type][k]['quantity'] = global.gear[v_type][k]['quantity'] or quantity
            global.gear[v_type][k]['prototype'] = global.gear[v_type][k]['prototype'] or v
        end
    end
end

function global_data.parse_gear(action)
    if not game then return end
    global.gear = global.gear or {}
    global_data.find_gear_by_type("capsule")
    global_data.find_gear_by_type("land-mine", "capsule")
    global_data.find_gear_by_type("ammo")
    global_data.find_gear_by_type("gun")
    global_data.find_gear_by_type("armor")

    global.gear['gun']['pistol'].cost = 0
    global.gear['ammo']['firearm-magazine'].cost = 0

    if action == "init" then
        global.gear['ammo']['cannon-shell'].enabled = false
        global.gear['ammo']['explosive-cannon-shell'].enabled = false
        global.gear['ammo']['uranium-cannon-shell'].enabled = false
        global.gear['ammo']['explosive-uranium-cannon-shell'].enabled = false
        global.gear['ammo']['artillery-shell'].enabled = false
        global.gear['ammo']['atomic-bomb'].enabled = false

        global.gear['armor']['power-armor'].enabled = false
        global.gear['armor']['power-armor-mk2'].enabled = false

        global.gear['capsule']['artillery-targeting-remote'].enabled = false
        global.gear['capsule']['discharge-defense-remote'].enabled = false
    end
end

function global_data.init()
    global_data.parse_technologies()
    global_data.parse_gear("init")
    global.gui_locked = true
    global.flags = {}
    global.players = {}
end

function global_data.OnConfigurationChanged(e)
    global_data.parse_technologies()
    global_data.parse_gear("OnConfigurationChanged")
end

return global_data
