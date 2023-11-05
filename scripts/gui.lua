local mod_gui = require("mod-gui")
local Func = require("scripts.func")
local Gui = {}

function Gui.GenerateCaption(player, item, item_type)
    local flag = false
    local cost = 0
    local caption
    local postfix = ""
    local force = player.force
    local produced = force["item_production_statistics"].input_counts

    local game_recipes = game.get_filtered_recipe_prototypes({ { filter = "has-product-item", elem_filters = { { filter = "name", name = item } } } })
    -- for _, recipe in pairs(game_recipes) do
    local item_translation = global.locale_dictionaries.item[item] or ""
    if global.gear[item_type] and global.gear[item_type][item] then
        cost = global.gear[item_type][item].cost
    elseif global.gear["capsule"] and global.gear["capsule"][item] then
        cost = global.gear["capsule"][item].cost
    else
        cost = 100
    end
    caption = "[img=item/" .. item .. "] " .. item_translation

    local items_produced = produced[item] or 0
    if items_produced < (cost or 0) then
        postfix = " [color=red][" .. tostring(items_produced) .. "/" .. tostring(cost) .. "][/color]"
    else
        flag = true
    end
    -- end

    return flag, cost, caption, postfix
end

function Gui.ProcessRadioButton(RadioButton)
    local ParentFrame = RadioButton.parent
    for _, child in pairs(ParentFrame.children) do
        if child.type == "radiobutton" and child.name ~= RadioButton.name then
            child.state = false
        end
    end
end

function Gui.Picked(e)
    Gui.ProcessRadioButton(e.element)
    local element_name = e.element.name
    local player = game.get_player(e.player_index)
    local item = Func.Split(element_name, ":")[3]
    local item_type = Func.Split(element_name, ":")[2]

    global.players[player.name][item_type:lower()] = item
end

function Gui.Quantity(e)
    local element_name = e.element.name
    local item_type = Func.Split(element_name, ":")[2]:lower()
    local item = Func.Split(element_name, ":")[3]:lower()
    global.gear[item_type][item].quantity = tonumber(e.element.text) or 0
end

function Gui.Cost(e)
    local element_name = e.element.name
    local item_type = Func.Split(element_name, ":")[2]:lower()
    local item = Func.Split(element_name, ":")[3]:lower()
    global.gear[item_type][item].cost = tonumber(e.element.text) or 0
end

function Gui.Enabled(e)
    local element_name = e.element.name
    local item_type = Func.Split(element_name, ":")[2]:lower()
    local item = Func.Split(element_name, ":")[3]:lower()
    global.gear[item_type][item].enabled = e.element.state
end

function Gui.PickedAmmo(e, tag)
    Gui.ProcessRadioButton(e.element)
    local element_name = e.element.name
    local player = game.get_player(e.player_index)
    local ammo = Func.Split(element_name, ":")[2]

    global.players[player.name].ammo[tag] = ammo
end

function Gui.SpawnTweaksTab(e)
    local element_name = e.element.name
    local player = game.get_player(e.player_index)
    local tab_name = Func.Split(element_name, ":")[2]

    if player.gui.screen.SpawnTweaksMain.inside_frame.tabbed_pane[tab_name:lower()] then
        local frame = player.gui.screen.SpawnTweaksMain.inside_frame.tabbed_pane[tab_name:lower()]
        frame.clear()
        if Gui.tabs[tab_name:lower()] then Gui.tabs[tab_name:lower()].func(frame) end
    end
end

function Gui.PickedPrimaryAmmo(e)
    Gui.PickedAmmo(e, "Primary")
end

function Gui.PickedSecondaryAmmo(e)
    Gui.PickedAmmo(e, "Secondary")
end

