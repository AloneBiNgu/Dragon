-- [[ Services ]] --
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- [[ Module ]] --
local VFXController = require(script.Parent.Modules:WaitForChild('VFX'))

-- [[ Remotes ]]--
local EffectRemote = ReplicatedStorage.Shared.Remotes.Events:WaitForChild('Effect')

-- [[ Varible ]]--
local LocalPlayer: Player = game.Players.LocalPlayer

-- [[ RBXScriptSignal ]] --
EffectRemote.OnClientEvent:Connect(function(... : any)
    local FXName, params = unpack( ... )
    VFXController[FXName](LocalPlayer, params)
end)