-- =============================================================
--  Jumping Mines — data-final-fixes.lua
--
--  Two independent sections:
--    1) Space Exploration mine types (cryo, tritium, antimatter)
--    2) landmine-thrower ammo conversion for all mine variants
-- =============================================================

-- =============================================================
--  SECTION 1 — Space Exploration integration
-- =============================================================
-- Only run if SE's cryo-ice simple-entity is actually present.
if data.raw["simple-entity"]["se-cryogun-ice"] then

  -- ── Radiation damage type (mirrors data.lua detection) ─────
  local radiation_type
  if data.raw["damage-type"]["kr-radioactive"] then
    radiation_type = "kr-radioactive"
  elseif data.raw["damage-type"]["jm-radioactive"] then
    radiation_type = "jm-radioactive"
  else
    radiation_type = "explosion"  -- fallback: treat as explosion
  end

  -- ── Shared helpers ─────────────────────────────────────────
  local function mine_picture_safe(name, scale)
    return {
      filename = "__jumping-mines__/graphics/entity/" .. name .. "/" .. name .. "-safe.png",
      priority = "medium",
      width    = 128,
      height   = 128,
      scale    = scale or 0.25,
    }
  end

  local function mine_picture_set(name, scale)
    return {
      filename = "__jumping-mines__/graphics/entity/" .. name .. "/" .. name .. "-set.png",
      priority = "medium",
      width    = 128,
      height   = 128,
      scale    = scale or 0.25,
    }
  end

  local mine_resistances = {
    {type = "fire",          percent = 100},
    {type = "explosion",     percent = 100},
    {type = "cold",          percent = 100},
    {type = radiation_type,  percent = 100},
  }

  -- ── Custom cryo-ice that drops nothing when mined ──────────
  local cryo_ice = util.table.deepcopy(data.raw["simple-entity"]["se-cryogun-ice"])
  cryo_ice.name    = "jumping-cryo-ice"
  cryo_ice.minable = nil   -- no ice drop on manual mining
  cryo_ice.loot    = nil   -- no ice drop on destruction/death
  data:extend({cryo_ice})

  -- ── Antimatter explosion entity names (K2 if present) ──────
  local am_expl_large  = data.raw.explosion["kr-large-matter-explosion"] and "kr-large-matter-explosion"  or "nuke-explosion"
  local am_expl_medium = data.raw.explosion["kr-matter-explosion"]       and "kr-matter-explosion"        or "nuke-explosion"
  local am_expl_small  = data.raw.explosion["kr-matter-explosion"]       and "kr-matter-explosion"        or "big-explosion"

  -- ── Entities ───────────────────────────────────────────────
  data:extend({

    -- jumping-cryo-mine
    {
      type             = "land-mine",
      name             = "jumping-cryo-mine",
      icon             = "__jumping-mines__/graphics/icons/jumping-cryo-mine.png",
      icon_size        = 128,
      flags            = {"placeable-player", "player-creation", "not-repairable"},
      minable          = {mining_time = 0.5, result = "jumping-cryo-mine"},
      max_health       = 50,
      corpse           = "small-remnants",
      collision_box    = {{-0.35, -0.35}, {0.35, 0.35}},
      selection_box    = {{-0.5, -0.5}, {0.5, 0.5}},
      is_military_target = true,
      resistances      = mine_resistances,
      picture_safe     = mine_picture_safe("jumping-cryo-mine"),
      picture_set      = mine_picture_set("jumping-cryo-mine"),
      timeout          = 60,
      trigger_radius   = 0,
      ammo_category    = "landmine",
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
          radius = 4,
          action_delivery = {
            type = "instant",
            target_effects = {
              {type = "damage",         damage = {amount = 200, type = "cold"}},
              {type = "create-sticker", sticker = "cryogun-sticker"},
            },
          },
        },
      },
    },

    -- jumping-tritium-mine
    {
      type             = "land-mine",
      name             = "jumping-tritium-mine",
      icon             = "__jumping-mines__/graphics/icons/jumping-tritium-mine.png",
      icon_size        = 128,
      flags            = {"placeable-player", "player-creation", "not-repairable"},
      minable          = {mining_time = 0.5, result = "jumping-tritium-mine"},
      max_health       = 50,
      corpse           = "small-remnants",
      collision_box    = {{-0.35, -0.35}, {0.35, 0.35}},
      selection_box    = {{-0.5, -0.5}, {0.5, 0.5}},
      is_military_target = true,
      resistances      = mine_resistances,
      picture_safe     = mine_picture_safe("jumping-tritium-mine", 0.3),
      picture_set      = mine_picture_set("jumping-tritium-mine", 0.3),
      timeout          = 60,
      trigger_radius   = 0,
      ammo_category    = "landmine",
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
                offset_deviation = {{-3.0, -3.0}, {3.0, 3.0}},
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
              {type = "damage", damage = {amount = 5000, type = "explosion"}},
              {type = "damage", damage = {amount = 5000, type = radiation_type}},
            },
          },
        },
      },
    },

    -- jumping-antimatter-mine
    {
      type             = "land-mine",
      name             = "jumping-antimatter-mine",
      icon             = "__jumping-mines__/graphics/icons/jumping-antimatter-mine.png",
      icon_size        = 128,
      flags            = {"placeable-player", "player-creation", "not-repairable"},
      minable          = {mining_time = 0.5, result = "jumping-antimatter-mine"},
      max_health       = 50,
      corpse           = "small-remnants",
      collision_box    = {{-0.35, -0.35}, {0.35, 0.35}},
      selection_box    = {{-0.5, -0.5}, {0.5, 0.5}},
      is_military_target = true,
      resistances      = mine_resistances,
      picture_safe     = mine_picture_safe("jumping-antimatter-mine", 0.3),
      picture_set      = mine_picture_set("jumping-antimatter-mine", 0.3),
      timeout          = 60,
      trigger_radius   = 0,
      ammo_category    = "landmine",
      action = {
        {
          type = "direct",
          action_delivery = {
            type = "instant",
            target_effects = {
              {type = "create-entity", entity_name = am_expl_large},
              {
                type             = "create-entity",
                entity_name      = am_expl_medium,
                offset_deviation = {{-3.0, -3.0}, {3.0, 3.0}},
              },
              {
                type             = "create-entity",
                entity_name      = am_expl_small,
                offset_deviation = {{-5.0, -5.0}, {5.0, 5.0}},
              },
            },
          },
        },
        {
          type = "area",
          radius = 25,
          action_delivery = {
            type = "instant",
            target_effects = {
              {type = "damage", damage = {amount = 12500, type = "explosion"}},
              {type = "damage", damage = {amount = 12500, type = radiation_type}},
            },
          },
        },
      },
    },

    -- ── Projectiles ──────────────────────────────────────────

    -- jumping-cryo-projectile
    {
      type           = "projectile",
      name           = "jumping-cryo-projectile",
      flags          = {"not-on-map"},
      acceleration   = 0,
      direction_only = false,
      max_speed      = 0.3,
      height         = 1,
      shadow = {
        filename       = "__base__/graphics/entity/grenade/grenade.png",
        priority       = "high",
        width          = 28,
        height         = 28,
        scale          = 0.6,
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
              -- Spawn ice walls around impact point
              {
                type             = "create-entity",
                entity_name      = "jumping-cryo-ice",
                offset_deviation = {{-1.5, -1.5}, {1.5, 1.5}},
              },
              {
                type             = "create-entity",
                entity_name      = "jumping-cryo-ice",
                offset_deviation = {{-2.5, -2.5}, {2.5, 2.5}},
              },
              {
                type             = "create-entity",
                entity_name      = "jumping-cryo-ice",
                offset_deviation = {{-3.0, -3.0}, {3.0, 3.0}},
              },
              {
                type             = "create-entity",
                entity_name      = "jumping-cryo-ice",
                offset_deviation = {{-3.5, -3.5}, {3.5, 3.5}},
              },
              {
                type             = "create-entity",
                entity_name      = "jumping-cryo-ice",
                offset_deviation = {{-4.0, -4.0}, {4.0, 4.0}},
              },
              {type = "create-entity", entity_name = "explosion-hit"},
            },
          },
        },
        {
          type = "area",
          radius = 4,
          action_delivery = {
            type = "instant",
            target_effects = {
              {type = "damage",         damage = {amount = 200, type = "cold"}},
              {type = "create-sticker", sticker = "cryogun-sticker"},
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

    -- jumping-tritium-projectile
    {
      type           = "projectile",
      name           = "jumping-tritium-projectile",
      flags          = {"not-on-map"},
      acceleration   = 0,
      direction_only = false,
      max_speed      = 0.25,
      height         = 1,
      shadow = {
        filename       = "__base__/graphics/entity/grenade/grenade.png",
        priority       = "high",
        width          = 28,
        height         = 28,
        scale          = 0.8,
        draw_as_shadow = true,
      },
      animation = {
        filename    = "__base__/graphics/entity/grenade/grenade.png",
        priority    = "high",
        width       = 28,
        height      = 28,
        frame_count = 1,
        scale       = 1.1,
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
                entity_name      = "nuke-explosion",
                offset_deviation = {{-2.0, -2.0}, {2.0, 2.0}},
              },
              {
                type             = "create-entity",
                entity_name      = "big-explosion",
                offset_deviation = {{-4.0, -4.0}, {4.0, 4.0}},
              },
              {
                type             = "create-entity",
                entity_name      = "big-explosion",
                offset_deviation = {{-6.0, -6.0}, {6.0, 6.0}},
              },
              {
                type             = "create-entity",
                entity_name      = "big-explosion",
                offset_deviation = {{-8.0, -8.0}, {8.0, 8.0}},
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
              {type = "damage", damage = {amount = 5000, type = "explosion"}},
              {type = "damage", damage = {amount = 5000, type = radiation_type}},
            },
          },
        },
        {
          type = "area",
          radius = 25,
          action_delivery = {
            type = "instant",
            target_effects = {
              {type = "damage", damage = {amount = 2000, type = "fire"}},
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

    -- jumping-antimatter-projectile
    {
      type           = "projectile",
      name           = "jumping-antimatter-projectile",
      flags          = {"not-on-map"},
      acceleration   = 0,
      direction_only = false,
      max_speed      = 0.2,
      height         = 1,
      shadow = {
        filename       = "__base__/graphics/entity/grenade/grenade.png",
        priority       = "high",
        width          = 28,
        height         = 28,
        scale          = 1.0,
        draw_as_shadow = true,
      },
      animation = {
        filename    = "__base__/graphics/entity/grenade/grenade.png",
        priority    = "high",
        width       = 28,
        height      = 28,
        frame_count = 1,
        scale       = 1.3,
      },
      action = {
        {
          type = "direct",
          action_delivery = {
            type = "instant",
            target_effects = {
              {type = "create-entity", entity_name = am_expl_large},
              {
                type             = "create-entity",
                entity_name      = am_expl_large,
                offset_deviation = {{-3.0, -3.0}, {3.0, 3.0}},
              },
              {
                type             = "create-entity",
                entity_name      = am_expl_medium,
                offset_deviation = {{-6.0, -6.0}, {6.0, 6.0}},
              },
              {
                type             = "create-entity",
                entity_name      = am_expl_small,
                offset_deviation = {{-5.0, -5.0}, {5.0, 5.0}},
              },
              {
                type             = "create-entity",
                entity_name      = am_expl_small,
                offset_deviation = {{-9.0, -9.0}, {9.0, 9.0}},
              },
              {
                type             = "create-entity",
                entity_name      = am_expl_small,
                offset_deviation = {{-13.0, -13.0}, {13.0, 13.0}},
              },
              {
                type             = "create-entity",
                entity_name      = am_expl_small,
                offset_deviation = {{-17.0, -17.0}, {17.0, 17.0}},
              },
            },
          },
        },
        {
          type = "area",
          radius = 25,
          action_delivery = {
            type = "instant",
            target_effects = {
              {type = "damage", damage = {amount = 12500, type = "explosion"}},
              {type = "damage", damage = {amount = 12500, type = radiation_type}},
            },
          },
        },
        {
          type = "area",
          radius = 30,
          action_delivery = {
            type = "instant",
            target_effects = {
              {type = "damage", damage = {amount = 5000, type = "fire"}},
              {type = "damage", damage = {amount = 5000, type = "explosion"}},
            },
          },
        },
      },
      final_action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          target_effects = {
            {type = "create-entity", entity_name = am_expl_large},
          },
        },
      },
    },

    -- ── Items ─────────────────────────────────────────────────

    {
      type         = "item",
      name         = "jumping-cryo-mine",
      icon         = "__jumping-mines__/graphics/icons/jumping-cryo-mine.png",
      icon_size    = 128,
      subgroup     = "defensive-structure",
      order        = "b[land-mine]-e[jumping-cryo-mine]",
      place_result = "jumping-cryo-mine",
      stack_size   = 100,
    },
    {
      type         = "item",
      name         = "jumping-tritium-mine",
      icon         = "__jumping-mines__/graphics/icons/jumping-tritium-mine.png",
      icon_size    = 128,
      subgroup     = "defensive-structure",
      order        = "b[land-mine]-f[jumping-tritium-mine]",
      place_result = "jumping-tritium-mine",
      stack_size   = 100,
    },
    {
      type         = "item",
      name         = "jumping-antimatter-mine",
      icon         = "__jumping-mines__/graphics/icons/jumping-antimatter-mine.png",
      icon_size    = 128,
      subgroup     = "defensive-structure",
      order        = "b[land-mine]-g[jumping-antimatter-mine]",
      place_result = "jumping-antimatter-mine",
      stack_size   = 100,
    },

    -- ── Recipes ───────────────────────────────────────────────

    {
      type             = "recipe",
      name             = "jumping-cryo-mine",
      enabled          = false,
      energy_required  = 15,
      ingredients = {
        {type = "item", name = "jumping-mine",    amount = 10},
        {type = "item", name = "se-cryonite-rod", amount = 1},
      },
      results = {
        {type = "item", name = "jumping-cryo-mine", amount = 10},
      },
    },
    (function()
      local tritium_item = nil
      if data.raw.item["kr-tritium"]  then tritium_item = "kr-tritium"
      elseif data.raw.item["se-tritium"] then tritium_item = "se-tritium"
      end
      local ingr = {
        {type = "item", name = "jumping-mine", amount = 10},
        {type = "item", name = "explosives",   amount = 40},
      }
      if tritium_item then
        ingr[#ingr + 1] = {type = "item", name = tritium_item, amount = 5}
      end
      return {
        type             = "recipe",
        name             = "jumping-tritium-mine",
        enabled          = false,
        energy_required  = 30,
        ingredients      = ingr,
        results = {
          {type = "item", name = "jumping-tritium-mine", amount = 10},
        },
      }
    end)(),
    {
      type             = "recipe",
      name             = "jumping-antimatter-mine",
      enabled          = false,
      energy_required  = 60,
      ingredients = {
        {type = "item", name = "jumping-mine",           amount = 10},
        {type = "item", name = "explosives",              amount = 100},
        {type = "item", name = "se-antimatter-canister",  amount = 5},
      },
      results = {
        {type = "item", name = "jumping-antimatter-mine", amount = 10},
      },
    },

  }) -- end data:extend for SE entities/projectiles/items/recipes

  -- ── Technologies ──────────────────────────────────────────

  -- jumping-cryo-mines
  local cryo_prereqs = {"jumping-mines"}
  if data.raw.technology["se-cryogun"] then
    cryo_prereqs[#cryo_prereqs + 1] = "se-cryogun"
  end
  data:extend({{
    type = "technology",
    name = "jumping-cryo-mines",
    icon = "__jumping-mines__/graphics/icons/jumping-cryo-mine.png",
    icon_size = 128,
    prerequisites = cryo_prereqs,
    unit = {
      count = 400,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"military-science-pack",   1},
        {"space-science-pack",      1},
      },
      time = 40,
    },
    effects = {
      {type = "unlock-recipe", recipe = "jumping-cryo-mine"},
    },
  }})

  -- jumping-tritium-mines
  local tritium_prereqs = {"jumping-nuclear-mines"}
  local fusion_tech =
    (data.raw.technology["kr-fusion-energy"]   and "kr-fusion-energy")   or
    (data.raw.technology["se-fusion-power"]    and "se-fusion-power")     or
    (data.raw.technology["se-space-thermodynamics-laboratory"] and "se-space-thermodynamics-laboratory")
  if fusion_tech then
    tritium_prereqs[#tritium_prereqs + 1] = fusion_tech
  end
  data:extend({{
    type = "technology",
    name = "jumping-tritium-mines",
    icon = "__jumping-mines__/graphics/icons/jumping-tritium-mine.png",
    icon_size = 128,
    prerequisites = tritium_prereqs,
    unit = {
      count = 800,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"military-science-pack",   1},
        {"space-science-pack",      1},
        {"utility-science-pack",    1},
      },
      time = 60,
    },
    effects = {
      {type = "unlock-recipe", recipe = "jumping-tritium-mine"},
    },
  }})

  -- jumping-antimatter-mines
  local antimatter_prereqs = {"jumping-tritium-mines"}
  if data.raw.technology["se-antimatter-production"] then
    antimatter_prereqs[#antimatter_prereqs + 1] = "se-antimatter-production"
  end
  data:extend({{
    type = "technology",
    name = "jumping-antimatter-mines",
    icon = "__jumping-mines__/graphics/icons/jumping-antimatter-mine.png",
    icon_size = 128,
    prerequisites = antimatter_prereqs,
    unit = {
      count = 1500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"military-science-pack",   1},
        {"space-science-pack",      1},
        {"utility-science-pack",    1},
      },
      time = 90,
    },
    effects = {
      {type = "unlock-recipe", recipe = "jumping-antimatter-mine"},
    },
  }})

