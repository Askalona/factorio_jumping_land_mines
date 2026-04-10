-- =============================================================
--  Jumping Mines — control.lua
--  Base range: 5 tiles  (+2 per range upgrade,    max 25)
--  Base delay: 60 ticks (-6 per activation upgrade, min 6)
--  Persistent upgrade: mines survive firing, go on cooldown
--  Base cooldown: 300 ticks (-30 per cooldown upgrade, min 30)
-- =============================================================

-- ─── Mine configuration table ────────────────────────────────
-- Maps mine entity name → {projectile, range_bonus}
-- range_bonus is added on top of the researched range.
-- SE mine entries are added at load / init time if SE is active.
local MINE_CONFIG = {
  ["jumping-mine"] = {
    projectile    = "jumping-mine-projectile",
    range_bonus   = 0,
    base_cooldown = 300,    -- 5 s
  },
  ["jumping-flame-mine"] = {
    projectile    = "jumping-flame-projectile",
    range_bonus   = 0,
    base_cooldown = 600,    -- 10 s
  },
  ["jumping-nuclear-mine"] = {
    projectile    = "jumping-nuclear-projectile",
    range_bonus   = 10,
    base_cooldown = 900,    -- 15 s
  },
  ["jumping-cryo-mine"] = {
    projectile    = "jumping-cryo-projectile",
    range_bonus   = 0,
    base_cooldown = 600,    -- 10 s
  },
  ["jumping-tritium-mine"] = {
    projectile    = "jumping-tritium-projectile",
    range_bonus   = 15,
    base_cooldown = 1200,   -- 20 s
  },
  ["jumping-antimatter-mine"] = {
    projectile    = "jumping-antimatter-projectile",
    range_bonus   = 20,
    base_cooldown = 1800,   -- 30 s
  },
}

local function register_se_mines() end  -- SE mines now built-in

-- ─── Constants ───────────────────────────────────────────────
local RANGE_BASE       = settings.startup["jm-base-range"].value
local RANGE_PER_LVL    = 2
local RANGE_MAX_LVL    = 10
local ARM_BASE         = 60
local ARM_STEP         = 6
local ARM_MAX_LVL      = 9
local COOLDOWN_BASE    = 300
local COOLDOWN_STEP    = 30
local COOLDOWN_MAX_LVL = 9
-- BATCH_SIZE is now a runtime-global setting: settings.global["jm-batch-size"].value

-- ─── Force-data cache ────────────────────────────────────────

local function compute_range(force)
  local level = 0
  for i = 1, RANGE_MAX_LVL do
    local tech = force.technologies["jumping-mines-range-" .. i]
    if tech and tech.researched then level = i else break end
  end
  return RANGE_BASE + level * RANGE_PER_LVL
end

local function compute_arm_ticks(force)
  local level = 0
  for i = 1, ARM_MAX_LVL do
    local tech = force.technologies["jumping-mines-activation-" .. i]
    if tech and tech.researched then level = i else break end
  end
  return math.max(6, ARM_BASE - level * ARM_STEP)
end

local function compute_persistent(force)
  if not settings.startup["jm-enable-persistent"].value then return false end
  local tech = force.technologies["jumping-mines-persistent"]
  return tech and tech.researched or false
end

local function compute_cooldown_level(force)
  local level = 0
  for i = 1, COOLDOWN_MAX_LVL do
    local tech = force.technologies["jumping-mines-cooldown-" .. i]
    if tech and tech.researched then level = i else break end
  end
  return level
end

-- Returns per-mine reload ticks: base_cooldown reduced by 5% per upgrade level.
-- Max 9 levels = −45%. Minimum = 10% of base.
local function reload_ticks_for(base_cooldown, cooldown_level)
  return math.max(
    math.floor(base_cooldown * 0.10),
    math.floor(base_cooldown * (1 - cooldown_level * 0.05))
  )
end

local function get_force_data(force)
  local cache = storage.force_cache
  local name  = force.name
  if not cache[name] then
    cache[name] = {
      range          = compute_range(force),
      arm_ticks      = compute_arm_ticks(force),
      persistent     = compute_persistent(force),
      cooldown_level = compute_cooldown_level(force),
    }
  end
  return cache[name]
end

