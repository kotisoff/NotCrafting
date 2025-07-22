local loader            = require "shared/recipe/loader";
local require_folder    = require "shared/utils/require_folder";
local not_utils         = require "shared/utils/not_utils"
local recipe_compressor = require "shared/recipe/utils/recipe_compressor"
local mp                = not_utils.multiplayer.api;

---@alias not_crafting.class.grid {id: int, count: int}[]

local module            = {
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

---@param slots int[]
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

---@param grid not_crafting.class.grid
---@return [ [int, int, int][], int ]
function module.compress_grid(grid)
  local t_grid = {
    {},
    #grid
  };

  for slot, g_item in ipairs(grid) do
    if g_item.id > 0 then
      table.insert(t_grid[1], { g_item.id, g_item.count, slot });
    end
  end

  return t_grid;
end

---@param comp_grid [ [int, int, int][], int ]
function module.decompress_grid(comp_grid)
  local data, size = unpack(comp_grid);

  local grid = {};

  for slot = 1, size do
    local g_item;
    for _, value in ipairs(data) do
      local id, count, _slot = unpack(value);
      if slot == _slot then
        g_item = {
          id = id,
          count = count
        };
      end
    end

    table.insert(grid, g_item or { id = 0, count = 0 });
  end

  return grid;
end

function module.compress_recipes()
  local compressed = {};
  for key, recipes in pairs(loader.recipes) do
    compressed[key] = {};
    local temp = compressed[key];
    for _, recipe in ipairs(recipes) do
      table.insert(temp, recipe_compressor.compress(recipe));
    end
  end

  return compressed;
end

---@param compressed table<string, any[][]>
function module.decompress_recipes(compressed)
  local decompressed = {};
  for key, recipes in pairs(compressed) do
    decompressed[key] = {};
    local temp = decompressed[key];
    for _, recipe in ipairs(recipes) do
      table.insert(temp, recipe_compressor.decompress(recipe, key));
    end
  end

  return decompressed;
end

local function checkIntegrity(recipes1, recipes2)
  local max_integrity = 0;
  local integrity = 0;
  for key, recipes in pairs(recipes1) do
    for id, recipe in ipairs(recipes) do
      if recipes2[key][id].result.id == recipe.result.id then
        integrity = integrity + 1;
      end
      max_integrity = max_integrity + 1;
    end
  end

  print(string.format("integrity: %s", integrity / max_integrity * 100) .. "%")
end

-- =========================init============================

local craft_types = require_folder "shared/recipe/craft_types";

events.on("not_crafting:server_init", function()
  ---@type { id: str, check: function }[]

  for _, craft_type in ipairs(craft_types) do
    module.add_recipe_type(craft_type.id, craft_type.check);
  end

  local server = mp.server;

  module.reload_recipes();
  local data = server.bson.serialize(loader.recipes);
  print("original:", #data);
  local comp1 = module.compress_recipes();
  -- local comp1_comp = server.bson.serialize(comp1);
  local comp1_comp = bjson.tobytes(comp1);
  print("compressed:", #comp1_comp);
  local decomp = module.decompress_recipes(comp1);
  local decomp_comp = server.bson.serialize(decomp);
  print("decompressed:", #decomp_comp);
  checkIntegrity(loader.recipes, decomp);
end)

return module;
