-- Set lua script file search path.
package.path = string.format("%s\\addons\\?.lua", CFFXiHook.Instance():GetHookDirectory());

--
-- Initialization
--

-- Load utility script.
require("utility");

-- Load ui script.
require("ui");

-- Load console script.
require("console");

-- Load alias script.
require("alias");

-- Load bind script.
require("bind");

-- Load game utilitiy script.
require("gameutility");