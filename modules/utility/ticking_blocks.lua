local ticking_blocks = {
  data = {}
};

function ticking_blocks.add(pos, data, ...)
  table.insert(ticking_blocks.data, { pos = pos, data = data or {}, blocks = { ... } })
end

function ticking_blocks.remove(blockid)
  local state, key = ticking_blocks.has(blockid);
  if state then table.remove(ticking_blocks.data, key) end;
end

function ticking_blocks.remove_pos(pos)
  local state, key = ticking_blocks.has_pos(pos);
  if state then table.remove(ticking_blocks.data, key) end;
end

function ticking_blocks.has(blockid)
  for key, value in pairs(ticking_blocks.data) do
    if table.has(value.blocks, blockid) then return true, key end;
  end
  return false, nil;
end

function ticking_blocks.has_pos(pos)
  for key, value in pairs(ticking_blocks.data) do
    if vec3.tostring(value.pos) == vec3.tostring(pos) then return true, key end;
  end
  return false, nil;
end

function ticking_blocks.get_data(pos)
  local state, key = ticking_blocks.has_pos(pos);
  if not state then return nil end;

  return ticking_blocks.data[key].data;
end

return ticking_blocks;
