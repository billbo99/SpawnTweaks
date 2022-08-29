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

function global_data.find_gear_by_type(item_type)
    global.gear[item_type] = global.gear[item_type] or {}
    local items = game.get_filtered_item_prototypes({ { filter = "type", type = item_type } })
    for k, v in pairs(items) do
        local game_recipes = game.get_filtered_recipe_prototypes({ { filter = "has-product-item", elem_filters = { { filter = "name", name = k } } } })
        local cost
        for recipe, recipe_data in pairs(game_recipes) do
            cost = (global.recipe_to_tech_mapping[recipe] or 1) * settings.global['SpawnTweaks-' .. v.type .. '_base_multiplyer'].value
        end
        global.gear[item_type][k] = global.gear[item_type][k] or { enabled = true, cost = cost }
    end
end

function global_data.parse_gear()
    if not game then return end
    global.gear = global.gear or {}
    global_data.find_gear_by_type("capsule")
    global_data.find_gear_by_type("ammo")
    global_data.find_gear_by_type("gun")
    global_data.find_gear_by_type("armor")

    global.gear['gun']['pistol'].cost = 0

    global.gear['ammo']['firearm-magazine'].cost = 0
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

function global_data.init()
    global_data.parse_technologies()
    global_data.parse_gear()
    global.flags = {}
    global.players = {}
end

function global_data.OnConfigurationChanged(e)
    global_data.parse_technologies()
    global_data.parse_gear()
end

return global_data
