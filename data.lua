-- =============================================================
--  Jumping Mines — data.lua
-- =============================================================

-- ─── Radiation damage type ───────────────────────────────────
-- Use K2's kr-radioactive if present, otherwise define our own.
local radiation_type
if data.raw["damage-type"]["kr-radioactive"] then
  radiation_type = "kr-radioactive"
else
  data:extend({{type = "damage-type", name = "jm-radioactive"}})
  radiation_type = "jm-radioactive"
end

-- ─── Shared resistance table for all jumping mines ───────────
local mine_resistances = {
  {type = "fire",      percent = 100},
  {type = "explosion", percent = 100},
  {type = "cold",      percent = 100},
  {type = radiation_type, percent = 100},
}

-- ─── Visual pieces for mine sprites (128×128 HR art) ──────────
local function mine_picture_safe(scale, filename)
  scale = scale or 0.25
  return {
    filename = filename or "__base__/graphics/entity/land-mine/land-mine.png",
    priority = "medium",
    width    = 128,
    height   = 128,
    scale    = scale,
  }
end

local function mine_picture_set(scale, filename)
  scale = scale or 0.25
  return {
    filename = filename or "__base__/graphics/entity/land-mine/land-mine-set.png",
    priority = "medium",
    width    = 128,
    height   = 128,
    scale    = scale,
  }
end

-- =============================================================
data:extend({

-- ─────────────────────────────────────────────────────────────
--  ENTITIES
-- ─────────────────────────────────────────────────────────────

-- ── jumping-mine (base) ──────────────────────────────────────
{
  type             = "land-mine",
  name             = "jumping-mine",
  icon             = "__jumping-mines__/graphics/icons/jumping-mine.png",
  icon_size        = 128,
  flags            = {"placeable-player", "player-creation", "not-repairable"},
  minable          = {mining_time = 0.5, result = "jumping-mine"},
  max_health       = 50,
  corpse           = "small-remnants",
  collision_box    = {{-0.35, -0.35}, {0.35, 0.35}},
  selection_box    = {{-0.5, -0.5}, {0.5, 0.5}},
  is_military_target = true,
  resistances      = mine_resistances,
  picture_safe     = mine_picture_safe(0.25, "__jumping-mines__/graphics/entity/jumping-mine/jumping-mine-safe.png"),
  picture_set      = mine_picture_set(0.25, "__jumping-mines__/graphics/entity/jumping-mine/jumping-mine-set.png"),
  timeout          = 60,
  trigger_radius   = 0,
  ammo_category    = "landmine",
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "create-entity", entity_name = "medium-explosion"},
        },
      },
    },
    {
      type = "area",
      radius = 4,
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "damage", damage = {amount = 250, type = "explosion"}},
        },
      },
    },
  },
},

-- ── jumping-flame-mine ───────────────────────────────────────
{
  type             = "land-mine",
  name             = "jumping-flame-mine",
  icon             = "__jumping-mines__/graphics/icons/jumping-flame-mine.png",
  icon_size        = 128,
  flags            = {"placeable-player", "player-creation", "not-repairable"},
  minable          = {mining_time = 0.5, result = "jumping-flame-mine"},
  max_health       = 50,
  corpse           = "small-remnants",
  collision_box    = {{-0.35, -0.35}, {0.35, 0.35}},
  selection_box    = {{-0.5, -0.5}, {0.5, 0.5}},
  is_military_target = true,
  resistances      = mine_resistances,
  picture_safe     = mine_picture_safe(0.25, "__jumping-mines__/graphics/entity/jumping-flame-mine/jumping-flame-mine-safe.png"),
  picture_set      = mine_picture_set(0.25, "__jumping-mines__/graphics/entity/jumping-flame-mine/jumping-flame-mine-set.png"),
  timeout          = 60,
  trigger_radius   = 0,
  ammo_category    = "flamethrower",
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "create-entity", entity_name = "explosion-hit"},
        },
      },
    },
    {
      type = "area",
      radius = 5,
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "damage", damage = {amount = 100, type = "fire"}},
          {type = "create-sticker", sticker = "jumping-flame-slow"},
        },
      },
    },
  },
},

