local packid = "not_crafting"

---@param folder string
return function(folder)
  local modules = {};
  local files = file.join(pack.get_folder(packid), "modules/" .. folder)
  for _, path in ipairs(file.list(files)) do
    local basename = file.stem(path)
    local module = require(file.join(folder, basename))
    table.insert(modules, module);
  end

  return modules;
end
