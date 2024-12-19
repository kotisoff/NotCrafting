function share_func(invid, slot)
  local itemid, count = inventory.get(invid, slot);

  local pinvid = player.get_inventory();
  inventory.add(pinvid, itemid, count);
  inventory.set(invid, slot, 0, 0);
end