-- ── jumping-nuclear-mine ─────────────────────────────────────
{
  type             = "land-mine",
  name             = "jumping-nuclear-mine",
  icon             = "__jumping-mines__/graphics/icons/jumping-nuclear-mine.png",
  icon_size        = 128,
  flags            = {"placeable-player", "player-creation", "not-repairable"},
  minable          = {mining_time = 0.5, result = "jumping-nuclear-mine"},
  max_health       = 50,
  corpse           = "small-remnants",
  collision_box    = {{-0.35, -0.35}, {0.35, 0.35}},
  selection_box    = {{-0.5, -0.5}, {0.5, 0.5}},
  is_military_target = true,
  resistances      = mine_resistances,
  picture_safe     = mine_picture_safe(0.3, "__jumping-mines__/graphics/entity/jumping-nuclear-mine/jumping-nuclear-mine-safe.png"),
  picture_set      = mine_picture_set(0.3, "__jumping-mines__/graphics/entity/jumping-nuclear-mine/jumping-nuclear-mine-set.png"),
  timeout          = 60,
  trigger_radius   = 0,
  ammo_category    = "landmine",
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "create-entity", entity_name = "big-explosion"},
        },
      },
    },
    {
      type = "area",
      radius = 15,
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "damage", damage = {amount = 5000, type = "explosion"}},
        },
      },
    },
  },
},

-- (cryo / tritium / antimatter mines defined in data-final-fixes.lua)

-- ─────────────────────────────────────────────────────────────
--  STICKERS
-- ─────────────────────────────────────────────────────────────

-- ── jumping-flame-slow ────────────────────────────────────────
-- 80% movement slow (target_movement_modifier = 0.2) for 8 s.
-- Also deals 15 fire damage every 30 ticks.
{
  type                      = "sticker",
  name                      = "jumping-flame-slow",
  flags                     = {"not-on-map"},
  duration_in_ticks         = 480,
  target_movement_modifier  = 0.2,
  damage_interval           = 30,
  damage_per_interval       = {amount = 15, type = "fire"},
},


-- ─────────────────────────────────────────────────────────────
--  PROJECTILES
-- ─────────────────────────────────────────────────────────────

-- ── jumping-mine-projectile (base) ───────────────────────────
{
  type           = "projectile",
  name           = "jumping-mine-projectile",
  flags          = {"not-on-map"},
  acceleration   = 0,
  direction_only = false,
  max_speed      = 0.4,
  height         = 1,
  shadow = {
    filename     = "__base__/graphics/entity/grenade/grenade.png",
    priority     = "high",
    width        = 28,
    height       = 28,
    scale        = 0.6,
    draw_as_shadow = true,
  },
  animation = {
    filename    = "__base__/graphics/entity/grenade/grenade.png",
    priority    = "high",
    width       = 28,
    height      = 28,
    frame_count = 1,
    scale       = 0.8,
  },
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type             = "create-entity",
            entity_name      = "medium-explosion",
            offset_deviation = {{-0.25, -0.25}, {0.25, 0.25}},
          },
          {type = "create-entity", entity_name = "explosion-gunshot"},
        },
      },
    },
    {
      type = "area",
      radius = 4,
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "damage",         damage = {amount = 250, type = "explosion"}},
          {type = "create-sticker", sticker = "stun-sticker"},
        },
      },
    },
  },
  final_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {type = "create-entity", entity_name = "medium-explosion"},
      },
    },
  },
},

