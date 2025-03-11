if SERVER then
    player_teleport_list = {}

    hook.Remove("FinishMove", "TeleportToPlayer")
    hook.Add("FinishMove", "TeleportToPlayer", function(ply, mv)
        if player_teleport_list and player_teleport_list[ply:SteamID()] != nil then
            print("Teleporting...")
            local pos = player_teleport_list[ply:SteamID()].pos
            local nick = player_teleport_list[ply:SteamID()].nick or ""
            mv:SetOrigin(Vector( pos.x, pos.y, pos.z ) )
            ply:ChatPrint("Teleported to " .. nick)
            player_teleport_list[ply:SteamID()] = nil
        end
        for _, other_ply in pairs(player.GetAll()) do
            if other_ply ~= ply and ply:GetPos():Distance(other_ply:GetPos()) < 50 then
                local push_force = 5  -- Adjust the force as needed
                local push_dir = (ply:GetPos() - other_ply:GetPos()):GetNormalized()
                
                -- Temporarily disable collisions
                ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                other_ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                
                ply:SetVelocity(push_dir * push_force)
                -- other_ply:SetVelocity(-(push_dir) + push_force)
                
                -- Reset collision group after a short delay
                timer.Simple(0.1, function()
                    if IsValid(ply) then ply:SetCollisionGroup(COLLISION_GROUP_PLAYER) end
                    if IsValid(other_ply) then other_ply:SetCollisionGroup(COLLISION_GROUP_PLAYER) end
                end)
            end
        end
    end)

    local function TeleportToPlayer(ply, target_name)
        if not IsValid(ply) then return end
        if not target_name or target_name == "" then
            ply:ChatPrint("Usage: !teleport <player_name>")
            return
        end

        local target_ply = nil

        for _, v in pairs(player.GetAll()) do
            if string.find(v:Nick():lower(), target_name:lower(), 1, true) then
                target_ply = v
                break
            end
        end

        if not target_ply then
            ply:ChatPrint("Player not found!")
            return
        end

        local pos = target_ply:GetPos()
        player_teleport_list[ply:SteamID()] = {pos = pos, nick = target_ply:Nick()}
        ply:ChatPrint("Teleporting to " .. target_ply:Nick())
        ply:ChatPrint("Please wait a moment...")
        PrintTable(player_teleport_list)
    end

    concommand.Add("teleport_to_player", function(ply, cmd, args)
        TeleportToPlayer(ply, args[1])
    end)

    hook.Add("PlayerSay", "TeleportToPlayerChatCommand", function(ply, text)
        if string.sub(text:lower(), 1, 10) == "!teleport " then
            local target_name = string.sub(text, 11)
            TeleportToPlayer(ply, target_name)
            return ""
        end
    end)
end