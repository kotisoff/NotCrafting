local loader = require "shared/recipe/loader";
local require_folder = require "shared/utils/require_folder";

local module = {
  ---@type table<str, (fun(grid: {id: int, count: int}[], recipe: not_crafting.class.recipe): int[] | nil)>
  engines = {}
};

---@param check fun(grid: {id: int, count: int}[], recipe: not_crafting.class.recipe): int[] | nil
function module.add_recipe_type(identifier, check)
  module.engines[identifier] = check;
end

function module.reload_recipes() loader.reload(module.engines) end

---@param craftblockid int
---@param grid { id: int, count: int }[]
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
    inventory.decrement(invid, slot, 1);
  end
end

local craft_types = require_folder "shared/recipe/craft_types";

events.on("not_crafting:hud_open", function()
  ---@type { id: str, check: function }[]

  for _, craft_type in ipairs(craft_types) do
    module.add_recipe_type(craft_type.id, craft_type.check);
  end

  module.reload_recipes();

  local slots, recipe = module.resolve_grid(block.index("not_crafting:crafting_table"),
    { { id = block.index("base:wood"), count = 1 } });

  debug.print(recipe);
end)

return module;
