-- [[ Services ]] --
local ReplicatedStrorage = game:GetService('ReplicatedStorage')
local ContextActionService = game:GetService('ContextActionService')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')

-- [[ Folders ]] --
local Assets = ReplicatedStrorage.Shared.Assets

-- [[ Modules ]] --
local Data = require(script.Parent:WaitForChild('Data'))

-- [[ Remotes ]] --
local RemoteEvent = script.Parent:WaitForChild('RemoteEvent')
local EffectEvent = ReplicatedStrorage.Shared.Remotes.Events:WaitForChild('Effect')

-- [[ Varibles ]] --
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Mouse = LocalPlayer:GetMouse()
local Tool = script.Parent
local Holding = false

-- [[ Functions ]] --
local function getWorldMousePosition()
	local mouseLocation = UserInputService:GetMouseLocation()
	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local directionVector = screenToWorldRay.Direction * 1000
	local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector)
	if raycastResult then
		return raycastResult.Position
	else
		return screenToWorldRay.Origin + directionVector
	end
end

local function HandleInput(ActionName: string, InputState: Enum.UserInputState, _InputObjects: any)
    if (InputState == Enum.UserInputState.Begin) then
        if (LocalPlayer:GetAttribute('Attacking') == true or LocalPlayer:GetAttribute('Stunned') == true) then return end
        RemoteEvent:FireServer(true)
        RemoteEvent:FireServer('Skill', ActionName)
        Holding = true

        while (Holding) do
            if (LocalPlayer:GetAttribute('Stunned') == true) then break end
            RemoteEvent:FireServer(getWorldMousePosition())
            RunService.Heartbeat:Wait()
        end

        RemoteEvent:FireServer(false, ActionName)
        return
    end
    
    if (InputState == Enum.UserInputState.End or InputState == Enum.UserInputState.Cancel) then
        if (LocalPlayer:GetAttribute('Attacking') == false) then return end
        RemoteEvent:FireServer(false, ActionName)
        Holding = false
        return
    end
end

-- [[ Threads ]] --
local Equipped = coroutine.create(function()
    Tool.Equipped:Connect(function()
        RemoteEvent:FireServer('Equip')
        for button, data in pairs(Data) do
            ContextActionService:BindAction(button, HandleInput, false, Enum.KeyCode[button])
        end
    end)
end)

local Unequipped = coroutine.create(function()
    Tool.Unequipped:Connect(function()
        RemoteEvent:FireServer('Unequip')
        for button, data in pairs(Data) do
            ContextActionService:UnbindAction(button)
        end
    end)
end)

-- [[ Init ]] --
coroutine.resume(Equipped)
coroutine.resume(Unequipped)