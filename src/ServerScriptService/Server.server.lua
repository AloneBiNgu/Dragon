-- [[ Services ]] --
local PlayerService = game:GetService('Players');
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ServerStorage = game:GetService('ServerStorage')

-- [[ Modules ]] --
local InputsTable = require(ReplicatedStorage.Shared.Modules:WaitForChild('InputsTable'))
local CooldownModule = require(ServerStorage.Source.Services:WaitForChild('Cooldown'))

-- [[ Varibles ]] --
local Attributes = {}

-- [[ Functions ]] --
local function InitServer()
    for i, v in pairs(ServerStorage.Source.Modules:GetChildren()) do
        local module = require(v)
        local moduleAttributes: table = module.Attributes
        if ( moduleAttributes ) then
            for name, value in pairs(moduleAttributes) do
                Attributes[name] = value
            end
        end
    end
end

local function onPlayerAdded(Player : Player)
    print('New player', Player.Name)

    InputsTable.Table[Player.Name] = {}
    CooldownModule.Table[Player.Name] = {}
    Player:SetAttribute('Attacking', false)
    Player:SetAttribute('Stunned', false)

    print('Checking attributes', Player.Name)
    task.spawn(function()
        for name, value in pairs(Attributes) do
            if (not Player:GetAttribute(name)) then
                Player:SetAttribute(name, value)
            end
        end
    end)
    print('Added attributes', Player.Name)

    Player.CharacterAdded:Connect(function(character)
        RunService.Heartbeat:Wait()
        character.Parent = workspace.Characters
        local Tool: Tool = ServerStorage.Source:WaitForChild('Dragon'):Clone()
        Tool.Parent = Player.Backpack
        Tool.Enabled = true
    end) 
end

local function onPlayerRemoved(Player : Player)
    print('Removed Player', Player.Name)
end

-- [[ Init ]] --
InitServer()

-- [[ RBXConnection ]] --
PlayerService.PlayerAdded:Connect(onPlayerAdded)
PlayerService.PlayerRemoving:Connect(onPlayerRemoved)