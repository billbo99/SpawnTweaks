local Gui = require("scripts.gui")
local DB = require("scripts.db")
local global_data = require("scripts.global-data")
local player_data = require("scripts.player-data")

local function GetTranslations()
    global.locale_dictionaries = remote.call("Babelfish", "get_translations")
    global.gui_locked = false
end

local function RegisterEvents()
    if remote.interfaces["Babelfish"] then
        local on_translations_complete_event = remote.call("Babelfish", "get_on_translations_complete_event")
        script.on_event(on_translations_complete_event, GetTranslations)
    end
end

local function OnInit()
    if remote.interfaces["freeplay"] == nil then
        return
    end
    remote.call("freeplay", "set_skip_intro", true)

    RegisterEvents()
    global_data.init()
    DB.OnInit()
    for _, player in pairs(game.players) do
        player_data.init(player)
    end
end

local function OnLoad()
    RegisterEvents()
end

---@param event ConfigurationChangedData
local function OnConfigurationChanged(event)
    RegisterEvents()
    global.gui_locked = true

    DB.OnConfigurationChanged(event)
    global_data.OnConfigurationChanged(event)

    for _, player in pairs(game.players) do
        player_data.validate(player)
    end
    game.print("Spawn Tweaks reset after mod configuration changed .. check your personal respawn settings")
end

---@param event EventData.on_player_created
local function OnPlayerCreated(event)
    local player = game.get_player(event.player_index)
    if player then
        player_data.init(player)
        player.print(settings.global["SpawnTweaks-welcome"].value, global.print_colour)
        player_data.GiveGear(player)
        Gui.create(player)
    end
end

---@param event EventData.on_player_joined_game
local function OnPlayerJoinedGame(event)
    local player = game.get_player(event.player_index)
    if player then
        Gui.create(player)
        if not global.players[player.name] then
            player_data.init(player)
        end
    end
end

---@param event EventData.on_player_left_game
local function OnPlayerLeftGame(event)
    local player = game.get_player(event.player_index)
    if player then Gui.close(player) end
end

---@param event EventData.on_player_removed
local function OnPlayerRemoved(event)
    local player = game.get_player(event.player_index)
    if player then global.players[player.name] = nil end
end

---@param event EventData.on_gui_text_changed
local function OnGuiTextChanged(event)
    Gui.OnGuiEvent(event)
end

---@param event EventData.on_gui_closed
local function OnGuiClosed(event)
    Gui.OnGuiClosed(event)
end

---@param event EventData.on_gui_click
local function OnGuiClick(event)
    Gui.OnGuiEvent(event)
end

---@param event EventData.on_research_finished
local function OnResearchFinished(event)
    for _, player in pairs(game.players) do
        Gui.close(player)
    end
end

---@param event EventData.on_player_died
local function OnPlayerDied(event)
    local player = game.get_player(event.player_index)
    if player then
        player.ticks_to_respawn = settings.global["SpawnTweaks-respawn-multiplyer"].value * player.character.prototype.respawn_time * 60
    end
end

---@param event EventData.on_player_respawned
local function OnPlayerRespawned(event)
    local player = game.get_player(event.player_index)
    if player then
        player_data.GiveGear(player)
        player.print(settings.global["SpawnTweaks-respawn"].value, global.print_colour)
    end
end

script.on_init(OnInit)
script.on_load(OnLoad)
script.on_configuration_changed(OnConfigurationChanged)
script.on_event(defines.events.on_player_created, OnPlayerCreated)
script.on_event(defines.events.on_player_joined_game, OnPlayerJoinedGame)
script.on_event(defines.events.on_player_left_game, OnPlayerLeftGame)
script.on_event(defines.events.on_player_removed, OnPlayerRemoved)
script.on_event(defines.events.on_gui_text_changed, OnGuiTextChanged)
script.on_event(defines.events.on_gui_click, OnGuiClick)
script.on_event(defines.events.on_gui_closed, OnGuiClosed)
script.on_event(defines.events.on_research_finished, OnResearchFinished)
script.on_event(defines.events.on_player_died, OnPlayerDied)
script.on_event(defines.events.on_player_respawned, OnPlayerRespawned)
