-- [[ Services ]] --
local ReplicatedStrorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')
-- [[ Modules ]] --
local Data = require(script.Parent:WaitForChild('Data'))
local InputsTable = require(ReplicatedStrorage.Shared.Modules:WaitForChild('InputsTable'))
local Dragon = require(ServerStorage.Source.Modules:WaitForChild('Dragon'))
local CooldownModule = require(ServerStorage.Source.Services:WaitForChild('Cooldown'))


-- [[ Remotes ]] --
local RemoteEvent = script.Parent:WaitForChild('RemoteEvent')
local EffectEvent = ReplicatedStrorage.Shared.Remotes.Events:WaitForChild('Effect')

-- [[ Threads ]] --
local OnServerEvent = coroutine.create(function()
    RemoteEvent.OnServerEvent:Connect(function(self, command, ...)
        if (command == 'Equip') then
            self:SetAttribute('Equipped', true)
            return
        end

        if (command == 'Unequip') then
            self:SetAttribute('Equipped', false)
            return
        end

        if (command == true) then
            self:SetAttribute('Attacking', true)
            return
        end

        if (command == 'Skill') then
            print('mep')
            if (self:GetAttribute('Attacking') == false or self:GetAttribute('Stunned') == true) then return end
            local button, params = ...
            InputsTable:AddInput(self, button)
            if (not CooldownModule.Check(self, button)) then
                local success, fail = pcall(Dragon[button], self, params)
                if (not success) then warn(fail) end
            end
            return
        end

        if (typeof(command) == 'Vector3') then
            self:SetAttribute('MouseHit', command)
            return
        end

        if (command == false) then
            InputsTable:RemoveInput(self, ...)
            self:SetAttribute('Attacking', false)
            return
        end
    end)
end)

-- [[ Init ]] --
coroutine.resume(OnServerEvent)