function Gui.PickedGun(e, tag)
    local elements = {}
    local state = false
    local player = game.get_player(e.player_index)
    local element_name = e.element.name
    local gun = Func.Split(element_name, ":")[2]
    local frame = player.gui.screen.SpawnTweaksMain.inside_frame.tabbed_pane[tag:lower()].ammo

    global.players[player.name].gun[tag] = gun
    if gun == "None" then
        global.players[player.name].ammo[tag] = "None"
    end

    Gui.ProcessRadioButton(e.element)
    frame.clear()
    if global.players[player.name].ammo[tag] == "None" then
        state = true
    end
    frame.add { name = "Picked" .. tag .. "Ammo:None", type = "radiobutton", state = state, caption = "None", enabled = true }

    if gun ~= "None" then
        local item = game.item_prototypes[gun]
        if item.attack_parameters and item.attack_parameters.ammo_categories then
            for _, ammo_category in pairs(item.attack_parameters.ammo_categories) do
                for k, v in pairs(global.AmmoByCategory[ammo_category]) do
                    local game_recipes = game.get_filtered_recipe_prototypes({ { filter = "has-product-item", elem_filters = { { filter = "name", name = v.name } } } })
                    local force_recipes = player.force.recipes
                    for _, recipe in pairs(game_recipes) do
                        if force_recipes[recipe.name].enabled then
                            if global.players[player.name].ammo[tag] == v.name then
                                state = true
                            else
                                state = false
                            end
                            local flag, cost, caption, postfix = Gui.GenerateCaption(player, v.name, v.proto.type)
                            if not elements[cost] then
                                elements[cost] = {}
                            end
                            if postfix then caption = caption .. " " .. postfix end
                            elements[cost][k] = { name = "Picked" .. tag .. "Ammo:" .. v.name, type = "radiobutton", state = state, caption = caption, enabled = flag }
                        end
                    end
                end
            end
        end
    end
    for _, k1 in pairs(Func.sortKeys(elements)) do
        for _, k2 in pairs(Func.sortKeys(elements[k1])) do
            local v = elements[k1][k2]
            if global.gear["ammo"][Func.Split(v.name, ":")[2]].enabled then
                local element = frame.add(elements[k1][k2])
                if element.state then
                    local data = { player_index = player.index, element = element }
                    Gui.PickedAmmo(data, tag)
                end
            end
        end
    end
end

function Gui.PickedPrimaryGun(e)
    Gui.PickedGun(e, "Primary")
end

function Gui.PickedSecondaryGun(e)
    Gui.PickedGun(e, "Secondary")
end

function Gui.CreateGunFrame(frame, tag, alt)
    local elements = {}
    local state = false
    local player = game.get_player(frame.player_index)

    local frame1 = frame.add({ type = "frame", style = "inside_shallow_frame_with_padding", caption = "Gun", name = "gun", direction = "vertical" })
    frame1.style.horizontally_stretchable = true
    frame1.style.vertically_stretchable = true
    frame1.style.minimal_width = 200

    if global.players[player.name].gun[tag] == "None" then
        global.players[player.name].ammo[tag] = "None"
        state = true
    end

    local frame2 = frame.add({ type = "frame", style = "inside_shallow_frame_with_padding", caption = "Ammo", name = "ammo", direction = "vertical" })
    frame2.style.horizontally_stretchable = true
    frame2.style.vertically_stretchable = true
    frame2.style.minimal_width = 200

    frame1.add { name = "Picked" .. tag .. "Gun:None", type = "radiobutton", state = state, caption = "None", enabled = true }
    local items = game.get_filtered_item_prototypes({ { filter = "type", type = "gun" } })
    for k, v in pairs(items) do
        if v.flags and v.flags.hidden then
            -- skip
        else
            local game_recipes = game.get_filtered_recipe_prototypes({ { filter = "has-product-item", elem_filters = { { filter = "name", name = v.name } } } })
            local force_recipes = player.force.recipes
            for _, recipe in pairs(game_recipes) do
                if force_recipes[recipe.name].enabled then
                    if global.players[player.name].gun[tag] == k then
                        state = true
                    else
                        state = false
                    end
                    local flag, cost, caption, postfix = Gui.GenerateCaption(player, v.name, v.type)
                    if global.players[player.name].gun[alt] == v.name then
                        flag = false
                    end

                    local key = ""
                    if v.subgroup and v.subgroup.name then key = key .. v.subgroup.name end
                    if v.order then key = key .. v.order end
                    if postfix then caption = caption .. " " .. postfix end
                    elements[key] = { name = "Picked" .. tag .. "Gun:" .. k, type = "radiobutton", state = state, caption = caption, enabled = flag }
                end
            end
        end
    end
    for _, k1 in pairs(Func.sortKeys(elements)) do
        local v = elements[k1]
        if global.gear["gun"][Func.Split(v.name, ":")[2]].enabled then
            local element = frame1.add(elements[k1])
            if element.state then
                local data = { player_index = player.index, element = element }
                Gui.PickedGun(data, tag)
            end
        end
    end