-- ── jumping-flame-projectile ─────────────────────────────────
{
  type           = "projectile",
  name           = "jumping-flame-projectile",
  flags          = {"not-on-map"},
  acceleration   = 0,
  direction_only = false,
  max_speed      = 0.4,
  height         = 1,
  shadow = {
    filename     = "__base__/graphics/entity/grenade/grenade.png",
    priority     = "high",
    width        = 28,
    height       = 28,
    scale        = 0.6,
    draw_as_shadow = true,
  },
  animation = {
    filename    = "__base__/graphics/entity/grenade/grenade.png",
    priority    = "high",
    width       = 28,
    height      = 28,
    frame_count = 1,
    scale       = 0.8,
  },
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          -- Spawn fire patches at impact
          {
            type             = "create-entity",
            entity_name      = "fire-flame",
            offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
          },
          {
            type             = "create-entity",
            entity_name      = "fire-flame",
            offset_deviation = {{-1.0, -1.0}, {1.0, 1.0}},
          },
          {
            type             = "create-entity",
            entity_name      = "fire-flame",
            offset_deviation = {{-1.5, -1.5}, {1.5, 1.5}},
          },
          {
            type             = "create-entity",
            entity_name      = "fire-flame",
            offset_deviation = {{-2.0, -2.0}, {2.0, 2.0}},
          },
          {type = "create-entity", entity_name = "explosion-hit"},
        },
      },
    },
    {
      type = "area",
      radius = 5,
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "damage",         damage = {amount = 100, type = "fire"}},
          {type = "create-sticker", sticker = "jumping-flame-slow"},
        },
      },
    },
  },
  final_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {type = "create-entity", entity_name = "explosion-hit"},
      },
    },
  },
},

-- ── jumping-nuclear-projectile ───────────────────────────────
{
  type           = "projectile",
  name           = "jumping-nuclear-projectile",
  flags          = {"not-on-map"},
  acceleration   = 0,
  direction_only = false,
  max_speed      = 0.3,
  height         = 1,
  shadow = {
    filename     = "__base__/graphics/entity/grenade/grenade.png",
    priority     = "high",
    width        = 28,
    height       = 28,
    scale        = 0.8,
    draw_as_shadow = true,
  },
  animation = {
    filename    = "__base__/graphics/entity/grenade/grenade.png",
    priority    = "high",
    width       = 28,
    height      = 28,
    frame_count = 1,
    scale       = 1.0,
  },
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "create-entity", entity_name = "nuke-explosion"},
          {
            type             = "create-entity",
            entity_name      = "big-explosion",
            offset_deviation = {{-2.0, -2.0}, {2.0, 2.0}},
          },
          {
            type             = "create-entity",
            entity_name      = "big-explosion",
            offset_deviation = {{-4.0, -4.0}, {4.0, 4.0}},
          },
        },
      },
    },
    {
      type = "area",
      radius = 15,
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "damage", damage = {amount = 2500, type = "explosion"}},
          {type = "damage", damage = {amount = 2500, type = radiation_type}},
          {
            type             = "create-entity",
            entity_name      = "medium-explosion",
            offset_deviation = {{-7, -7}, {7, 7}},
          },
        },
      },
    },
    {
      type = "area",
      radius = 20,
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "damage", damage = {amount = 500, type = "fire"}},
        },
      },
    },
  },
  final_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {type = "create-entity", entity_name = "nuke-explosion"},
      },
    },
  },
},


-- ─────────────────────────────────────────────────────────────
--  ITEMS
-- ─────────────────────────────────────────────────────────────

{
  type         = "item",
  name         = "jumping-mine",
  icon         = "__jumping-mines__/graphics/icons/jumping-mine.png",
  icon_size    = 128,
  subgroup     = "defensive-structure",
  order        = "b[land-mine]-b[jumping-mine]",
  place_result = "jumping-mine",
  stack_size   = 100,
},
{
  type         = "item",
  name         = "jumping-flame-mine",
  icon         = "__jumping-mines__/graphics/icons/jumping-flame-mine.png",
  icon_size    = 128,
  subgroup     = "defensive-structure",
  order        = "b[land-mine]-c[jumping-flame-mine]",
  place_result = "jumping-flame-mine",
  stack_size   = 100,
},
{
  type         = "item",
  name         = "jumping-nuclear-mine",
  icon         = "__jumping-mines__/graphics/icons/jumping-nuclear-mine.png",
  icon_size    = 128,
  subgroup     = "defensive-structure",
  order        = "b[land-mine]-d[jumping-nuclear-mine]",
  place_result = "jumping-nuclear-mine",
  stack_size   = 100,
},