end -- end SE section



-- =============================================================
--  SECTION 2 — landmine-thrower ammo conversion
-- =============================================================
-- Only run if landmine-thrower's ammo category is present.
if not data.raw["ammo-category"]["land-mine"] then return end

-- Helper: build an artillery projectile + convert one item to ammo.
-- mine_item_name  : the item prototype name
-- mine_entity_name: the land-mine entity the artillery shell spawns
local function convert_mine_to_thrower_ammo(mine_item_name, mine_entity_name)
  local item = data.raw.item[mine_item_name]
  -- If already converted to ammo (e.g. by a previous call), use that table.
  if not item then
    item = data.raw.ammo[mine_item_name]
  end
  if not item then return end  -- item not present (SE disabled, etc.)

  local proj_name = "thrower-" .. mine_entity_name

  -- Artillery projectile
  data:extend({{
    type       = "artillery-projectile",
    name       = proj_name,
    flags      = {"not-on-map"},
    reveal_map = false,
    map_color  = {r = 1, g = 1, b = 0},
    rotatable  = false,
    picture = {
      filename  = "__base__/graphics/entity/land-mine/land-mine.png",
      priority  = "medium",
      width     = 64,
      height    = 64,
      scale     = 0.5,
    },
    shadow = {
      filename  = "__landmine-thrower__/graphics/entity/hr-shell-shadow.png",
      width     = 64,
      height    = 64,
      scale     = 0.5,
    },
    chart_picture = {
      filename  = "__core__/graphics/empty.png",
      priority  = "extra-high",
      width     = 1,
      height    = 1,
    },
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type                  = "create-entity",
            entity_name           = mine_entity_name,
            trigger_created_entity = true,
            check_buildability    = true,
            show_in_tooltip       = true,
          },
        },
      },
    },
    height_from_ground = 280 / 64,
  }})

  -- Convert item → ammo
  item.type          = "ammo"
  item.ammo_category = "land-mine"
  item.ammo_type = {
    category    = "land-mine",
    target_type = "position",
    action = {
      type = "direct",
      action_delivery = {
        type               = "artillery",
        projectile         = proj_name,
        starting_speed     = 1,
        direction_deviation = 0,
        range_deviation    = 0,
        source_effects = {
          type        = "create-explosion",
          entity_name = "artillery-cannon-muzzle-flash",
        },
      },
    },
  }

  -- Re-register under "ammo" prototype; remove stale "item" entry.
  data:extend({item})
  data.raw.item[mine_item_name] = nil
end

-- ── Base jumping-mine (original, keep same behaviour) ────────
-- This mirrors the existing conversion from the old data-final-fixes.lua.
convert_mine_to_thrower_ammo("jumping-mine", "jumping-mine")

-- ── Additional mine variants ─────────────────────────────────
convert_mine_to_thrower_ammo("jumping-flame-mine",   "jumping-flame-mine")
convert_mine_to_thrower_ammo("jumping-nuclear-mine", "jumping-nuclear-mine")

-- SE mine variants (converted if present)
convert_mine_to_thrower_ammo("jumping-cryo-mine",      "jumping-cryo-mine")
convert_mine_to_thrower_ammo("jumping-tritium-mine",    "jumping-tritium-mine")
convert_mine_to_thrower_ammo("jumping-antimatter-mine", "jumping-antimatter-mine")
