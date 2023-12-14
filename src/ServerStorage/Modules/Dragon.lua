-- [[ Service ]] --
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ServerStorage = game:GetService('ServerStorage')
local Debris = game:GetService('Debris')

-- [[ Modules ]] --
local Functions = require(ReplicatedStorage.Shared.Modules:WaitForChild('Functions'))
local InputsTable = require(ReplicatedStorage.Shared.Modules:WaitForChild('InputsTable'))
local CooldownModule = require(ServerStorage.Source.Services:WaitForChild('Cooldown'))
local BezierModule = require(ReplicatedStorage.Shared.Modules:WaitForChild('Bezier'))
local Others = require(ReplicatedStorage.Shared.Modules:WaitForChild('Others'))

-- [[ Initilization ]] --
local Dragon = {}

Dragon.Skills = {
    ['Z'] = {
        Cooldown = 2
    },
    ['X'] = {
        Cooldown = 4
    },
    ['C'] = {
        Cooldown = 3
    },
    ['V'] = {
        Cooldown = 1
    },
    ['F'] = {
        Cooldown = 5
    },
    ['G'] = {
        Cooldown = 0,
        ExtraInfo = {
            Enabled = false
        }
    }
}

function Dragon.Z(Player : Player, params : any)
    CooldownModule.Add(Player, 'Z', Dragon.Skills['Z'].Cooldown)

    local Character : Model = Player.Character
    local HumanoidRootPart : BasePart = Character.HumanoidRootPart

    local BodyVelocity : BodyVelocity = Instance.new('BodyVelocity', HumanoidRootPart)
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.Name = 'Charge'

    Functions.FireAllClient({
        Origin = HumanoidRootPart,
        Distance = 125,
        Remote = ReplicatedStorage.Shared.Remotes.Events.Effect
    }, {
        'BeamCharge',
        { Player = Player, Character = Character }
    })

    while (InputsTable.Table[Player.Name]['Z']) do
        RunService.Heartbeat:Wait()
    end

    BodyVelocity:Destroy()
end

return Dragon