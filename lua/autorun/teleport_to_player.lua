concommand.Add("teleport_to_player", function(ply, cmd, args)

    if #args < 1 then

        print("Usage: teleport_to_player <player_name>")

        return

    end


    local target_ply = nil

    for _, v in ipairs(player.GetAll()) do

        if v:Nick():lower() == args[1]:lower() then

            target_ply = v

            break

        end

    end


    if not target_ply then

        print("Player not found!")

        return

    end


    ply:SetPos(target_ply:GetPos())

    print("Teleported to " .. target_ply:Nick())

end)