local mp = require "shared/utils/not_utils".multiplayer;
local gui_func_gen = require "shared/recipe/utils/gui_func_gen"

if mp.mode ~= "standalone" then return end;

local pos = { nil, nil, nil };

function on_open(invid, x, y, z)
  pos = { x, y, z };
end

local funcs = gui_func_gen.init_crafting_table(
  function()
    return pos;
  end
)

grid = funcs.grid;
