local loader = require "shared/recipe/loader";

local module = {
  ---@type { id: str, check: fun(), use: fun() }[]
  engines = {}
};

function module.add_recipe_type(identifier, check, use)
  table.insert(module.engines, {
    id = identifier,
    check = check,
    use = use
  })
end

function module.resolve_grid(grid) -- TODO: сортировать рецепты по виду рецепта.
end

events.on("not_crafting:hud_open", function()
  loader.reload({ { id = "not_crafting:crafting_shapeless" }, { id = "not_crafting:crafting_shaped" }, { id = "not_crafting:smelting" } })
end)
