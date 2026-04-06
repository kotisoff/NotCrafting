local loader = require "shared/recipe/loader";
local sync   = require "shared/recipe/sync"

local tags   = require "shared/utils/not_utils".tags;

---@alias not_crafting.class.grid {id: int, count: int}[]

local module = {
  ---@type table<str, (fun(grid: not_crafting.class.grid, recipe: not_crafting.class.recipe): table<int, int> | nil)>
  engines = {},
  compressed = {},
  ---@type int[]
  crafting_items = {}
};

---@param check fun(grid: not_crafting.class.grid, recipe: not_crafting.class.recipe): table<int, int> | nil
function module.add_recipe_type(identifier, check)
  module.engines[identifier] = check;
end

function module.reload_recipes()
  loader.reload(module.engines)
  sync.compress();
end

---@param craftblockid int
---@param grid not_crafting.class.grid
---@return table<int, int> | nil, not_crafting.class.recipe | nil
function module.resolve_grid(craftblockid, grid)
  local props = block.properties[craftblockid];
  ---@type { recipe_types: str[] }
  local prop = (props["not_crafting:crafting_block_data"] or {});
  local recipe_types = prop.recipe_types;

  if not recipe_types then return nil end;

  for _, recipe_type in ipairs(recipe_types) do
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

---@param invid int
---@param slots table<int, int>
function module.take_items(invid, slots)
  for slot, count in pairs(slots) do
    inventory.decrement(invid, slot - 1, count or 1); -- "or 1" потому что я себе не доверяю сука.
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

function module.is_crafting_item(itemid)
  if #module.crafting_items <= 0 then
    local default = item.index("base:bazalt_breaker");

    local items = tags.item.get_by_tags(false, "not_crafting:craft_item") or {};

    if #items <= 0 then
      items = { default };
    end

    module.crafting_items = items;
  end

  return table.has(module.crafting_items, itemid);
end

return module;
