local PACK_ID = PACK_ID or "not_crafting";

local recipe_loader = require "recipe/loader";
--[[
Примеры рецептов.
{
  {
  "type": "minecraft:crafting_shaped",
  "category": "misc",
  "key": {
    "#": {
      "item": "base:planks"
    }
  },
  "pattern": ["##", "##"],
  "result": {
    "count": 1,
    "id": "not_crafting:crafting_table"
  },
  "show_notification": false
  },
  {
  "type": "minecraft:crafting_shaped",
  "category": "misc",
  "key": {
    "#": {
      "item": "base:planks"
    }
  },
  "pattern": ["#", "#"],
  "result": {
    "count": 4,
    "id": "not_survival:stick"
  },
  "show_notification": false
  }
}
]]

local recipe_engine = {};

-- Виды рецептов. Пока есть только 3, будет пополняться.
recipe_engine.recipe_types = {
  shapeless = { "minecraft:crafting_shapeless", "crafting_shapeless" },
  shaped = { "minecraft:crafting_shaped", "crafting_shaped" },
  smelting = { "minecraft:smelting", "smelting" }
}

local function types_key(type)
  for key, value in pairs(recipe_engine.recipe_types) do
    if table.has(value, type) then return key end
  end
  return nil;
end

local function reverse_array(arr)
  local t = {};
  for key, value in ipairs(arr) do
    t[#arr - key + 1] = value;
  end
  return t;
end

local matches = {};

matches["shaped"] = function(grid, recipe)
  local pattern = reverse_array(recipe.pattern);
  local pattern_height = #pattern
  local pattern_width = #pattern[1]

  local grid_row_size = math.sqrt(#grid);
  if grid_row_size % 1 ~= 0 then
    print("[" .. PACK_ID .. "] Wrong crafting grid size. Fix inventory size.")
  end

  -- Функция для проверки соответствия рецепта с учетом смещения
  local function check_match(offset_row, offset_col)
    local found_items = {}
    local used_indices = {}

    for row = 1, pattern_height do
      for col = 1, pattern_width do
        local pattern_char = pattern[row]:sub(col, col)
        local grid_row = offset_row + (row - 1)
        local grid_col = offset_col + (col - 1)
        local grid_index = grid_row * grid_row_size + grid_col + 1 -- Индексация с 1 для Lua
        local grid_item = grid[grid_index]

        if pattern_char ~= " " then
          local pattern_key = recipe.key[pattern_char]
          if not grid_item or grid_item.id ~= pattern_key.item then
            return false, nil
          end
          table.insert(found_items, grid_item)
          used_indices[grid_index] = true
        end
      end
    end

    -- Проверяем, что в неиспользуемых слотах нет других предметов
    for index = 1, #grid do
      if not used_indices[index] and grid[index].id ~= 0 then
        return false, nil
      end
    end

    return true, found_items
  end

  -- Проверяем все возможные смещения в сетке
  for offset_row = 0, grid_row_size - pattern_height do
    for offset_col = 0, grid_row_size - pattern_width do
      local match, found_items = check_match(offset_row, offset_col)
      if match then
        return true, found_items
      end
    end
  end

  return false, nil
end

matches["shapeless"] = function(grid, recipe)
  local ingredients = recipe.ingredients;

  local grid_items = {}

  -- Собираем все доступные предметы из сетки
  for _, slot in ipairs(grid) do
    if slot then
      table.insert(grid_items, slot)
    end
  end

  local items = {};
  for i, value in pairs(grid_items) do
    if value.id ~= 0 then
      table.insert(items, value);
    end
  end
  grid_items = items;

  -- Проверяем соответствие каждого ингредиента
  local found_items = {};
  for _, ingredient in ipairs(ingredients) do
    local found = false
    for i, grid_item in ipairs(grid_items) do
      if grid_item.id == ingredient.item then
        found = true
        table.insert(found_items, grid_item);
        table.remove(grid_items, i) -- Убедившись, что ингредиент используется только раз
        break
      end
    end
    if not found then return false, nil end
  end

  -- Условие необходимости пустого остатка: все использованные предметы удалены
  return #grid_items == 0, found_items
end

matches["smelting"] = function(grid, recipe)
  local ingredient = recipe.ingredient;

  for _, value in pairs(grid) do
    if value.id == ingredient.item then
      return true, { value }
    end
  end
  return false, nil;
end

-- Функция для поиска и проверки рецептов
function recipe_engine.find_recipe(grid, types_filter)
  local filtered_types = {};
  if types_filter then
    for _, filter in pairs(types_filter) do
      local key = types_key(filter);
      if key then
        filtered_types[key] = recipe_engine.recipe_types[key]
      elseif recipe_engine.recipe_types[filter] then
        filtered_types[filter] = recipe_engine.recipe_types[filter]
      end
    end
  else
    filtered_types = recipe_engine.recipe_types
  end

  for _, recipe in ipairs(recipe_loader.recipes) do
    for key, types in pairs(filtered_types) do
      if table.has(types, recipe.type) then
        local status, found = matches[key](grid, recipe);
        if status then
          return recipe, found;
        end
      end
    end
  end
  return nil -- если рецепт не найден
end

function recipe_engine.check_crafting_grid(invid, ignored_slots, types_filter)
  local grid = {}
  local invsize = inventory.size(invid);

  if type(ignored_slots) == "number" then ignored_slots = { ignored_slots } end
  if not ignored_slots then ignored_slots = { -1 } end;

  for i = 0, invsize - 1, 1 do
    if not table.has(ignored_slots, i) then
      local itemid, _ = inventory.get(invid, i)
      table.insert(grid, { id = itemid, slot = i })
    end
  end

  return recipe_engine.find_recipe(grid, types_filter)
end

function recipe_engine.take_items(invid, found_items)
  for _, item in ipairs(found_items) do
    local _, count = inventory.get(invid, item.slot);
    inventory.set(
      invid,
      item.slot,
      item.id,
      count - 1
    )
  end
end

return recipe_engine
