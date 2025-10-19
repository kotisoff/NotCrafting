local pos = { x = nil, y = nil, z = nil };
local blockid = block.index("not_crafting:crafting_table");

local function get_pos()
  return pos;
end

function on_open(invid, x, y, z)
  pos = { x = x, y = y, z = z };
end

local utils = require("shared/recipe/utils/layout_utils")
    .init_crafting_table(blockid, get_pos);

grid = utils.grid;
