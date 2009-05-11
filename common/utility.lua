-- Utility function for disconnecting connections.
function DisconnectConnection(Connection)
	if(Connection ~= nil) then
		Connection:Disconnect();
	end
end

-- Utility function for disconnecting CEGUI connections.
function DisconnectCEGUIConnection(Connection)
	if(Connection ~= nil) then
		Connection:disconnect();
	end
end

-- Check if a key is currently pressed including consumed keys.
function IsKeyDown(Key)
	return CFFXiHook.Instance():GetUIManager():GetKeyboard():IsKeyDown(Key);
end

-- Sets a key up or down.
function SetKeyState(Key, Down)
    return CFFXiHook.Instance():GetUIManager():GetKeyboard():SetKeyState(Key, Down);
end

-- Gets the key state not including consumed keys.
function GetKeyState(Key)
    return CFFXiHook.Instance():GetUIManager():GetKeyboard():GetKeyState(Key);
end

-- Send input to the game.
function SendInput(Input)
	CFFXiHook.Instance():GetGameHooks():ParseCommand(Input, 0);
end

-- Log to the console.
function Log(Text)
	-- Add the text to the log.
	CFFXiHook.Instance():GetConsole():AddTextToLog(Text);
end

-- Get the hook base directory.
function GetHookDirectory()
	return CFFXiHook.Instance():GetHookDirectory();
end

-- Get script directory.
function GetScriptDirectory()
	return string.format("%s\\%s", CFFXiHook.Instance():GetHookDirectory(), "addons");
end

-- Get script file path.
function GetScriptFilePath(File)
	return string.format("%s\\%s", GetScriptDirectory(), File);
end

-- Run a script file.
function RunScriptFile(File)
    return CFFXiHook.Instance():GetConsole():RunScriptFile(File);    
end

-- Count the number of times a value occurs in a table 
function table_count(tt, item)
	local count = 0;
	if(tt ~= nil) then
		for ii,xx in pairs(tt) do
			if item == xx then 
				count = count + 1;
			end
		end
	end
	return count;
end


-- Remove duplicates from a table array (doesn't work on key-value tables)
function table_unique(tt)
	local newtable = {};
	if(tt ~= nil) then
		for ii, xx in ipairs(tt) do
			if(table_count(newtable, xx) == 0) then
				newtable[#newtable+1] = xx;
			end
		end
	end
	return newtable;
end

-- Compared two sorted tables (doesn't work on key-value tables)
function table_compare_sorted(tt, zz)
	if(#tt ~= #zz) then
		return false;
	end
	
	for ii, xx in ipairs(tt) do
		if(zz[ii] ~= xx) then
			return false;
		end
	end
	
	return true;
end

function Trim(Text)

    return (string.gsub(Text, "^%s*(.-)%s*$", "%1"));
    
end