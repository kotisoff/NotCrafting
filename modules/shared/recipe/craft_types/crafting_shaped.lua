local resource = require "shared/utils/resource_func";
local micro_logger = require "shared/recipe/utils/micro_logger";

local module = {};
module.id = resource("crafting_shaped");

---@param recipe not_crafting.class.recipe
---@param grid { id: int, count: int }[]
---@param offset vec2
local function check_match(recipe, grid, offset)
  local found_slots = {};
  local used_slots = {};

  local pattern = recipe.pattern;

  local p_h, p_w = #pattern, #pattern[1];
  local o_r, o_c = unpack(offset);
  local grid_row_size = math.sqrt(#grid);

  for row = 1, p_h do
    for col = 1, p_w do
      local char = pattern[row]:sub(col, col);
      local g_r = o_r + row - 1;
      local g_c = o_c + col - 1;
      local g_index = g_r * grid_row_size + g_c + 1; -- Единица тут для индексации с 1.

      local grid_item = grid[g_index];

      if char ~= " " then
        local key = recipe.key[char];
        if not grid_item or grid_item.id ~= key.item then
          return nil;
        end

        table.insert(found_slots, g_index);
        used_slots[g_index] = true;
      end
    end
  end

  for i = 1, #grid do
    if not used_slots[i] and grid[i].id ~= 0 then
      return nil;
    end
  end

  return found_slots;
end

---@param recipe { pattern: str[], key: table<str, {item: str}> }
function module.check(grid, recipe)
  local row_size = math.sqrt(#grid);

  if row_size % 1 ~= 0 then
    micro_logger:print("Wrong crafting grid size. Fix inventory size.");
    return nil;
  end

  local pattern = recipe.pattern;
  local p_h, p_w = #pattern, #pattern[1];

  for offset_r = 0, row_size - p_h do
    for offset_c = 0, row_size - p_w do
      local slots = check_match(recipe, grid, { offset_r, offset_c });
      if slots then return slots end;
    end
  end

  return nil;
end

return module;