end

function Gui.CreatePrimary(frame)
    Gui.CreateGunFrame(frame, "Primary", "Secondary")
end

function Gui.CreateSecondary(frame)
    Gui.CreateGunFrame(frame, "Secondary", "Primary")
end

function Gui.CreateData(player, item_type)
    local elements = {}
    -- local items = game.get_filtered_item_prototypes({ { filter = "type", type = item_type:lower() } })
    for k, v in pairs(global.gear[item_type:lower()]) do
        if v.prototype and v.prototype.flags and v.prototype.flags.hidden then
            -- skip
        else
            local game_recipes = game.get_filtered_recipe_prototypes({ { filter = "has-product-item", elem_filters = { { filter = "name", name = v.prototype.name } } } })
            local force_recipes = player.force.recipes
            if #game_recipes > 0 then
                for _, recipe in pairs(game_recipes) do
                    if global.players[player.name][item_type:lower()] == v.prototype.name then
                        state = true
                    else
                        state = false
                    end
                    local flag, cost, caption, postfix = Gui.GenerateCaption(player, v.prototype.name, v.prototype.type)
                    local key = ""
                    if v.prototype.subgroup and v.prototype.subgroup.name then key = key .. v.prototype.subgroup.name end
                    if v.prototype.order then key = key .. v.prototype.order end
                    key = key .. v.prototype.name
                    elements[key] = { name = v.prototype.name, type = v.prototype.type, state = state, caption = caption, postfix = postfix, enabled = flag, unlocked = force_recipes[recipe.name].enabled }
                end
            else
                local key = ""
                if v.prototype.subgroup and v.prototype.subgroup.name then key = key .. v.prototype.subgroup.name end
                if v.prototype.order then key = key .. v.prototype.order end
                local flag, cost, caption, postfix = Gui.GenerateCaption(player, v.prototype.name, v.prototype.type)
                elements[key] = { name = v.prototype.name, type = v.prototype.type, state = state, caption = caption, postfix = postfix, enabled = flag, unlocked = true }
            end
        end
    end
    return elements
end

function Gui.CreateRadioButtonList(frame, item_type)
    local state = false
    local player = game.get_player(frame.player_index)

    if global.players[player.name].capsule == "None" then
        state = true
    end
    frame.add { name = "Picked:" .. item_type .. ":None", type = "radiobutton", state = state, caption = "None", enabled = true }

    local elements = Gui.CreateData(player, item_type)

    for _, k1 in pairs(Func.sortKeys(elements)) do
        local v = elements[k1]
        local v_type
        if global.gear[v.type] and global.gear[v.type][v.name] then
            v_type = v.type
        else
            v_type = "capsule"
        end
        if v.postfix then v.caption = v.caption .. " " .. v.postfix end
        local element = { name = "Picked:" .. item_type .. ":" .. v.name, type = "radiobutton", state = v.state, caption = v.caption, enabled = v.enabled }
        if v.unlocked and global.gear[v_type][v.name].enabled then
            frame.add(element)
        end
    end
end

function Gui.CreateAdmin(frame)
    local player = game.get_player(frame.player_index)
    local tabbed_pane = frame.add({ type = "tabbed-pane", name = "admin_tabbed_pane", style = "tabbed_pane_with_no_side_padding" })

    for name, data in pairs(Gui.admin_tabs) do
        if (data.admin and player.admin) or (not data.admin) then
            local new_tab = tabbed_pane.add({ type = "tab", style = "tab", name = "SpawnTweaksTab:" .. name, caption = Func.CapitalizeWord(data.caption) })
            local new_frame = tabbed_pane.add({ type = "frame", style = "invisible_frame", name = name, direction = data.direction })
            tabbed_pane.add_tab(new_tab, new_frame)
            global.players[player.name].frames[new_tab.name] = new_tab
            global.players[player.name].frames[new_frame.name] = new_frame
            data.func(new_frame, data.caption)
        end
    end
