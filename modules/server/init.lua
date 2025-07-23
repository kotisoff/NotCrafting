local require_folder = require "shared/utils/require_folder"

require_folder "server/events";

print("Облять")

events.emit("not_crafting:server_init");
