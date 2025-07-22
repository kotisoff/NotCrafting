local CATEGORY_DICT = {
  "misc"
}

local GROUPS = {
  "planks", "wood"
}

local function compress_recipe(recipe)
  local compressed = {}

  -- Обязательные поля
  compressed[1] = table.index(CATEGORY_DICT, recipe.category)
  compressed[2] = recipe.result.id

  -- Опциональные поля с битовой маской
  local flags = 0
  local flag_index = 0

  -- Функция для установки флага
  local function set_flag(condition)
    if condition then
      flags = bit.bor(flags, bit.lshift(1, flag_index))
    end
    flag_index = flag_index + 1
  end

  -- Проверяем опциональные поля
  set_flag(recipe.group)
  set_flag(recipe.cookingtime)
  set_flag(recipe.experience)
  set_flag(recipe.show_notification == false)
  set_flag(recipe.result.count and recipe.result.count ~= 1)
  set_flag(recipe.pattern)
  set_flag(recipe.key or recipe.ingredients or recipe.ingredient)

  compressed[3] = flags

  -- Добавляем опциональные поля, если они есть
  local index = 4

  if recipe.group then
    compressed[index] = table.index(GROUPS, recipe.group);
    index = index + 1
  end

  if recipe.cookingtime then
    compressed[index] = recipe.cookingtime
    index = index + 1
  end

  if recipe.experience then
    compressed[index] = recipe.experience
    index = index + 1
  end

  if recipe.result.count and recipe.result.count ~= 1 then
    compressed[index] = recipe.result.count
    index = index + 1
  end

  -- Обрабатываем ингредиенты
  if recipe.key or recipe.ingredients or recipe.ingredient then
    local ingredients = {}
    local ingredient_list = recipe.ingredients or
        (recipe.ingredient and { recipe.ingredient }) or
        (recipe.key and (function()
          local list = {}
          for _, v in pairs(recipe.key) do
            table.insert(list, v)
          end
          return list
        end)())

    for _, ing in ipairs(ingredient_list) do
      local compressed_ing = {}

      if ing.item then
        compressed_ing[1] = ing.item
      else
        compressed_ing[1] = -1
        compressed_ing[2] = ing.tag
      end

      if ing.count and ing.count ~= 1 then
        compressed_ing[3] = ing.count
      end

      table.insert(ingredients, compressed_ing)
    end

    compressed[index] = ingredients
    index = index + 1

    -- Добавляем pattern, если есть
    if recipe.pattern then
      compressed[index] = recipe.pattern
      index = index + 1
    end
  end

  return compressed
end

local function decompress_recipe(compressed, type)
  local recipe = {
    type = type,
    category = CATEGORY_DICT[compressed[1]],
    result = { id = compressed[2] }
  }

  local flags = compressed[3]
  local flag_index = 0
  local index = 4

  -- Функция для проверки флага
  local function check_flag()
    local result = bit.band(flags, bit.lshift(1, flag_index)) ~= 0
    flag_index = flag_index + 1
    return result
  end

  -- Восстанавливаем опциональные поля
  if check_flag() then
    recipe.group = GROUPS[compressed[index]]
    index = index + 1
  end

  if check_flag() then
    recipe.cookingtime = compressed[index]
    index = index + 1
  end

  if check_flag() then
    recipe.experience = compressed[index]
    index = index + 1
  end

  if check_flag() then
    recipe.show_notification = false
  else
    recipe.show_notification = true
  end

  if check_flag() then
    recipe.result.count = compressed[index]
    index = index + 1
  else
    recipe.result.count = 1
  end

  -- Восстанавливаем ингредиенты и pattern
  if check_flag() then
    if check_flag() then
      local ingredients = compressed[index]
      index = index + 1

      local decompressed_ingredients = {}

      for _, comp_ing in ipairs(ingredients) do
        local ing = {}

        if comp_ing[1] ~= -1 then
          ing.item = comp_ing[1]
        else
          ing.tag = comp_ing[2]
        end

        if comp_ing[3] then
          ing.count = comp_ing[3]
        else
          ing.count = 1
        end

        table.insert(decompressed_ingredients, ing)
      end

      recipe.ingredients = decompressed_ingredients

      -- Восстанавливаем pattern, если есть
      if compressed[index] then
        recipe.pattern = compressed[index]
        index = index + 1
      end
    end
  end

  return recipe
end

return {
  compress = compress_recipe,
  decompress = decompress_recipe
}
