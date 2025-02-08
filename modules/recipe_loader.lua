local PACK_ID = PACK_ID or "not_crafting"; local function resource(name) return PACK_ID .. ":" .. name end

recipe_loader = {
  packs = {}
};
recipe_loader.recipes = {};

function recipe_loader.scan()
  recipe_loader.packs = {};

  local installed = pack.get_installed();
  for _, packid in pairs(installed) do
    local path = packid .. ":resources/data";
    if file.exists(path) then
      for _, pack in pairs(file.list(path)) do
        recipe_loader.packs[pack] = {};
      end
    end
  end
end

function recipe_loader.load()
  for pack, _ in pairs(recipe_loader.packs) do
    recipe_loader.packs[pack] = {};
    local path = pack .. "/recipe";
    if file.exists(path) then
      local recipes = file.list(pack .. "/recipe");
      for _, recipe_file in pairs(recipes) do
        if file.isfile(recipe_file) then
          local filedata = file.read(recipe_file);
          local status, recipe = pcall(json.parse, filedata);
          if status and recipe.result then
            table.insert(recipe_loader.packs[pack], recipe);
          end
        end
      end
    end
  end
  print(#recipe_loader.packs .. " packs loaded.")

  local recipeCount = 0;
  local loaded_recipes = "";
  for _, recipes in pairs(recipe_loader.packs) do
    recipeCount = recipeCount + #recipes
    for _, recipe in pairs(recipes) do
      loaded_recipes = loaded_recipes .. recipe.result.id .. "\n"
    end
  end
  print(recipeCount .. " recipes loaded.")
  print(loaded_recipes);
end

function block.item_index(blockname)
  return block.get_picking_item(block.index(blockname));
end

function index_item(recipe, itemname)
  local status = true;
  local itemid_or_err = 0;

  status, itemid_or_err = pcall(block.item_index, itemname);
  if not status then status, itemid_or_err = pcall(item.index, itemname) end;

  if not status then
    print(
      "[" .. PACK_ID .. '] Error indexing recipe "' ..
      recipe.result.id .. '". Error: ' .. itemid_or_err
    )
    return nil;
  end
  return itemid_or_err;
end

function recipe_loader.index()
  -- table.insert(recipe_loader.recipes, recipe);
  local indexed_recipes = {};
  for packid, recipes in pairs(recipe_loader.packs) do
    print('[' .. PACK_ID .. '] Indexing items of "' .. packid:split(":")[1] .. '"');
    for _, recipe in pairs(recipes) do
      local invalid = false;

      recipe.name = recipe.result.id;
      local result_itemid = index_item(recipe, recipe.result.id);
      if not result_itemid then
        invalid = true;
      else
        recipe.result.id = result_itemid;
      end

      if recipe.key and not invalid then
        for key, value in pairs(recipe.key) do
          local itemid = index_item(recipe, value.item);
          if not itemid then
            invalid = true
          else
            recipe.key[key].item = itemid;
          end
        end
      elseif recipe.ingredients and not invalid then
        for index, value in pairs(recipe.ingredients) do
          local itemid = index_item(recipe, value.item);
          if not itemid then
            invalid = true
          else
            recipe.ingredients[index].item = itemid
          end
        end
      end

      if not invalid then
        table.insert(indexed_recipes, recipe);
        print("[" .. PACK_ID .. '] Indexed recipe "' .. recipe.name .. '"')
      end
    end
  end

  recipe_loader.recipes = indexed_recipes;
end

recipe_loader.scan();
recipe_loader.load();

events.on(resource("first_tick"), recipe_loader.index);

return recipe_loader;
