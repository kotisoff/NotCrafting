local CATEGORY_DICT = {
  "misc"
}

local GROUPS = {
  "planks", "wood"
}

local function compress_recipe(recipe)
  return recipe;
end

local function decompress_recipe(compressed, type)
  return compressed;
end

return {
  compress = compress_recipe,
  decompress = decompress_recipe
}
