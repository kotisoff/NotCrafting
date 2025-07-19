local micro_logger = {
  prefix = "[not_crafting][recipe_engine]",
};

function micro_logger:set_prefix(prefix)
  self.prefix = string.format("[not_crafting][%s]", prefix);
end

function micro_logger:print(...)
  print(self.prefix .. table.concat({ ... }, " "));
end;

return micro_logger;
