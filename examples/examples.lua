-
-- Example function to cast the best cure for the situation.
--
function SmartCure()

        -- Get the local player.
        local Player = GetPlayer();
        
        -- List of cure spells.
        local Cures = { { Name = "Cure V", RequiredMP = 135 }, 
                                        { Name = "Cure IV", RequiredMP = 88 },
                                        { Name = "Cure III", RequiredMP = 46 },                                 
                                        { Name = "Cure II", RequiredMP = 24 },
                                        { Name = "Cure", RequiredMP = 8 } };
                                        
        if(Player ~= nil) then
        
                -- Get the players current MP.
                local CurrentMP = Player:GetMagicPoints();
                
                -- Check each cure to see if it can be used.
                for i = 1, #Cures do
                
                        -- Check that the player has enough MP.
                        if(CurrentMP >= Cures[i].RequiredMP) then
                
                                -- TODO: Check if the target is the local player or alliance member
                                --               and use a lower cure if the cure will overheal.
                                
                                -- Cast the spell.
                                local command = "/ma \"" .. Cures[i].Name .. "\" <t>";
                                Log(command);
                                SendInput(command);
                                
                                return;
                        
                        end
                
                end
                
                Log("Not enough MP to cast cure!");
                
        end

end

-- 
-- Register the SmartCure function to the "cure" console command.
--
Alias("cure", SmartCure);