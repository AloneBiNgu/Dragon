local Cooldown = {}
Cooldown.Table = {}

function Cooldown.Add( Player: Player, SkillName: string, Time: number )
    Cooldown.Table[Player.Name][SkillName] = true
    task.delay(Time, function()
        Cooldown.Table[Player.Name][SkillName] = nil
    end)
end

function Cooldown.Check( Player: Player, SkillName: string )
    return Cooldown.Table[Player.Name][SkillName] or nil
end

return Cooldown