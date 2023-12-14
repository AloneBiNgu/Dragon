-- [[ Services ]] --
local ContentProvider: ContentProvider = game:GetService('ContentProvider')
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')

-- [[ Initalization ]]--
if ( not game:IsLoaded() ) then game.Loaded:Wait() end
ContentProvider:PreloadAsync({ ReplicatedStorage.Shared.Assets })
warn('Reloaded Assets')