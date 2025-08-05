local packets = {
  sync_data = tohex(1),
  fetch_recipes = tohex(2),
  item_use_on_block = tohex(3),
  sync_inventory = tohex(4)
}

return packets