end

function Gui.CreateMisc(frame)
    local frame1 = frame.add({ type = "frame", style = "inside_shallow_frame_with_padding", caption = "Armor", name = "armor", direction = "vertical" })
    frame1.style.horizontally_stretchable = true
    frame1.style.vertically_stretchable = true
    frame1.style.minimal_width = 200
    Gui.CreateRadioButtonList(frame1, "Armor")

    local frame2 = frame.add({ type = "frame", style = "inside_shallow_frame_with_padding", caption = "Capsule", name = "capsule", direction = "vertical" })
    frame2.style.horizontally_stretchable = true
    frame2.style.vertically_stretchable = true
    frame2.style.minimal_width = 200
    Gui.CreateRadioButtonList(frame2, "Capsule")
end

function Gui.CreateSpawnTweaksMain(player)
    if player.gui.screen["SpawnTweaksMain"] then
        player.gui.screen["SpawnTweaksMain"].destroy()
    end

    local main_frame = player.gui.screen.add({ type = "frame", name = "SpawnTweaksMain", direction = "vertical" })
    player.opened = main_frame

    local flowtitle = main_frame.add { type = "flow", name = "title" }
    local title = flowtitle.add { type = "label", style = "frame_title", caption = "Spawn Tweaks" }
    title.drag_target = main_frame
    local pusher = flowtitle.add { type = "empty-widget", style = "draggable_space_header" }
    pusher.style.vertically_stretchable = true
    pusher.style.horizontally_stretchable = true
    pusher.drag_target = main_frame
    flowtitle.add { type = "sprite-button", style = "frame_action_button", name = "SpawnTweaksMainClose", sprite = "utility/close_white" }

    local inside_frame = main_frame.add({ type = "frame", name = "inside_frame", style = "inside_deep_frame_for_tabs" })

    local tabbed_pane = inside_frame.add({ type = "tabbed-pane", name = "tabbed_pane", style = "tabbed_pane_with_no_side_padding" })

    for name, data in pairs(Gui.tabs) do
        if (data.admin and player.admin) or (not data.admin) then
            local tab = tabbed_pane.add({ type = "tab", style = "tab", name = "SpawnTweaksTab:" .. name, caption = Func.CapitalizeWord(name) })
            local frame = tabbed_pane.add({ type = "frame", style = "invisible_frame", name = name, direction = data.direction })
            tabbed_pane.add_tab(tab, frame)
            global.players[player.name].frames[tab.name] = tab
            global.players[player.name].frames[frame.name] = tab
            data.func(frame)
        end
    end

    main_frame.force_auto_center()
end

function Gui.SpawnTweaksMainToggle(e)
    local player = game.get_player(e.player_index)

    if player.gui.screen["SpawnTweaksMain"] then
        player.gui.screen["SpawnTweaksMain"].destroy()
    else
        Gui.CreateSpawnTweaksMain(player)
    end
end

function Gui.DestroyGui(player)
    local gui_main = player.gui.screen["SpawnTweaksMain"]

    if gui_main ~= nil then
        gui_main.destroy()
    end
end

function Gui.CreateTopGui(player)
    local button_flow = mod_gui.get_button_flow(player)
    local button = button_flow.SpawnTweaksMainButton
    if not button then
        button =
            button_flow.add {
                type = "sprite-button",
                name = "SpawnTweaksMainButton",
                sprite = "SpawnTweaksIcon",
                style = mod_gui.button_style
            }
    end
    return button
end

function Gui.close(player)
    Gui.DestroyGui(player)
end

function Gui.CloseGui(e)
    local player = game.get_player(e.player_index)
    Gui.close(player)
end

function Gui.create(player)
    Gui.DestroyGui(player)

    local gui_button = player.gui.screen["SpawnTweaksMainButton"]
    if not gui_button then
        Gui.CreateTopGui(player)
    end
end

function Gui.OnGuiClosed(e)
    if not e.element then return end
    if e.element and e.element.get_mod() ~= "SpawnTweaks" then return end
    local player = game.get_player(e.player_index)
    player.opened = nil
    Gui.close(player)
end

