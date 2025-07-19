local loader = require "shared/recipe/loader";
local require_folder = require "shared/utils/require_folder";

---@alias not_crafting.class.grid {id: int, count: int}[]

local module = {
  ---@type table<str, (fun(grid: not_crafting.class.grid, recipe: not_crafting.class.recipe): int[] | nil)>
  engines = {}
};

---@param check fun(grid: not_crafting.class.grid, recipe: not_crafting.class.recipe): int[] | nil
function module.add_recipe_type(identifier, check)
  module.engines[identifier] = check;
end

function module.reload_recipes() loader.reload(module.engines) end

---@param craftblockid int
---@param grid not_crafting.class.grid
---@return int[] | nil, not_crafting.class.recipe | nil
function module.resolve_grid(craftblockid, grid)
  local props = block.properties[craftblockid];
  ---@type str[] | nil
  local prop = props["not_crafting:craft_types"];

  if not prop then return nil end;

  for _, recipe_type in ipairs(prop) do
    local recipes = loader.recipes[recipe_type];
    local engine = module.engines[recipe_type];

    if not engine then goto continue end

    for _, recipe in ipairs(recipes) do
      local slots = engine(grid, recipe);
      if slots then return slots, recipe end;
    end

    ::continue::
  end

  return nil;
end

function module.take_items(invid, slots)
  for _, slot in ipairs(slots) do
    inventory.decrement(invid, slot - 1, 1);
  end
end

---@param invid int
---@param ignored_slots int[] | nil
---@return not_crafting.class.grid
function module.get_grid(invid, ignored_slots)
  local grid = {};
  local invsize = inventory.size(invid);

  for i = 0, invsize - 1 do
    if not ignored_slots or not table.has(ignored_slots, i) then
      local itemid, count = inventory.get(invid, i);
      table.insert(grid, { id = itemid, count = count })
    end
  end

  return grid;
end

-- =========================init============================

local craft_types = require_folder "shared/recipe/craft_types";

events.on("not_crafting:hud_open", function()
  ---@type { id: str, check: function }[]

  for _, craft_type in ipairs(craft_types) do
    module.add_recipe_type(craft_type.id, craft_type.check);
  end

  module.reload_recipes();
end)

return module;
