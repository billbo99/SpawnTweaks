local event = require("__flib__.event")
-- local gui = require("__flib__.gui")
local Gui = require("scripts.gui")
local DB = require("scripts.db")
local Func = require("scripts.func")
local migration = require("__flib__.migration")
local translation = require("__flib__.translation")
local constants = require("constants")

-- local constants = require("constants")
local global_data = require("scripts.global-data")
local on_tick = require("scripts.on-tick")
local player_data = require("scripts.player-data")

-- local main_gui = require("scripts.gui.main.base")

local function build_strings()
    local strings = {}
    local i = 0
    for category in pairs(constants.empty_translation_table) do
        for name, prototype in pairs(game[category .. "_prototypes"]) do
            i = i + 1
            strings[i] = { dictionary = category, internal = name, localised = prototype.localised_name }
        end
    end
    -- save to global
    global.strings = strings
end

event.on_init(
    function()
        if remote.interfaces["freeplay"] == nil then
            return
        end
        remote.call("freeplay", "set_skip_intro", true)

        -- gui.init()
        -- gui.build_lookup_tables()
        build_strings()
        translation.init()
        global_data.init()
        DB.OnInit()
        for _, player in pairs(game.players) do
            player_data.init(player)
            player_data.refresh(player, global.players[player.name])
        end
    end
)

event.on_load(
    function()
        -- gui.build_lookup_tables()
        on_tick.register()
    end
)

event.on_configuration_changed(
    function(e)
        DB.OnConfigurationChanged(e)
        global_data.OnConfigurationChanged(e)
    end
)

event.on_player_created(
    function(e)
        local player = game.get_player(e.player_index)
        player_data.init(player)

        local player_table = global.players[player.name]
        player_data.refresh(player, player_table)
        player.print(settings.global["SpawnTweaks-welcome"].value, global.print_colour)
        player_data.GiveGear(player)
    end
)

event.on_player_joined_game(
    function(e)
        local player = game.get_player(e.player_index)
        Gui.close(player)

        if not global.players[player.name] then
            player_data.init(player)
        end

        local player_table = global.players[player.name]
        if player_table.flags.translate_on_join then
            player_table.flags.translate_on_join = false
            player_data.start_translations(e.player_index)
        end
    end
)

event.on_player_left_game(
    function(e)
        local player = game.get_player(e.player_index)
        Gui.close(player)

        if translation.is_translating(e.player_index) then
            local player = game.get_player(e.player_index)
            translation.cancel(e.player_index)
            global.players[player.name].flags.translate_on_join = true
        end
    end
)
event.on_player_removed(
    function(e)
        local player = game.get_player(e.player_index)
        global.players[player.name] = nil
    end
)

event.on_runtime_mod_setting_changed(
    function(e)
        if game.mod_setting_prototypes[e.setting].mod == "SpawnTweaks" and e.setting_type == "runtime-per-user" then
            local player = game.get_player(e.player_index)
            local player_table = global.players[player.name]
            player_data.update_settings(player, player_table)
        end
    end
)

event.on_string_translated(
    function(e)
        local names, finished = translation.process_result(e)
        if names then
            local player = game.get_player(e.player_index)
            local player_table = global.players[player.name]
            local translations = player_table.translations
            for dictionary_name, internal_names in pairs(names) do
                local dictionary = translations[dictionary_name]
                for i = 1, #internal_names do
                    local internal_name = internal_names[i]
                    local result = e.translated and e.result or internal_name
                    dictionary[internal_name] = result
                end
            end
        end
        if finished then
            local player = game.get_player(e.player_index)
            local player_table = global.players[player.name]
            -- show message if needed
            if player_table.flags.show_message_after_translation then
                player.print { "SpawnTweaks-Messages.translations-done" }
            end
            -- create GUI
            -- main_gui.create(player, player_table)
            Gui.create(player)
            -- update flags
            player_table.flags.can_open_gui = true
            player_table.flags.translate_on_join = false -- not really needed, but is here just in case
            player_table.flags.show_message_after_translation = false
            -- update on_tick
            on_tick.register()
        end
    end
)

event.on_gui_text_changed(
    function(e)
        Gui.OnGuiEvent(e)
    end
)
event.on_gui_click(
    function(e)
        Gui.OnGuiEvent(e)
    end
)

event.on_research_finished(
    function(e)
        for _, player in pairs(game.players) do
            Gui.close(player)
        end
    end
)

event.register(defines.events.on_player_died,
    function(e)
        local player = game.get_player(e.player_index)
        player.ticks_to_respawn = settings.global["SpawnTweaks-respawn-multiplyer"].value * player.character.prototype.respawn_time * 60
    end
)

event.register(defines.events.on_player_respawned,
    function(e)
        local player = game.get_player(e.player_index)
        player_data.GiveGear(player)
        player.print(settings.global["SpawnTweaks-respawn"].value, global.print_colour)
    end
)

-- event.on_nth_tick(1800, OnTickDoCheckForSpawnGear)
