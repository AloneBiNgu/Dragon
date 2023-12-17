-- [[ Service ]] --
local Players = game:GetService('Players')
local RunService: RunService = game:GetService('RunService')

-- [[ Initialization ]] --
local Functions: table = {}

if ( not RunService:IsServer() ) then
    return Functions
end

function Functions.FireClient(Player : Player, data : table, ... : any)
    print(data)
    data['Remote']:FireClient(Player, ...)
end

function Functions.FireAllClient(data : table, ... : any)
    for i,v in pairs(Players:GetChildren()) do
        if (v.Character) then
            if ((v.Character.HumanoidRootPart.Position - data['Origin'].Position).Magnitude <= data['Distance']) then
                print('Mep')
                data['Remote']:FireClient(v, ...)         
            end
        end
    end
end

return Functions