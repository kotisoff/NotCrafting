local _logger = require "shared/utils/not_utils".Logger.new("not_crafting");

local logger = {
  levels = _logger.levels,
  clear = function() _logger:clear() end,

  ---@param level not_utils.logger.levels
  log = function(level, ...)
    _logger:log(level, ...);
  end,
  print = function()
    _logger:print()
  end,
  println = function(level, ...)
    _logger:println(level, ...);
  end
}

return logger;
