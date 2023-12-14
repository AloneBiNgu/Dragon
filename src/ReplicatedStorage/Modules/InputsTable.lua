-- [[ Initalization ]] --
local InputsTable = {}
InputsTable.Table = {}

function InputsTable:AddInput( Player: Player, Input: string )
    InputsTable.Table[Player.Name][Input] = true    
end

function InputsTable:RemoveInput( Player: Player, Input: string )
    InputsTable.Table[Player.Name][Input] = nil
end

function InputsTable:RemoveAllInputs( Player: Player )
    InputsTable.Table[Player.Name] = {}
end

function InputsTable:CheckInput( Player: Player, Input: string )
    return InputsTable.Table[Player.Name][Input]
end

return InputsTable