local loader            = require "shared/recipe/loader";
local require_folder    = require "shared/utils/require_folder";
local not_utils         = require "shared/utils/not_utils"
local recipe_compressor = require "shared/recipe/utils/recipe_compressor"
local packets           = require "shared/utils/declarations/packets"
local nc_events         = require "shared/utils/nc_events"
local _mp               = not_utils.multiplayer;
local mp                = _mp.api;
local log               = require "logger";

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

-- ==================recipes=compression====================

---@return bytearray
function module.compress_recipes()
  local compressed = {};
  for key, recipes in pairs(loader.recipes) do
    compressed[key] = {};
    local temp = compressed[key];
    for _, recipe in ipairs(recipes) do
      table.insert(temp, recipe_compressor.compress(recipe));
    end
  end

  return compressed
end

---@param compressed bytearray
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

-- =========================init============================

nc_events.on("first_tick", function()
  log.println("I", "Loading recipe types...");

  ---@type { id: str, check: function }[]
  local recipe_types = require_folder "shared/recipe/recipe_types";
  local keys = {};

  for _, value in ipairs(recipe_types) do
    table.insert(keys, value.id);
  end

  local addon_craft_types = setmetatable({}, {
    __index = {
      add = function(id, check)
        if type(id) == "string" and type(check) == "function" then
          if table.has(keys, id) then
            return log.log("E", string.format("Recipe type with '%s' id already exists!", id))
          end

          table.insert(recipe_types, { id = id, check = check });
        end
      end
    }
  })
  events.emit("not_crafting:load_recipe_types", addon_craft_types);

  for _, recipe_type in ipairs(recipe_types) do
    module.add_recipe_type(recipe_type.id, recipe_type.check);
  end;

  log.print();
  log.println("I", "Recipe types loading done.");

  _mp.as_server(function(server, mode)
    module.reload_recipes();

    if mode == "standalone" then return end;

    log.println("I", "Compressing recipes...");

    ---@type bytearray
    local compressed_recipes = module.compress_recipes();

    events.on("server:client_connected", function(client)
      mp.server.events.tell("not_crafting", packets.fetch_recipes, client, bjson.tobytes(compressed_recipes));
    end)
  end)

  _mp.as_client(function(client)
    print("client event");
    client.events.on("not_crafting", packets.fetch_recipes, function(bytes)
      log.println("I", string.format("Got %s bytes of recipes.", #bytes));
      local data = bjson.frombytes(bytes);
      loader.recipes = module.decompress_recipes(data);
    end)
  end)
end)

return module;