-- ─────────────────────────────────────────────────────────────
--  RECIPES
-- ─────────────────────────────────────────────────────────────

-- Conversion: vanilla land-mine → jumping-mine
{
  type             = "recipe",
  name             = "jumping-mine-from-landmine",
  enabled          = false,
  energy_required  = 5,
  ingredients = {
    {type = "item", name = "land-mine",          amount = 1},
    {type = "item", name = "electronic-circuit", amount = 1},
  },
  results = {
    {type = "item", name = "jumping-mine", amount = 1},
  },
},

-- Craft from scratch
{
  type             = "recipe",
  name             = "jumping-mine",
  enabled          = false,
  energy_required  = 5,
  ingredients = {
    {type = "item", name = "iron-plate",         amount = 2},
    {type = "item", name = "explosives",          amount = 2},
    {type = "item", name = "electronic-circuit", amount = 1},
  },
  results = {
    {type = "item", name = "jumping-mine", amount = 2},
  },
},

{
  type             = "recipe",
  name             = "jumping-flame-mine",
  enabled          = false,
  energy_required  = 10,
  ingredients = {
    {type = "item", name = "jumping-mine",    amount = 10},
    {type = "item", name = "flamethrower-ammo", amount = 1},
  },
  results = {
    {type = "item", name = "jumping-flame-mine", amount = 10},
  },
},

{
  type             = "recipe",
  name             = "jumping-nuclear-mine",
  enabled          = false,
  energy_required  = 20,
  ingredients = {
    {type = "item", name = "jumping-mine", amount = 10},
    {type = "item", name = "explosives",   amount = 20},
    {type = "item", name = "uranium-235",  amount = 1},
  },
  results = {
    {type = "item", name = "jumping-nuclear-mine", amount = 10},
  },
},


-- ─────────────────────────────────────────────────────────────
--  BASE TECHNOLOGY
-- ─────────────────────────────────────────────────────────────

{
  type = "technology",
  name = "jumping-mines",
  icon = "__jumping-mines__/graphics/icons/jumping-mine.png",
  icon_size = 128,
  prerequisites = {"land-mine", "military-2"},
  unit = {
    count = 150,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack",   1},
      {"military-science-pack",   1},
    },
    time = 20,
  },
  effects = {
    {type = "unlock-recipe", recipe = "jumping-mine"},
    {type = "unlock-recipe", recipe = "jumping-mine-from-landmine"},
  },
},

-- ─────────────────────────────────────────────────────────────
--  FLAME AND NUCLEAR TECHNOLOGIES
-- ─────────────────────────────────────────────────────────────

{
  type = "technology",
  name = "jumping-flame-mines",
  icon = "__jumping-mines__/graphics/icons/jumping-flame-mine.png",
  icon_size = 128,
  prerequisites = {"jumping-mines", "flammables"},
  unit = {
    count = 200,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack",   1},
      {"military-science-pack",   1},
    },
    time = 25,
  },
  effects = {
    {type = "unlock-recipe", recipe = "jumping-flame-mine"},
  },
},

{
  type = "technology",
  name = "jumping-nuclear-mines",
  icon = "__jumping-mines__/graphics/icons/jumping-nuclear-mine.png",
  icon_size = 128,
  prerequisites = {"jumping-mines", "atomic-bomb"},
  unit = {
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack",   1},
      {"military-science-pack",   1},
      {"utility-science-pack",    1},
    },
    time = 30,
  },
  effects = {
    {type = "unlock-recipe", recipe = "jumping-nuclear-mine"},
  },
},


