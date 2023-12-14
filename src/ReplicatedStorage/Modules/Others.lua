local Others = {}

function Others.IncreaseAttribute( Player: Player, AttributeName: string, Value: any, MaximumValue: any )
    if ( Player:GetAttribute(AttributeName) + Value > MaximumValue ) then return end
    Player:SetAttribute(AttributeName, Player:GetAttribute(AttributeName) + Value )
end

function Others.DecreaseAttribute( Player: Player, AttributeName: string, Value: any, PositiveNumber: boolean )
    if ( PositiveNumber == true and Player:GetAttribute(AttributeName) - Value <= 0 ) then return end
    Player:SetAttribute(AttributeName, Player:GetAttribute(AttributeName) - Value )
end

function Others:Weld( PartA: BasePart, PartB: BasePart, OffSetCF: CFrame )
    PartA.CFrame = PartB.CFrame * OffSetCF
	
	local WeldConstraint: WeldConstraint = Instance.new('WeldConstraint', PartA)
	WeldConstraint.Part0 = PartA
	WeldConstraint.Part1 = PartB
end

return Others