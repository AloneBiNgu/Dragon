-- [[ Services ]] --
local Players = game:GetService('Players')
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService: RunService = game:GetService('RunService')
local Debris: Debris = game:GetService('Debris')
local TweenService: TweenService = game:GetService('TweenService')

-- [[ Modules ]] --
local BezierModule = require(ReplicatedStorage.Shared.Modules:WaitForChild('Bezier'))
local OthersModule = require(ReplicatedStorage.Shared.Modules:WaitForChild('Others'))

-- [[ Remotes ]] --
local RemoteEvent: RemoteEvent = ReplicatedStorage.Shared.Remotes.Events:WaitForChild('RemoteEvent')

-- [[ Folder ]] --
local Assets = ReplicatedStorage.Shared.Assets

-- [[ Functions ]] --
local function Hold(Character : Model)
    local HumanoidRootPart: BasePart = Character.HumanoidRootPart
    local BodyGyro: BodyGyro = Instance.new('BodyGyro', HumanoidRootPart)
    BodyGyro.P = 20000
    BodyGyro.D = 0 
    BodyGyro.CFrame = HumanoidRootPart.CFrame
    BodyGyro.MaxTorque = Vector3.new(999999, 999999, 999999)
    return BodyGyro
end

-- [[ Initialization ]]--
local Dragon = {
    ['BeamCharge'] = function(self : Player, ... : any)
        local data : table = ...
        local Player : Player = data['Player']
        local Character : Model = data['Character']
        local HumanoidRootPart : BasePart = Character.HumanoidRootPart
        local BodyGyro : BodyGyro = Hold(Character)
        Character.Humanoid.AutoRotate = false

        local Mouse = Player:GetMouse()

        local BeamCharge : Model = Assets:WaitForChild('BeamCharge'):Clone()
        BeamCharge.Parent = workspace.VFX
        BeamCharge.Bubble.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 2, -2)

        task.spawn(function()
            TweenService:Create(BeamCharge.Bubble, TweenInfo.new(
                1,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            ), { Size = Vector3.new(0, 0, 0), Transparency = 1 }):Play()

            for i, v in pairs(BeamCharge.Bubble.Attachment:GetChildren()) do
                v.Lifetime = NumberRange.new(0, 0)
                task.wait(.05)
            end

            BeamCharge.Bubble.PointLight.Enabled = false
        end)

        while (HumanoidRootPart:FindFirstChild('Charge')) do
            BodyGyro.CFrame = CFrame.new(HumanoidRootPart.Position, Mouse.Hit.Position)
            BeamCharge.Bubble.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 2, -2)
            RunService.Heartbeat:Wait()
        end

        Character.Humanoid.AutoRotate = true

        local MouseHit = Player:GetAttribute('MouseHit')
        local TargetDirection = (MouseHit - HumanoidRootPart.Position).Unit
        local DirectionVector = TargetDirection * 125
        local HitPosition

        local RayParams = RaycastParams.new()
        RayParams.FilterDescendantsInstances = { workspace.VFX, Character }
        RayParams.FilterType = Enum.RaycastFilterType.Exclude
        local Result = workspace:Raycast(HumanoidRootPart.Position, DirectionVector, RayParams)

        if (Result) then
            print('Hit something', Result.Instance.Name)
            HitPosition = Result.Position
        else
            HitPosition = HumanoidRootPart.Position + DirectionVector
        end
        
        local LineDistance = (HumanoidRootPart.Position - HitPosition).Magnitude
        local Line = Assets:WaitForChild('Line'):Clone()
        Line.CFrame = CFrame.lookAt(HumanoidRootPart.Position, HitPosition) * CFrame.new(0, 2, -1.2 * LineDistance / 2) * CFrame.Angles(0, math.rad(90), 0)
        Line.Size = Vector3.new(LineDistance, 3, 3)
        Line.Parent = workspace.VFX

        BodyGyro:Destroy() 
    end
}

return Dragon