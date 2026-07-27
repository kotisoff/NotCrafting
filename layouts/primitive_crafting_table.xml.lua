local mp             = require "shared/utils/not_utils".multiplayer;
local block_props    = require "shared/api/v1/block_props"
local standalone_ui  = require "shared/crafting/standalone_ui"
local crafting_table = require "shared/crafting/crafting_table"

if mp.mode ~= "standalone" then return end;

local blockid = nil;
local result_slot = nil;

function on_open(invid, x, y, z)
  blockid = block.get(x, y, z);
  result_slot = block_props.craft_data(blockid).result_slot;

  crafting_table.update_result(invid, blockid, result_slot);
end

local blockid_fn = function() return blockid end;
local result_slot_fn = function() return result_slot end;

local handlers = standalone_ui.create_handlers(blockid_fn, result_slot_fn);

grid = handlers.grid;
result = handlers.result;
