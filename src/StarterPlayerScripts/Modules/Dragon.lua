-- [[ Services ]] --
local ContextActionService = game:GetService('ContextActionService')
local Players = game:GetService('Players')
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService: RunService = game:GetService('RunService')
local Debris: Debris = game:GetService('Debris')
local TweenService: TweenService = game:GetService('TweenService')
local Workspace = game:GetService('Workspace')

-- [[ Modules ]] --
local BezierModule = require(ReplicatedStorage.Shared.Modules:WaitForChild('Bezier'))
local OthersModule = require(ReplicatedStorage.Shared.Modules:WaitForChild('Others'))
local CameraShakerModule = require(ReplicatedStorage.Shared.Modules:WaitForChild('CameraShaker'))
local RockModule = require(ReplicatedStorage.Shared.Modules:WaitForChild('RocksModule'))
local ZoneModule = require(ReplicatedStorage.Shared.Modules:WaitForChild('Zone'))

-- [[ Folder ]] --
local Assets = ReplicatedStorage.Shared.Assets
local VFX = Assets.VFX
local Audios = Assets.Audios
local Animations = Assets.Animations

-- [[ Functions ]] --
local function Hold(Character : Model)
    local HumanoidRootPart: BasePart = Character.HumanoidRootPart
    local BodyGyro: BodyGyro = Instance.new('BodyGyro', HumanoidRootPart)
    BodyGyro.P = 2000
    BodyGyro.D = 0 
    BodyGyro.CFrame = HumanoidRootPart.CFrame
    BodyGyro.MaxTorque = Vector3.new(999999, 999999, 999999)
    return BodyGyro
end

