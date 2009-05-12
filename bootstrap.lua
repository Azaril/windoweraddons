-- Set lua script file search path.
package.path = string.format("%s\\addons\\?.lua", CFFXiHook.Instance():GetHookDirectory());

--
-- Initialization
--

-- Load common script.
require("common\\common");

-- Load console script.
require("console\\console");

-- Load alias script.
require("alias\\alias");

-- Load bind script.
require("bind\\bind");