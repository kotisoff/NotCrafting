local resource = require "shared/utils/resource_func";

function on_use_on_block(x, y, z, pid, normal)
  if block.get(x, y, z) == block.index("base:wood") then
    block.place(x, y, z, block.index(resource("primitive_crafting_table")), pid)
    local inv, slot = player.get_inventory(pid)
    inventory.decrement(inv, slot, 1)
    return true
  end
end
