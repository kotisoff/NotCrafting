--[[
  Спасибо боже, что существуют нейронки.
  Я бы своими силами это вряд-ли так быстро сделал.

  Функция matches_shaped_recipe я
]]

local PACK_ID = PACK_ID or "not_crafting"; local function resource(name) return PACK_ID .. ":" .. name end

recipe_loader = require(resource("recipe_loader"));
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

recipe_engine = {};

-- Виды рецептов. Пока есть только 2, будет пополняться.
local recipe_types = {
  shapeless = "minecraft:crafting_shapeless",
  shaped = "minecraft:crafting_shaped"
}

local function reverse_array(arr)
  local t = {};
  for key, value in ipairs(arr) do
    t[#arr - key + 1] = value;
  end
  return t;
end

local function matches_shaped_recipe(grid, recipe)
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

local function matches_shapeless_recipe(grid, recipe)
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

-- Функция для поиска и проверки рецептов
function recipe_engine.find_recipe(grid)
  for _, recipe in ipairs(recipe_loader.recipes) do
    if recipe.type == recipe_types.shapeless then
      local status, found_items = matches_shapeless_recipe(grid, recipe);
      if status then
        print("Recipe found.")
        return recipe, found_items
      end
    elseif recipe.type == recipe_types.shaped then
      local status, found_items = matches_shaped_recipe(grid, recipe);
      if status then
        print("Recipe found.")
        return recipe, found_items
      end
    end
  end
  print("Recipe not found.")
  return nil -- если рецепт не найден
end

function recipe_engine.check_crafting_grid(invid, result_slot_id)
  local grid = {}
  local invsize = inventory.size(invid);

  -- Slot ids are in range [0, invsize - 1].
  if not result_slot_id then result_slot_id = invsize end;

  for i = 0, invsize - 1, 1 do
    if i ~= result_slot_id then
      local itemid, _ = inventory.get(invid, i)
      table.insert(grid, { id = itemid, slot = i })
    end
  end

  return recipe_engine.find_recipe(grid)
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
