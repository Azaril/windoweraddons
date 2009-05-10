--
-- Get the local player.
--
function GetPlayer()

	return CFFXiHook.Instance():GetGameStateManager():GetLocalPlayerInformation();

end

function GetItemStorage(StorageType)

    return CFFXiHook.Instance():GetGameStateManager():GetItemStorage(StorageType);

end

function GetInventory()

    return GetItemStorage(ItemStorageType.Inventory);

end

--
-- Returns the horizontal distance between two mobs.
--
function DistanceBetweenMobs(Mob1, Mob2)

    return math.sqrt(math.pow(Mob1:GetXPosition() - Mob2:GetXPosition(), 2) +  math.pow(Mob1:GetYPosition() - Mob2:GetYPosition(), 2));
                    
end

--
-- Returns the horizontal distance between a mob and the player.
--
function GetDistanceToMob(Mob)

    local Player = GetPlayer();
    
    return DistanceBetweenMobs(Player, Mob);

end

--
-- Convert a mob collection to a lua table.
--
function MobCollectionToTable(Collection)

    local MobTable = { };
    
    -- Check that a collection was specified.
    if(Collection ~= nil) then
    
        -- Get each item from the collection.
        for i = 0, Collection:GetCount() - 1 do
        
            -- Add the item to the table.
            table.insert(MobTable, Collection:GetAtIndex(i));
        
        end
    
    end
    
    return MobTable;
    
end

--
-- Find a single player that matches the specified name.
--
function FindPlayer(Name)

    -- Find all the matching players.
	local PlayerCol = CFFXiHook.Instance():GetGameStateManager():GetPlayerInformationByName(Name);
	
	-- Check at least one player was found.
	if(PlayerCol:GetCount() > 0) then
	
	    -- Return the first matching player.
	    return PlayerCol:GetAtIndex(0);
	    
	end
	
	-- No player was found.
	return nil;

end

--
-- Find non-players within a range of a position.
--
function FindNonplayersWithinRange(X, Y, Z, Range)

    local NonplayerCol = CFFXiHook.Instance():GetGameStateManager():GetNonplayerInformationWithinRange(X, Y, Z, Range);
    
    return MobCollectionToTable(NonplayerCol);

end

--
-- Find non-players within range of the player.
--

function FindNonplayersWithinRangeOfPlayer(Range)

    local Player = GetPlayer();
    
    if(Player ~= nil) then
    
        return FindNonplayersWithinRange(Player:GetXPosition(), Player:GetYPosition(), Player:GetZPosition(), Range);
    
    end
    
    return nil;

end
