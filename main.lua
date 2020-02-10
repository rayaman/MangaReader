print("running!")
require("Library")
local bin = require("bin")
local multi,thread = require("multi"):init()
GLOBAL, THREAD = require("multi.integration.loveManager").init()
require("GuiManager")
require("manga")

local app = gui:newFullFrame("App")
require("app").init(app)

-- Main Driver
multi.OnError(function(...)
	print(...)
end)
multi:loveloop()
