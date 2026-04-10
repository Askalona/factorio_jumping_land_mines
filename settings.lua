-- =============================================================
--  Jumping Mines — settings.lua
-- =============================================================

data:extend({

  -- ── Persistent Mode toggle ───────────────────────────────────
  -- Hides the Persistent Mode technology and shortcut when disabled.
  {
    type          = "bool-setting",
    name          = "jm-enable-persistent",
    setting_type  = "startup",
    default_value = true,
    order         = "a",
  },

  -- ── Damage multiplier ────────────────────────────────────────
  -- Applied to all mine projectile damage amounts.
  {
    type          = "double-setting",
    name          = "jm-damage-modifier",
    setting_type  = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    maximum_value = 10.0,
    order         = "b",
  },

  -- ── Base detection range ─────────────────────────────────────
  -- Starting range before any research upgrades.
  {
    type          = "int-setting",
    name          = "jm-base-range",
    setting_type  = "startup",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 30,
    order         = "c",
  },

  -- ── Batch size (runtime) ─────────────────────────────────────
  -- Mines scanned per tick in on_tick. Changeable without restart.
  {
    type          = "int-setting",
    name          = "jm-batch-size",
    setting_type  = "runtime-global",
    default_value = 100,
    minimum_value = 10,
    maximum_value = 1000,
    order         = "d",
  },

})