-- ─── Mine registry ───────────────────────────────────────────
-- storage.mines      : uid → {entity, ready_tick}
-- storage.mine_ids   : ordered array of uids for batched scanning
-- storage.mine_cursor: current position in mine_ids

local function register_mine(entity, tick)
  local uid = entity.unit_number
  local fd  = get_force_data(entity.force)
  storage.mines[uid] = {
    entity     = entity,
    ready_tick = tick + fd.arm_ticks,
  }
  local ids = storage.mine_ids
  ids[#ids + 1] = uid
end

local function unregister_mine(uid)
  storage.mines[uid] = nil
  -- Physical removal from mine_ids happens lazily during the tick scan.
end

-- ─── Combat helpers ──────────────────────────────────────────

local function launch(mine, target, cfg)
  mine.surface.create_entity({
    name     = cfg.projectile,
    position = mine.position,
    target   = target,
    speed    = 0.35,
    source   = mine,
    force    = mine.force,
  })
end

-- Only the base jumping-mine creates a flare for the landmine-thrower.
local function create_mine_ghost(surface, position, force, mine_name)
  surface.create_entity({
    name       = "entity-ghost",
    inner_name = mine_name,
    position   = position,
    force      = force,
  })
  if mine_name == "jumping-mine" and script.active_mods["landmine-thrower"] then
    surface.create_entity({
      name           = "landmine-thrower-flare",
      position       = position,
      force          = force,
      frame_speed    = 0,
      vertical_speed = 0,
      height         = 0,
      movement       = {0, 0},
    })
  end
end

-- ─── Event filter ────────────────────────────────────────────
-- Filter by type to cover every land-mine variant without listing names.
local mine_type_filter = {{filter = "type", type = "land-mine"}}

-- ─── Build / placement handlers ──────────────────────────────

local function on_mine_built(event)
  local e = event.entity or event.created_entity
  if e and e.valid and MINE_CONFIG[e.name] then
    register_mine(e, event.tick)
  end
end

local function on_mine_died(event)
  local e = event.entity
  if e and MINE_CONFIG[e.name] then
    create_mine_ghost(e.surface, e.position, e.force, e.name)
    unregister_mine(e.unit_number)
  end
end

local function on_mine_mined(event)
  local e = event.entity
  if e and MINE_CONFIG[e.name] then
    unregister_mine(e.unit_number)
  end
end

script.on_event(defines.events.on_built_entity,       on_mine_built, mine_type_filter)
script.on_event(defines.events.on_robot_built_entity, on_mine_built, mine_type_filter)
script.on_event(defines.events.script_raised_built,   on_mine_built, mine_type_filter)
script.on_event(defines.events.script_raised_revive,  on_mine_built, mine_type_filter)

script.on_event(defines.events.on_entity_died,         on_mine_died,  mine_type_filter)
script.on_event(defines.events.on_player_mined_entity, on_mine_mined, mine_type_filter)
script.on_event(defines.events.on_robot_mined_entity,  on_mine_mined, mine_type_filter)
script.on_event(defines.events.script_raised_destroy,  on_mine_mined, mine_type_filter)

-- Invalidate force cache on any research completion.
-- Also enable persistent toggle by default when the tech is researched.
script.on_event(defines.events.on_research_finished, function(event)
  storage.force_cache = {}
  if event.research.name == "jumping-mines-persistent" then
    local force = event.research.force
    storage.force_persistent[force.name] = true
    if settings.startup["jm-enable-persistent"].value then
      for _, p in pairs(force.players) do
        p.set_shortcut_toggled("jumping-mines-persistent-toggle", true)
      end
    end
  end
end)

-- Toggle persistent mode per-force when shortcut is clicked.
script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= "jumping-mines-persistent-toggle" then return end
  local player = game.players[event.player_index]
  local fname  = player.force.name
  local new_state = not (storage.force_persistent[fname] or false)
  storage.force_persistent[fname] = new_state
  for _, p in pairs(player.force.players) do
    p.set_shortcut_toggled("jumping-mines-persistent-toggle", new_state)
  end
end)

-- Sync shortcut visual state when a player joins (e.g. multiplayer).
script.on_event(defines.events.on_player_joined_game, function(event)
  if not settings.startup["jm-enable-persistent"].value then return end
  local player = game.players[event.player_index]
  local state  = storage.force_persistent[player.force.name] or false
  player.set_shortcut_toggled("jumping-mines-persistent-toggle", state)
end)

