-- [[ Service ]] --
local Players = game:GetService('Players')
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

-- [[ M1 ]] --

function Dragon.Sword(Player : Player, params : any)
    local Character : Model = Player.Character
    local HumanoidRootPart : BasePart = Character.HumanoidRootPart

    Functions.FireAllClient({
        Origin = HumanoidRootPart,
        Distance = 99999999,
        Remote = ReplicatedStorage.Shared.Remotes.Events.Effect
    }, {
        'Sword',
        { Player = Player, Character = Character }
    })

    Functions.FireClient(Player, {
        Remote = ReplicatedStorage.Shared.Remotes.Events.Effect
    }, {
        'SetupSword',
    })
end

function Dragon.DestroySword(Player : Player, params : any)
    local Character : Model = Player.Character
    local HumanoidRootPart : BasePart = Character.HumanoidRootPart

    Functions.FireAllClient({
        Origin = HumanoidRootPart,
        Distance = 99999999,
        Remote = ReplicatedStorage.Shared.Remotes.Events.Effect
    }, {
        'DestroySword',
        { Player = Player, Character = Character }
    })
end

function Dragon.Attack(Player : Player, params : any)
    local Character : Model = Player.Character
    local HumanoidRootPart : BasePart = Character.HumanoidRootPart

    local Combo = params['Combo']
    local HitData = params['HitData']

    if (Combo == 3) then
        Functions.FireAllClient({
            Origin = HumanoidRootPart,
            Distance = 125,
            Remote = ReplicatedStorage.Shared.Remotes.Events.Effect
        }, {
            'SwordGround',
            { Player = Player, Character = Character }
        })
    end

    local hit = {}
    for i,v in pairs(HitData) do
        local target = v.Parent
        if (target == Character) then continue end
        local Humanoid = target:FindFirstChild('Humanoid')
        local HRP = target:FindFirstChild('HumanoidRootPart')

        if (Humanoid and Humanoid.Health > 0 and hit[target] == nil) then
            hit[target] = true
            Humanoid:TakeDamage(5)

            HRP.CFrame = CFrame.lookAt(HRP.Position, Character:GetModelCFrame().Position)
            
            if (Combo == 3) then
                local BodyVelocity = Instance.new('BodyVelocity', HRP)
                BodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
                BodyVelocity.P = 50
                BodyVelocity.Velocity = (Character:GetModelCFrame().LookVector * 25) + Vector3.new(0, 30, 0)
                Debris:AddItem(BodyVelocity, .1)
            else
                local BodyVelocity = Instance.new('BodyVelocity', HRP)
                BodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
                BodyVelocity.P = 10
                BodyVelocity.Velocity = Character:GetModelCFrame().LookVector * 20
                Debris:AddItem(BodyVelocity, .2)
            end

            Functions.FireAllClient({
                Origin = HumanoidRootPart,
                Distance = 125,
                Remote = ReplicatedStorage.Shared.Remotes.Events.Effect
            }, {
                'Hit',
                { Character = target }
            })

            local player = Players:GetPlayerFromCharacter(target)
            if (player) then
                player:SetAttribute('Stunned', true)
                task.delay(1, function()
                    player:SetAttribute('Stunned', false)
                end)
            end
        end
    end
end

-- [[ Skills ]]--

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
    task.wait()
    local BodyVelocity : BodyVelocity = Instance.new('BodyVelocity', HumanoidRootPart)
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    Debris:AddItem(BodyVelocity, 3.5)
end

function Dragon.BeamHit(Player : Player, params : any)
    local HitPosition : Vector3 = params.HitPosition
    local Scale : number = params.Scale
    local Radius : number = Scale * 3 / 3
    local OverlapParams : OverlapParams = OverlapParams.new()
    OverlapParams.FilterDescendantsInstances = { workspace.VFX, Player.Character }
    OverlapParams.FilterType = Enum.RaycastFilterType.Exclude

    local hitParts = workspace:GetPartBoundsInRadius(HitPosition, Radius, OverlapParams)
    local hit = {}
    for i, v in pairs(hitParts) do
        local Humanoid = v.Parent:FindFirstChild('Humanoid')
        if (Humanoid and Humanoid.Health > 0 and hit[v.Parent] == nil) then
            hit[v.Parent] = true
            Humanoid:TakeDamage(10)
            local player = Players:GetPlayerFromCharacter(v.Parent)

            if (player) then
                print('Found PLR')
                player:SetAttribute('Stunned', true)

                Functions.FireClient(player, {
                    Remote = ReplicatedStorage.Shared.Remotes.Events.Effect
                }, {
                    'Explosion'
                })

                task.delay(1.5, function()
                    player:SetAttribute('Stunned', false)
                end)
            end
        end
    end
end

return Dragon