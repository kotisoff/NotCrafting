local nu = require "shared/utils/not_utils";
local fileReader = nu.FileReader;
local Logger = nu.Logger;
local utils = nu.utils;

local reader = fileReader.new();

local module = {
  recipes = {},
  logger = Logger.new("not_crafting", "recipe_loader")
};

---@param n number|nil
local function validate(n)
  if type(n) == "nil" then
    error("Failed to validate value!")
  end
  return n;
end

---@param path str
---@param reason str
local function log_recipe_error(path, reason)
  module.logger:info(
    string.format("Failed to index item in '%s' from '%s/%s'. Reason: %s",
      file.stem(path),
      file.prefix(path),
      file.name(file.parent(file.parent(path))),
      reason
    )
  );
end

local function index_item(filename, itemname)
  local status, itemid = pcall(utils.index_item, itemname);
  if not status then
    log_recipe_error(filename, "provided item does not exist")
  end
  return validate(itemid);
end

---@param recipe_types { id: str, check: fun(), use: fun() }[]
function module.reload(recipe_types)
  module.logger:info("Loading recipes...");
  module.recipes = {};

  local installed = pack.get_installed();

  for _, value in pairs(recipe_types) do
    module.recipes[value.id] = {};
  end

  for _, packid in ipairs(installed) do
    local path = string.format("%s:resources/data", packid);
    reader:list(path, { recursive = true });
  end

  local errors = 0;
  reader
      :filter(function(_, path) return (file.name(file.parent(path)) == "recipe") and (file.ext(path) == "json") end)
      :read(function(data, path)
        local status, parsed = pcall(json.parse, data);
        if not status then
          return module.logger:info(string.format("Unable to load recipe '%s' from pack '%s'", path, file.prefix(path)));
        end

        return parsed;
      end)
      :for_each(function(data, path)
        module.logger:info(
          string.format("Indexing recipe '%s' from '%s/%s'...",
            file.stem(path),
            file.prefix(path),
            file.name(file.parent(file.parent(path))))
        );

        local valid = module.recipes[data.type] and true or false;
        local reason, latest_item;

        if not valid then
          reason = string.format("recipe type '%s' is not supported", data.type);
        else
          valid = pcall(function()
            data.path = path;

            data.result = {
              id = index_item(path, data.result.id),
              count = data.result.count or 1
            };

            local ingredients = data.key or data.ingredients;
            if ingredients then
              for _, value in pairs(ingredients) do
                latest_item = value.item;
                local itemid = index_item(path, latest_item);
                value.item = itemid;
              end
            end
          end)

          if not valid then
            reason = string.format("Item '%s' does not exist", latest_item);
          end
        end

        if not valid then
          log_recipe_error(path, reason or "not defined")
          errors = errors + 1;
          goto continue;
        end;
        table.insert(module.recipes[data.type], data);
        ::continue::
      end)
      :clear();

  module.logger:info(string.format("Done with %s errors.", errors));
  module.logger:print();
end

return module;