-- ─── Lifecycle hooks ─────────────────────────────────────────

script.on_init(function()
  register_se_mines()
  storage.mines            = {}
  storage.mine_ids         = {}
  storage.mine_cursor      = 1
  storage.force_cache      = {}
  storage.force_persistent = {}
end)

script.on_load(function()
  register_se_mines()
end)

script.on_configuration_changed(function()
  register_se_mines()

  if not storage.mines            then storage.mines            = {} end
  if not storage.force_cache      then storage.force_cache      = {} end
  if not storage.force_persistent then storage.force_persistent = {} end
  storage.force_cache = {}  -- always refresh after any mod change

  -- Migrate old saves: arm_tick → ready_tick
  for _, entry in pairs(storage.mines) do
    if entry.arm_tick and not entry.ready_tick then
      entry.ready_tick = entry.arm_tick
      entry.arm_tick   = nil
    end
  end

  -- Rebuild mine_ids from the mines dict, pruning dead entries.
  local ids = {}
  for uid, entry in pairs(storage.mines) do
    if entry.entity and entry.entity.valid then
      ids[#ids + 1] = uid
    else
      storage.mines[uid] = nil
    end
  end

  -- Scan all surfaces for mines that lost registration (mod update / wipe).
  for _, surface in pairs(game.surfaces) do
    for _, mine in pairs(surface.find_entities_filtered{type = "land-mine"}) do
      if MINE_CONFIG[mine.name] then
        local uid = mine.unit_number
        if not storage.mines[uid] then
          storage.mines[uid] = {entity = mine, ready_tick = 1}
          ids[#ids + 1] = uid
        end
      end
    end
  end

  storage.mine_ids    = ids
  storage.mine_cursor = 1
end)

-- ─── Tick: batched mine scan ─────────────────────────────────
-- BATCH_SIZE mines are checked per tick, advancing a cursor.
-- Each mine is visited roughly every (#mines / BATCH_SIZE) ticks.
-- Removed/fired mines are swapped out with the tail element (O(1)).

script.on_event(defines.events.on_tick, function(event)
  local ids = storage.mine_ids
  if #ids == 0 then return end

  if not storage.mine_cursor then storage.mine_cursor = 1 end

  local tick   = event.tick
  local cursor = storage.mine_cursor
  local done   = 0
  local batch  = settings.global["jm-batch-size"].value

  while done < batch and #ids > 0 do
    if cursor > #ids then cursor = 1 end

    done = done + 1

    local uid   = ids[cursor]
    local entry = storage.mines[uid]

    if not entry or not entry.entity.valid then
      -- Lazy removal: swap with tail and shrink.
      storage.mines[uid] = nil
      ids[cursor] = ids[#ids]
      ids[#ids]   = nil
      if cursor > #ids then cursor = 1 end

    elseif tick >= entry.ready_tick then
      local mine = entry.entity
      local cfg  = MINE_CONFIG[mine.name]

      if not cfg then
        -- Unknown mine name (e.g. SE disabled mid-save) — skip silently.
        cursor = cursor + 1
      else
        local fdata       = get_force_data(mine.force)
        local total_range = fdata.range + cfg.range_bonus
        local enemy = mine.surface.find_nearest_enemy({
          position     = mine.position,
          max_distance = total_range,
          force        = mine.force,
        })

        if enemy then
          local pos, surf, force, mine_name =
            mine.position, mine.surface, mine.force, mine.name

          surf.create_entity({name = "explosion-hit", position = pos})
          launch(mine, enemy, cfg)

          local persistent_on = fdata.persistent
            and (storage.force_persistent[force.name] ~= false)
            and (storage.force_persistent[force.name] ~= nil)

          if persistent_on then
            -- Destroy silently and respawn in safe (visible) state.
            -- The mine is exposed to enemy attacks during its arm period.
            local reload = reload_ticks_for(cfg.base_cooldown, fdata.cooldown_level)
            mine.destroy()
            storage.mines[uid] = nil
            ids[cursor] = ids[#ids]; ids[#ids] = nil
            if cursor > #ids then cursor = 1 end
            local new_mine = surf.create_entity({
              name        = mine_name,
              position    = pos,
              force       = force,
              raise_built = false,
            })
            if new_mine and new_mine.valid then
              storage.mines[new_mine.unit_number] = {
                entity     = new_mine,
                ready_tick = tick + reload,
              }
              ids[#ids + 1] = new_mine.unit_number
            end
          else
            -- Mine is consumed after firing.
            mine.destroy()
            create_mine_ghost(surf, pos, force, mine_name)
            storage.mines[uid] = nil
            ids[cursor] = ids[#ids]
            ids[#ids]   = nil
            if cursor > #ids then cursor = 1 end
          end
        else
          cursor = cursor + 1
        end
      end

    else
      cursor = cursor + 1
    end
  end

  storage.mine_cursor = (#ids > 0) and cursor or 1
end)

-- =============================================================
--  Informatron integration
-- =============================================================
if script.active_mods["informatron"] then

  local function add_mine_row(element, sprite_name, caption)
    local flow = element.add{type = "flow", direction = "horizontal"}
    flow.style.vertical_align = "center"
    flow.style.top_margin     = 4
    -- Icon
    local icon = flow.add{type = "sprite", sprite = sprite_name}
    icon.style.size         = 32
    icon.style.right_margin = 8
    -- Text
    local lbl = flow.add{type = "label", caption = caption}
    lbl.style.single_line = false
  end

  local function page_content(data)
    local el          = data.element
    local page_name   = data.page_name
    local has_se      = script.active_mods["space-exploration"]
    local has_persist = settings.startup["jm-enable-persistent"].value

    if page_name == "jumping-mines" then
      el.add{type = "label", caption = {"jumping-mines-info.overview_text"}}.style.single_line = false

    elseif page_name == "jm-mines" then
      local header = has_persist and "jumping-mines-info.mines_header"
                                  or "jumping-mines-info.mines_header_no_persistent"
      el.add{type = "label", caption = {header}}.style.single_line = false
      el.add{type = "line",  direction = "horizontal"}
      local s = has_persist and "" or "_no_persistent"
      add_mine_row(el, "item/jumping-mine",         {"jumping-mines-info.mine_basic"          .. s})
      add_mine_row(el, "item/jumping-flame-mine",   {"jumping-mines-info.mine_flame"          .. s})
      add_mine_row(el, "item/jumping-nuclear-mine", {"jumping-mines-info.mine_nuclear"        .. s})
      if has_se then
        add_mine_row(el, "item/jumping-cryo-mine",       {"jumping-mines-info.mine_cryo"      .. s})
        add_mine_row(el, "item/jumping-tritium-mine",    {"jumping-mines-info.mine_tritium"   .. s})
        add_mine_row(el, "item/jumping-antimatter-mine", {"jumping-mines-info.mine_antimatter".. s})
      end

    elseif page_name == "jm-upgrades" then
      el.add{type = "label", caption = {"jumping-mines-info.upgrades_text"}}.style.single_line = false
      el.add{type = "line",  direction = "horizontal"}
      el.add{type = "label", caption = {"jumping-mines-info.upgrade_range"}}.style.single_line = false
      el.add{type = "label", caption = {"jumping-mines-info.upgrade_arm"}}.style.single_line   = false
      if has_persist then
        el.add{type = "label", caption = {"jumping-mines-info.upgrade_persistent"}}.style.single_line = false
        el.add{type = "label", caption = {"jumping-mines-info.upgrade_cooldown"}}.style.single_line   = false
      end

    elseif page_name == "jm-settings" then
      el.add{type = "label", caption = {"jumping-mines-info.settings_header"}}.style.single_line = false
      el.add{type = "line",  direction = "horizontal"}
      el.add{type = "label", caption = {"jumping-mines-info.settings_persistent"}}.style.single_line = false
      el.add{type = "label", caption = {"jumping-mines-info.settings_damage"}}.style.single_line     = false
      el.add{type = "label", caption = {"jumping-mines-info.settings_range"}}.style.single_line      = false
      el.add{type = "label", caption = {"jumping-mines-info.settings_batch"}}.style.single_line      = false
    end
  end

  remote.add_interface("jumping-mines", {
    informatron_menu = function(data)
      return {
        ["jm-mines"]    = 1,
        ["jm-upgrades"] = 1,
        ["jm-settings"] = 1,
      }
    end,
    informatron_page_content = function(data)
      page_content(data)
    end,
  })

end