function Gui.OnGuiEvent(e)
    if e.element.get_mod() ~= "SpawnTweaks" then return end

    local element_name = e.element.name
    local method = Func.Split(element_name, ":")[1]

    if global.gui_locked then return end

    if Gui.events[method] then
        Gui.events[method](e)
    end
end

function Gui.CreateAdminTab(frame, item_data)
    local player = game.get_player(frame.player_index)

    local frame0 = frame.add({ type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical" })
    frame0.style.horizontally_stretchable = "on"
    frame0.style.vertically_stretchable = true
    frame0.style.minimal_width = 300
    frame0.style.minimal_height = 400
    local frame1 = frame0.add({ type = "scroll-pane", style = "naked_scroll_pane", direction = "vertical" })
    frame1.style.horizontally_stretchable = "on"
    frame1.style.vertically_stretchable = "on"
    frame1.style.minimal_width = 300

    local column_count = 3
    if item_data == "Ammo" or item_data == "Capsule" then column_count = 4 end

    local flow = frame1.add({ type = "table", column_count = column_count })
    flow.style.vertically_stretchable = "on"

    if item_data == "Ammo" or item_data == "Capsule" then flow.add({ type = "label", caption = "Qty" }) end
    flow.add({ type = "label", caption = "Cost" })
    flow.add({ type = "label", caption = "" })
    flow.add({ type = "label", caption = "Item" })

    items = Gui.CreateData(player, item_data)
    for _, k1 in pairs(Func.sortKeys(items)) do
        local item = items[k1]
        local i_type
        if global.gear[item.type] and global.gear[item.type][item.name] then
            i_type = item.type
        elseif global.gear["capsule"] and global.gear["capsule"][item.name] then
            i_type = "capsule"
        end

        if item_data == "Ammo" or item_data == "Capsule" then
            local quantity = global.gear[i_type][item.name].quantity
            v = flow.add({ name = "Quantity:" .. item_data .. ":" .. item.name, type = "textfield", numeric = true, allow_negative = false, allow_decimal = false, text = quantity })
            v.style.maximal_width = 50
        end

        local cost = global.gear[i_type][item.name].cost
        v = flow.add({ name = "Cost:" .. item_data .. ":" .. item.name, type = "textfield", numeric = true, allow_negative = false, allow_decimal = false, text = cost })
        v.style.maximal_width = 50

        flow.add({ name = "Enabled:" .. item_data .. ":" .. item.name, type = "checkbox", state = global.gear[i_type][item.name].enabled, enabled = true })
        flow.add({ type = "label", caption = item.caption })
    end
end

Gui.admin_tabs = {
    admingun = { func = Gui.CreateAdminTab, direction = "vertical", admin = true, caption = "Gun" },
    adminammo = { func = Gui.CreateAdminTab, direction = "vertical", admin = true, caption = "Ammo" },
    adminarmor = { func = Gui.CreateAdminTab, direction = "vertical", admin = true, caption = "Armor" },
    admincapsule = { func = Gui.CreateAdminTab, direction = "vertical", admin = true, caption = "Capsule" }
}

Gui.tabs = {
    primary = { func = Gui.CreatePrimary, direction = "horizontal", admin = false },
    secondary = { func = Gui.CreateSecondary, direction = "horizontal", admin = false },
    misc = { func = Gui.CreateMisc, direction = "horizontal", admin = false },
    admin = { func = Gui.CreateAdmin, direction = "horizontal", admin = true }
}

Gui.events = {
    ["SpawnTweaksMainButton"] = Gui.SpawnTweaksMainToggle,
    ["SpawnTweaksMainClose"] = Gui.CloseGui,
    ["SpawnTweaksTab"] = Gui.SpawnTweaksTab,
    ["PickedPrimaryGun"] = Gui.PickedPrimaryGun,
    ["PickedSecondaryGun"] = Gui.PickedSecondaryGun,
    ["PickedPrimaryAmmo"] = Gui.PickedPrimaryAmmo,
    ["PickedSecondaryAmmo"] = Gui.PickedSecondaryAmmo,
    ["Picked"] = Gui.Picked,
    ["Enabled"] = Gui.Enabled,
    ["Cost"] = Gui.Cost,
    ["Quantity"] = Gui.Quantity
}

return Gui