-- [[ Initialization ]]--
local Dragon = {
    ['SetupSword'] = function(self : Player, ... : any)
        local Character : Model = self.Character
        local Humanoid : Instance = Character.Humanoid
        local HumanoidRootPart : BasePart = Character.HumanoidRootPart
        local Mouse = self:GetMouse()

        local Idle : AnimationTrack = Humanoid:LoadAnimation(Animations:WaitForChild('MaceIdle'))
        local Walk : AnimationTrack = Humanoid:LoadAnimation(Animations:WaitForChild('MaceWalk'))
        Idle:Play()

        local connection : RBXScriptConnection
        connection = RunService.Heartbeat:Connect(function()
            if (self:GetAttribute('Attacking') == true or self:GetAttribute('Stunned') == true) then
                Walk:Stop()
                Idle:Stop()
                return
            end
            if (Humanoid.MoveDirection.Magnitude > 0) then
                if (Idle.IsPlaying == true) then Idle:Stop() end
                if (Walk.IsPlaying == false) then Walk:Play() end
            else
                if (Walk.IsPlaying == true) then Walk:Stop() end
                if (Idle.IsPlaying == false) then Idle:Play() end
            end
            if (self:GetAttribute('Equipped') == false) then
                Idle:Stop()
                Walk:Stop()
                connection:Disconnect()
            end
        end)

        local MAX_COMBO = 4
        local onCooldown = false
        local combo = 0
        local lastCombo = os.clock()

        ContextActionService:BindAction('Attack', function(ActionName: string, InputState: Enum.UserInputState, _InputObjects: any)
            if (InputState ~= Enum.UserInputState.Begin) then return end
            if (self:GetAttribute('Stunned') == true or self:GetAttribute('Attacking') == true) then return end
            if (onCooldown) then return end
            onCooldown = true

            if (os.clock() > lastCombo + 1) then
                combo = 1
                lastCombo = os.clock()
            else
                lastCombo = os.clock()
                combo += 1
                if (combo > MAX_COMBO) then
                    combo = 1
                end
            end

            task.spawn(function()
                if (HumanoidRootPart:FindFirstChild('BodyGyro')) then return end
                local BodyGyro : BodyGyro = Hold(Character)
                while (os.clock() < lastCombo + 2 and self:GetAttribute('Attacking') == false and self:GetAttribute('Stunned') == false) do
                    Humanoid.AutoRotate = false
                    BodyGyro.CFrame = CFrame.new(HumanoidRootPart.CFrame.Position, Vector3.new(Mouse.Hit.Position.X, Mouse.Hit.Position.Y, Mouse.Hit.Position.Z))
                    RunService.Heartbeat:Wait()
                end
                BodyGyro:Destroy()
                Humanoid.AutoRotate = true
            end)
            
            local oldWalkSpeed = Humanoid.WalkSpeed
            Humanoid.WalkSpeed = 0            

            local Mace = Character:WaitForChild('Mace')

            local MaceSwing : Sound = Audios:WaitForChild('MaceSwing'):Clone()
            MaceSwing.Parent = Mace
            MaceSwing:Play()
            Debris:AddItem(MaceSwing, MaceSwing.TimeLength)

            local AttackAnim : AnimationTrack =  Humanoid:LoadAnimation(Animations:WaitForChild('Hit' .. combo))
            AttackAnim:Play()

            if (combo == 4) then
                local connection : RBXScriptConnection
                connection = AttackAnim:GetMarkerReachedSignal('Hit'):Connect(function()
                    print('shitt')
                    local BodyVelocity = Instance.new('BodyVelocity', HumanoidRootPart)
                    BodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
                    BodyVelocity.P = 10
                    BodyVelocity.Velocity = Character:GetModelCFrame().LookVector * (combo < MAX_COMBO and 20 or 50)
                    Debris:AddItem(BodyVelocity, .2)

                    task.wait(.3)

                    local HitBox = Instance.new('Part')
                    HitBox.Size = Vector3.new(7, 5, 10)
                    HitBox.Anchored = true
                    HitBox.CanCollide = false
                    HitBox.CFrame = Character:GetModelCFrame() * CFrame.new(0, 0, -HitBox.Size.Z / 2 - 5)
                    HitBox.Parent = workspace.VFX

                    local Zone = ZoneModule.new(HitBox)
                    local Result = Zone:getParts()
                    local RemoteEvent : RemoteEvent = Character:FindFirstChildWhichIsA('Tool'):WaitForChild('RemoteEvent')
                    RemoteEvent:FireServer('Damage', 'Attack', {
                        Combo = combo,
                        HitData = Result
                    })

                    HitBox:Destroy()
                    Zone:destroy()
                    connection:Disconnect()
                end)
            else
                local BodyVelocity = Instance.new('BodyVelocity', HumanoidRootPart)
                BodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
                BodyVelocity.P = 10
                BodyVelocity.Velocity = Character:GetModelCFrame().LookVector * (combo < MAX_COMBO and 20 or 50)
                Debris:AddItem(BodyVelocity, .2)

                local HitBox = Instance.new('Part')
                HitBox.Size = Vector3.new(7, 5, 10)
                HitBox.Anchored = true
                HitBox.CanCollide = false
                HitBox.CFrame = Character:GetModelCFrame() * CFrame.new(0, 0, -HitBox.Size.Z / 2 - 5)
                HitBox.Parent = workspace.VFX

                local Zone = ZoneModule.new(HitBox)
                local Result = Zone:getParts()
                local RemoteEvent : RemoteEvent = Character:FindFirstChildWhichIsA('Tool'):WaitForChild('RemoteEvent')
                RemoteEvent:FireServer('Damage', 'Attack', {
                    Combo = combo,
                    HitData = Result
                })

                HitBox:Destroy()
                Zone:destroy()
            end

            task.delay(AttackAnim.Length, function()
                onCooldown = false
                Humanoid.WalkSpeed = 16
            end)
        end, false, Enum.UserInputType.MouseButton1)
    end,
    ['Sword'] = function(self : Player, ... : any)
        local data : table = ...
        local Player : Player = data['Player']
        local Character : Model = data['Character']
        local Humanoid : Instance = Character.Humanoid
        local HumanoidRootPart : BasePart = Character.HumanoidRootPart
        local Mace : Model = Assets:WaitForChild('MaceDummy'):WaitForChild('Mace'):Clone()
        OthersModule:Weld(Mace.Handle, Character['RightHand'], Mace.Handle.WeldValue.Value.CFrame:Inverse() * Mace.Handle.CFrame)
        Mace.Parent = Character
    end,
    ['DestroySword'] = function(self : Player, ... : any)
        local data : table = ...
        local Player : Player = data['Player']
        local Character : Model = data['Character']
        
        Character:WaitForChild('Mace'):Destroy()
        ContextActionService:UnbindAction('Attack')
    end,
    ['SwordGround'] = function(self : Player, ... : any)
        local data : table = ...
        local Player : Player = data['Player']
        local Character : Model = data['Character']

        local Mace = Character:WaitForChild('Mace')

        task.wait(.15)
        local RockImpact : Sound = Audios:WaitForChild('RockImpact'):Clone()
        RockImpact.Parent = Mace
        RockImpact:Play()
        Debris:AddItem(RockImpact, RockImpact.TimeLength)

        local Crack : BasePart = VFX:WaitForChild('Crack'):Clone()
        Crack.Position = Mace:GetModelCFrame().Position + Vector3.new(0,0, -0.5)
        Crack.Parent = VFX

        task.delay(4, function()
            local tween = TweenService:Create(
                Crack,
                TweenInfo.new(1),
                { Size = Vector3.new(0, 0, 0), Transparency = 1 }
            )
            tween:Play()
            tween.Completed:Wait()
            Crack:Destroy()
        end)
        
        RockModule.Ground(
            Mace:GetModelCFrame().Position + Vector3.new(0,0, -0.5),
            5,
            Vector3.new(2, 1, 1),
            { workspace.VFX, workspace.Enemies, workspace.Characters, Character },
            5,
            false,
            3
        )

        if (self == Player) then
            local CurrentCamera = workspace.CurrentCamera
            local CameraShake = CameraShakerModule.new(Enum.RenderPriority.Camera.Value, function(cframe)
                CurrentCamera.CFrame = CurrentCamera.CFrame * cframe
            end)
            CameraShake:ShakeSustain(CameraShake.Presets.Explosion)
            CameraShake:Start()
            task.wait(.2)
            CameraShake:StopSustained(.5)
        end
    end,
    ['Hit'] = function(self : Player, ... : any)

    end,
    ['BeamCharge'] = function(self : Player, ... : any)
        local data : table = ...
        local Player : Player = data['Player']
        local Character : Model = data['Character']
        local Humanoid : Instance = Character.Humanoid
        local HumanoidRootPart : BasePart = Character.HumanoidRootPart
        local Mouse = self:GetMouse()
        local BodyGyro : BodyGyro = Hold(Character)
        BodyGyro.CFrame = CFrame.new(HumanoidRootPart.CFrame.Position, Vector3.new(Mouse.Hit.Position.X, Mouse.Hit.Position.Y, Mouse.Hit.Position.Z))
        Humanoid.AutoRotate = false

        local BeamChargeAnim : AnimationTrack = Humanoid:LoadAnimation(Animations:WaitForChild('BeamCharge'))
        BeamChargeAnim:Play()

        local CurrentScale = 0
        local MAX_SCALE = 1
        local ChargeAmount = 1
        local BeamCharge : Model = VFX:WaitForChild('BeamCharge'):Clone()
        BeamCharge.Parent = workspace.VFX
        BeamCharge.PrimaryPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 2, -2)

        local BeamChargeSound : Sound = Audios:WaitForChild('BeamCharge'):Clone()
        BeamChargeSound.Parent = workspace.Sounds
        BeamChargeSound:Play()
        -- Debris:AddItem(BeamChargeSound, BeamChargeSound.TimeLength)

        local FireChargeSound : Sound = Audios:WaitForChild('FireCharge'):Clone()
        FireChargeSound.Parent = workspace.Sounds
        FireChargeSound:Play()
        -- Debris:AddItem(FireChargeSound, BeamChargeSound.TimeLength)

        task.delay(BeamChargeSound.TimeLength / 1.5, function()
            -- TweenService:Create(FireChargeSound, TweenInfo.new(
            --     1,
            --     Enum.EasingStyle.Linear,
            --     Enum.EasingDirection.InOut
            -- ), { Volume = 0 }):Play()
            TweenService:Create(BeamChargeSound, TweenInfo.new(
                1,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            ), { Volume = 0 }):Play()
            -- Debris:AddItem(BeamChargeSound, 1)
            -- Debris:AddItem(FireChargeSound, 1)
        end)

        task.spawn(function()
            for i, v in pairs(BeamCharge.PrimaryPart.Attachment:GetChildren()) do
                v.Enabled = true
            end

            while (BeamCharge:GetScale() < MAX_SCALE) do
                if (not HumanoidRootPart:FindFirstChild('Charge')) then break end
                BeamCharge:ScaleTo(BeamCharge:GetScale() + 0.05)
                ChargeAmount += 0.1
                CurrentScale = BeamCharge:GetScale()
                task.wait(0.1)
            end
        end)

        if (self == Player) then
            task.spawn(function()
                local CurrentCamera = workspace.CurrentCamera
                local CameraShake = CameraShakerModule.new(Enum.RenderPriority.Camera.Value, function(cframe)
                    CurrentCamera.CFrame = CurrentCamera.CFrame * cframe
                end)
                CameraShake:ShakeSustain(CameraShake.Presets.RoughDriving)
                CameraShake:Start()

                while (HumanoidRootPart:FindFirstChild('Charge')) do
                    RunService.Heartbeat:Wait()
                end

                CameraShake:StopSustained(0.5)
            end)
        end

        while (HumanoidRootPart:FindFirstChild('Charge')) do
            BodyGyro.CFrame = CFrame.new(HumanoidRootPart.CFrame.Position, Vector3.new(Mouse.Hit.Position.X, Mouse.Hit.Position.Y, Mouse.Hit.Position.Z))
            BeamCharge.PrimaryPart.CFrame = Character.Head.CFrame * CFrame.new(0, -0.5, -1.25)
            RunService.Heartbeat:Wait()
        end

        TweenService:Create(FireChargeSound, TweenInfo.new(
            1,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        ), { Volume = 0 }):Play()
        TweenService:Create(BeamChargeSound, TweenInfo.new(
            1,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        ), { Volume = 0 }):Play()
        
        while (BeamCharge:GetScale() > 0.1) do
            BeamCharge:ScaleTo(BeamCharge:GetScale() - 0.1)
            task.wait(.05)
        end

        local MouseHit = Player:GetAttribute('MouseHit')
        local TargetDirection = (MouseHit - HumanoidRootPart.Position).Unit
        local DirectionVector = TargetDirection * 125
        local HitPosition

        local RayParams = RaycastParams.new()
        RayParams.FilterDescendantsInstances = { workspace.VFX, Character }
        RayParams.FilterType = Enum.RaycastFilterType.Exclude
        local Result = workspace:Raycast(HumanoidRootPart.Position, DirectionVector, RayParams)

        if (Result) then
            HitPosition = Result.Position
        else
            HitPosition = HumanoidRootPart.Position + DirectionVector
        end

        for i, v in pairs(BeamCharge.PrimaryPart.Attachment:GetChildren()) do
            v.Enabled = false
        end
        BeamCharge.PrimaryPart.PointLight.Enabled = false
        Debris:AddItem(BeamCharge, 1)
        
        BeamChargeAnim:Stop()
        local DragonBeamFireAnim : AnimationTrack = Humanoid:LoadAnimation(Animations:WaitForChild('DragonBeamFire'))
        local connection : RBXScriptConnection
        connection = DragonBeamFireAnim:GetMarkerReachedSignal('Fire'):Connect(function()
            BodyGyro.CFrame = CFrame.new(HumanoidRootPart.CFrame.Position, HitPosition)
            BodyGyro:Destroy()
            DragonBeamFireAnim:AdjustSpeed(0)
            local BeamShot : Sound = Audios:WaitForChild('BeamShot'):Clone()
            BeamShot.Parent = workspace.Sounds
            BeamShot:Play()

            local LineDistance = (HumanoidRootPart.Position - HitPosition).Magnitude
            local Line = VFX:WaitForChild('Line'):Clone()
            Line.CFrame = CFrame.lookAt(HumanoidRootPart.Position, HitPosition) * CFrame.new(0, 0.25, -LineDistance / 2 - 2.75) * CFrame.Angles(0, math.rad(90), 0)
            Line.Size = Vector3.new(LineDistance, 1, 1)
            Line.Parent = workspace.VFX
            
            local Size = Line.Size.X
            Line.started.Position = Vector3.new(-Size / 2, -0, -0)
            Line.Attachment.Position = Vector3.new(-Size / 2, -0, -0)
            Line.End.Position = Vector3.new(Size / 2, -0, -0)

            local Explode : Model = VFX:WaitForChild('Explode'):Clone()
            Explode.Parent = workspace.VFX
            Explode.PrimaryPart.Position = HitPosition

            local BeamExplosion : Sound = Audios:WaitForChild('BeamExplosion'):Clone()
            BeamExplosion.Parent = Explode
            BeamExplosion:Play()

            task.spawn(function()
                if (self == Player) then
                    local RemoteEvent : RemoteEvent = Character:FindFirstChildWhichIsA('Tool'):WaitForChild('RemoteEvent')
                    RemoteEvent:FireServer('Damage', 'BeamHit', {
                        HitPosition = HitPosition,
                        Scale = 1 * CurrentScale * (CurrentScale < 0.5 and 2 or 1) * 100
                    })
                end
                for i = 0.01, 1 * CurrentScale * (CurrentScale < 0.5 and 2 or 1), 0.05 do
                    Explode:ScaleTo(i)
                    task.wait()
                end
            end)

            RockModule.Ground(
                HitPosition,
                (CurrentScale < 0.5 and CurrentScale * 35 + 10 or CurrentScale * 35),
                Vector3.new(3, 4.5, 3),
                { workspace.VFX, workspace.Enemies, workspace.Characters, Character },
                (CurrentScale < 0.5 and math.random(5, 10) or 30),
                false,
                3
            )
            
            if (self == Player) then
                game.Lighting.ColorCorrection.TintColor = Color3.fromRGB(255, 170, 127)
                local CurrentCamera = workspace.CurrentCamera
                local CameraShake = CameraShakerModule.new(Enum.RenderPriority.Camera.Value, function(cframe)
                    CurrentCamera.CFrame = CurrentCamera.CFrame * cframe
                end)
                CameraShake:ShakeSustain(CameraShake.Presets.Explosion)
                CameraShake:Start()
                task.delay(1, function()
                    CameraShake:StopSustained(1)
                end)
            end

            task.wait(BeamShot.TimeLength / 1.5)

            TweenService:Create(game.Lighting.ColorCorrection, TweenInfo.new(
                1,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            ), { TintColor = Color3.fromRGB(255, 255, 255) }):Play()

            local tween = TweenService:Create(BeamShot, TweenInfo.new(
                0.5,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            ), { Volume = 0 })
            tween:Play()
            tween.Completed:Wait()

            TweenService:Create(BeamExplosion, TweenInfo.new(
                1,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            ), { Volume = 0 }):Play()

            TweenService:Create(Line, TweenInfo.new(
                0.1,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            ), { Size = Vector3.new(0, Line.Size.Y, 0), Transparency = 1 }):Play()

            Debris:AddItem(Line, 2)
            for i, v in pairs(Line.started:GetChildren()) do
                task.spawn(function()
                    for j = 1, 0, -0.01 do
                        v.Transparency = NumberSequence.new(i,1)
                        task.wait(0.1)
                    end
                end)
            end
            for i, v in pairs(Line.Attachment:GetChildren()) do
                v.Lifetime = NumberRange.new(0, 0)
            end

            for i = 1 * CurrentScale * (CurrentScale < 0.5 and 2 or 1), 0.001, -0.05 do
                Explode:ScaleTo(i)
                task.wait()
            end

            DragonBeamFireAnim:Stop()
            BeamExplosion:Destroy()
            Explode:Destroy()
            FireChargeSound:Destroy()
            BeamShot:Destroy()
            BeamChargeSound:Destroy()
            connection:Disconnect()
            Humanoid.AutoRotate = true
        end)

        DragonBeamFireAnim:Play()
    end,
    ['Explosion'] = function(self : Player, ... : any)
        local Character = self.Character
        local HumanoidRootPart : BasePart = Character.HumanoidRootPart

        local CurrentCamera = workspace.CurrentCamera
        local CameraShake = CameraShakerModule.new(Enum.RenderPriority.Camera.Value, function(cframe)
            CurrentCamera.CFrame = CurrentCamera.CFrame * cframe
        end)
        CameraShake:ShakeSustain(CameraShake.Presets.Explosion)
        CameraShake:Start()
        task.delay(1, function()
            CameraShake:StopSustained(1)
        end)
    end
}

return Dragon