-- Set lua script file search path.
package.path = string.format("%s\\addons\\?.lua", CFFXiHook.Instance():GetHookDirectory());

--
-- Initialization
--

-- Load utility script.
require("common\\utility");

-- Load game utility script.
require("common\\gameutility");

-- Load ui script.
require("common\\ui");

-- Load console script.
require("console\\console");

-- Load alias script.
require("alias\\alias");

-- Load bind script.
require("bind\\bind");