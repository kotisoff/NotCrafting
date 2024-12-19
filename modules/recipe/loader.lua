local PACK_ID = "not_crafting";

local not_utils = require "utility/utils";
local ResourceLoader = require "utility/resource_loader";
ResourceLoader.set_pack_id(PACK_ID);

local recipe_loader = ResourceLoader.new("recipe_loader");

recipe_loader.recipes = {};

recipe_loader:scan_packs("data", { "not_survival", "not_crafting" })
recipe_loader:load_folders(
  "recipe",
  function(_, data) return data.result ~= nil end
)

function recipe_loader.index_recipe_item(self, recipe, itemname)
  local status, itemid = not_utils.index_item(itemname);

  if not status then
    self.logger:silent(
      'Error indexing recipe "' ..
      recipe.name .. '". Error: ' .. itemid
    )
    return nil;
  end
  return itemid;
end

function recipe_loader.index(self)
  local indexed_recipes = {};
  for packpath, recipes in pairs(recipe_loader.packs) do
    self.logger:info('Indexing recipes of "' .. packpath .. '"');
    local has_errors = false;

    for _, recipe in pairs(recipes) do
      local invalid = false;

      recipe.name = recipe.result.id;
      recipe.result.count = recipe.result.count or 1;
      local result_itemid = self:index_recipe_item(recipe, recipe.result.id);
      if not result_itemid then
        invalid = true;
      else
        recipe.result.id = result_itemid;
      end

      if recipe.key and not invalid then
        for key, value in pairs(recipe.key) do
          local itemid = self:index_recipe_item(recipe, value.item);
          if not itemid then
            invalid = true
          else
            recipe.key[key].item = itemid;
          end
        end
      elseif recipe.ingredients and not invalid then
        for index, value in pairs(recipe.ingredients) do
          local itemid = self:index_recipe_item(recipe, value.item);
          if not itemid then
            invalid = true
          else
            recipe.ingredients[index].item = itemid
          end
        end
      elseif recipe.ingredient and not invalid then
        local itemid = self:index_recipe_item(recipe, recipe.ingredient.item);
        if not itemid then
          invalid = true;
        else
          recipe.ingredient.item = itemid;
        end
      end

      if not invalid then
        table.insert(indexed_recipes, recipe);
        self.logger:silent('Indexed recipe "' .. recipe.name .. '"')
      end

      if invalid then has_errors = invalid end;
    end

    if has_errors then
      self.logger:info('Some errors occured while loading pack "' .. packpath .. '"');
      self.logger:info('Check "' .. self.logger:filepath() .. '" file for more information');
    end
  end

  recipe_loader.recipes = indexed_recipes;

  self.logger:print();
  self.logger:save();
end

events.on("not_crafting:first_tick", function()
  recipe_loader:index();
end);

return recipe_loader;