-- ─────────────────────────────────────────────────────────────
--  PERSISTENT MINE TECHNOLOGY
-- ─────────────────────────────────────────────────────────────

{
  type = "technology",
  name = "jumping-mines-persistent",
  icon = "__base__/graphics/icons/land-mine.png",
  icon_size = 64,
  prerequisites = {"jumping-mines", "military-4", "atomic-bomb"},
  unit = {
    count = 600,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack",   1},
      {"military-science-pack",   1},
      {"utility-science-pack",    1},
    },
    time = 60,
  },
  effects = {
    {
      type = "nothing",
      effect_description = {"technology-description.jumping-mines-persistent"},
    },
  },
},

-- ── Shortcut: toggle persistent mode ─────────────────────────
{
  type                  = "shortcut",
  name                  = "jumping-mines-persistent-toggle",
  order                 = "z[jumping-mines]-a",
  action                = "lua",
  toggleable            = true,
  technology_to_unlock  = "jumping-mines-persistent",
  icon            = "__jumping-mines__/graphics/icons/shortcut-persistent.png",
  icon_size       = 32,
  small_icon      = "__jumping-mines__/graphics/icons/shortcut-persistent.png",
  small_icon_size = 32,
},

}) -- end data:extend


-- =============================================================
--  Range upgrades — 10 levels, +2 tiles each (base 5 → max 25)
-- =============================================================
local range_techs = {}
for i = 1, 10 do
  range_techs[i] = {
    type = "technology",
    name = "jumping-mines-range-" .. i,
    icon = "__base__/graphics/icons/land-mine.png",
    icon_size = 64,
    prerequisites = (i == 1) and {"jumping-mines"} or {"jumping-mines-range-" .. (i - 1)},
    unit = {
      count = 100 * i,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"military-science-pack",   1},
      },
      time = 20,
    },
    effects = {
      {
        type = "nothing",
        effect_description = {"technology-description.jumping-mines-range-upgrade"},
      },
    },
  }
end
data:extend(range_techs)

-- =============================================================
--  Activation-time upgrades — 9 levels
--  60 ticks (1.0 s) → 6 ticks (0.1 s), step −6 ticks each
-- =============================================================
local arm_techs = {}
for i = 1, 9 do
  arm_techs[i] = {
    type = "technology",
    name = "jumping-mines-activation-" .. i,
    icon = "__base__/graphics/icons/land-mine.png",
    icon_size = 64,
    prerequisites = (i == 1) and {"jumping-mines"} or {"jumping-mines-activation-" .. (i - 1)},
    unit = {
      count = 150 * i,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"military-science-pack",   1},
      },
      time = 25,
    },
    effects = {
      {
        type = "nothing",
        effect_description = {"technology-description.jumping-mines-activation-upgrade"},
      },
    },
  }
end
data:extend(arm_techs)

-- =============================================================
--  Cooldown upgrades — 9 levels
--  300 ticks (5.0 s) → 30 ticks (0.5 s), step −30 ticks each
-- =============================================================
local cooldown_techs = {}
for i = 1, 9 do
  cooldown_techs[i] = {
    type = "technology",
    name = "jumping-mines-cooldown-" .. i,
    icon = "__base__/graphics/icons/land-mine.png",
    icon_size = 64,
    prerequisites = (i == 1)
      and {"jumping-mines-persistent"}
      or  {"jumping-mines-cooldown-" .. (i - 1)},
    unit = {
      count = 200 * i,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"military-science-pack",   1},
        {"utility-science-pack",    1},
      },
      time = 30,
    },
    effects = {
      {
        type = "nothing",
        effect_description = {"technology-description.jumping-mines-cooldown-upgrade"},
      },
    },
  }
end
data:extend(cooldown_techs)
