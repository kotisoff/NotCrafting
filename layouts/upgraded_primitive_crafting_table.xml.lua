function share_func(invid, slot)
  local pid = hud.get_player();
  local itemid, count = inventory.get(invid, slot);
  local pinvid = player.get_inventory(pid);

  if inventory.can_add_item(itemid, count, pinvid) then
    inventory.add(pinvid, itemid, count);
    inventory.set(invid, slot, 0, 0);
  end
end
