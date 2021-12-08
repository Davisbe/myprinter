print("[Arro's printers] Loading template printer...")
--------------------------------------------------------------------------------
--SHARED FILES
--------------------------------------------------------------------------------
AddCSLuaFile("printer_config.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
--------------------------------------------------------------------------------
--NETWORKING
--------------------------------------------------------------------------------
util.AddNetworkString("entities.printertemplate.ui")
util.AddNetworkString("givemaxmoney")
util.AddNetworkString("printermessage_hint")
util.AddNetworkString("button1_logic")
util.AddNetworkString("button2_logic")
util.AddNetworkString("update_upgrade")

--------------------------------------------------------------------------------
--INCLUDES
--------------------------------------------------------------------------------
include("printer_config.lua")
include("shared.lua")  

--------------------------------------------------------------------------------
--MAIN CODE
--------------------------------------------------------------------------------

-- Defines a printer's config as self.printer_cfg


--------------Used to change the printer owner from world to ply----------------
hook.Add("playerBoughtCustomEntity", "penismanBuysPrinter", function(ply, entTable, ent)
    ent:CPPISetOwner(ply)
end)



function PrinterCFG(ent_info)

    local printer_id = scripted_ents.Get(ent_info:GetClass()).UniquePrinterID
    ent_info.printer_cfg = printer[printer_id]

end



function ENT:Initialize()

    PrinterCFG(self)

    self:SetModel("models/props_c17/consolebox03a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:SetIsUpgradeUIopen(true) -- Is the upgrad
    self:SetButtonOne(1)--Upgrade levels|
    self:SetButtonTwo(1)--              |
    self:SetButtonThree(1)--            |
    self:SetButtonFour(0)--             |
    self:SetButtonFive(1)--_____________|
    self.timer = CurTime()
    self.Locked = false -- used for the lock printer upgrade
    self.hud_timer = false -- used so player doesnt get spammed with messages

    self.health = self.printer_cfg.health
    self.IsMoneyPrinter = true -- idk couldn't be fucked to change this

    if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then

        phys:Wake()

    end

    self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
    self.sound:SetSoundLevel(52)
    self.sound:PlayEx(0.8, 100)


end



function ENT:OnTakeDamage(dmg)
    if self.burningup then return end

    self.health = (self.health) - dmg:GetDamage()
    if self.health <= 0 then
        local rnd = math.random(1, 10)
        if rnd < 3 then
            self:BurstIntoFlames()
        else
            self:Destruct()
            self:Remove()
        end
    end
end



function ENT:Destruct()
    local vPoint = self:GetPos()
    local effectdata = EffectData()
    effectdata:SetStart(vPoint)
    effectdata:SetOrigin(vPoint)
    effectdata:SetScale(1)
    util.Effect("Explosion", effectdata)
    DarkRP.notify(self:CPPIGetOwner(), 1, 4, DarkRP.getPhrase("money_printer_exploded"))
end



function ENT:BurstIntoFlames()
    DarkRP.notify(self:CPPIGetOwner(), 0, 4, DarkRP.getPhrase("money_printer_overheating"))
    self.burningup = true
    local burntime = math.random(8, 18)
    self:Ignite(burntime, 0)
    timer.Simple(burntime, function() self:Fireball() end)
end



function ENT:Fireball()
    if not self:IsOnFire() then self.burningup = false return end
    local dist = math.random(20, 280) -- Explosion radius
    self:Destruct()
    for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
        if not v:IsPlayer() and not v:IsWeapon() and v:GetClass() ~= "predicted_viewmodel" and not v.IsMoneyPrinter then
            v:Ignite(math.random(5, 22), 0)
        elseif v:IsPlayer() then
            local distance = v:GetPos():Distance(self:GetPos())
            v:TakeDamage(distance / dist * 100, self, self)
        end
    end
    self:Remove()
end



function ENT:Think()

    if not IsValid(self) or self:IsOnFire() then return end

    if CurTime() > self.timer + self.printer_cfg.speedUpgradeArray[self:GetButtonOne()] and
        self:GetMoneyAmount() + self.printer_cfg.printUpgradeArray[self:GetButtonThree()] <=
        self.printer_cfg.storageUpgradeArray[self:GetButtonTwo()] then

        self.timer = CurTime()
        self:SetMoneyAmount(self:GetMoneyAmount() + self.printer_cfg.printUpgradeArray[self:GetButtonThree()])

    elseif CurTime() > self.timer + self.printer_cfg.speedUpgradeArray[self:GetButtonOne()] and
        self:GetMoneyAmount() + self.printer_cfg.printUpgradeArray[self:GetButtonThree()] >
        self.printer_cfg.storageUpgradeArray[self:GetButtonTwo()] then

        self.timer = CurTime()
        self:SetMoneyAmount(self.printer_cfg.storageUpgradeArray[self:GetButtonTwo()])

    end

    print(self.sound)


end



function ENT:Use(act, call)
    if not IsValid( call ) or not call:IsPlayer() then return end

    local eye = call:GetEyeTrace()
    local cursorPos = eye.HitPos
    local localcursorPos = self:WorldToLocal(cursorPos)

    -- USE COLLECT LOGIC --
    if(localcursorPos.x*10 >= 40 and
        localcursorPos.x*10 <= 70 and
        localcursorPos.y*10 > -75 and
        localcursorPos.y*10 < 75) then

        if self.Locked == true and
        call ~= self:CPPIGetOwner() and
        self.hud_timer == false then
            net.Start("printermessage_hint")
                net.WriteString("The printer's locked!")
                net.WriteString("buttons/button14.wav")
                net.WriteString("error")
            net.Send(call)
            self.hud_timer = true
            timer.Simple(1.5,function() self.hud_timer = false end)

        elseif self.Locked == true and
        call == self:CPPIGetOwner() or
        self.Locked == false then
            local money = self:GetMoneyAmount()
                self:SetMoneyAmount(0)
                call:addMoney(money)
                    if money > 0 then
                        net.Start("printermessage_hint")
                            net.WriteString("Collected $"..money.." from "..self.printer_cfg.name)
                            net.WriteString("ambient/water/drip2.wav")
                            net.WriteString("normal")
                        net.Send(call)
                    end
        end

    end

    -- USE UPGRADE LOGIC --
    if(localcursorPos.x*10 >= 0 and
        localcursorPos.x*10 <= 30 and
        localcursorPos.y*10 > -75 and
        localcursorPos.y*10 < 75 and
        self:GetIsUpgradeUIopen() == true) then
        net.Start("entities.printertemplate.ui")
            net.WriteEntity(self)
        net.Send(call)
        self:SetIsUpgradeUIopen(false)
        timer.Simple(0.5,function() self:SetIsUpgradeUIopen(true) end)
    end
end

function ENT:OnRemove()
    if self.sound then
        self.sound:Stop()
    end
end

--BUYING UPGRADES FROM THE UPGRADE DFRAME MENU
--------------------------------------------------------------------------------
net.Receive("button1_logic", function(len, ply)

    if not IsValid( ply ) or not ply:IsPlayer() then return end

    local entity = net.ReadEntity()
    local upgrade_str = net.ReadString()

    if not IsValid(entity) then return end

    -- If someone sends a request to upgrade a printer that has the upgrade disabled,
    -- said someone gets banned
    if upgrade_str == "buyLabel1" and
        entity.printer_cfg.speedUpgrade == false then
        ply:Ban(0, false)
        ply:Kick( [[Arro's printers - don't try to upgrade an upgrade that's disabled]] )
        return
    elseif upgrade_str == "buyLabel2" and
        entity.printer_cfg.storageUpgrade == false then
        ply:Ban(0, false)
        ply:Kick( [[Arro's printers - don't try to upgrade an upgrade that's disabled]] )
        return
    elseif upgrade_str == "buyLabel3" and
        entity.printer_cfg.printUpgrade == false then
        ply:Ban(0, false)
        ply:Kick( [[Arro's printers - don't try to upgrade an upgrade that's disabled]] )
        return
    end


    -- the upgrade logic for the "Speed" upgrade--------------------------------
    if upgrade_str == "buyLabel1" and
        entity:GetButtonOne() >= 6 then
        net.Start("printermessage_hint")
            net.WriteString("Maximum upgrade level reached!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif entity:GetButtonOne() < 6 and
        ply:getDarkRPVar("money") < entity.printer_cfg.speedPriceArray[entity:GetButtonOne()] and
        upgrade_str == "buyLabel1" then
        net.Start("printermessage_hint")
            net.WriteString("Insufficient money for the speed upgrade!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif upgrade_str == "buyLabel1" and
        entity:GetButtonOne() < 6 then
        ply:addMoney(- entity.printer_cfg.speedPriceArray[entity:GetButtonOne()])
        entity:SetButtonOne(entity:GetButtonOne() + 1)
        net.Start("update_upgrade")
        net.Send(ply)
    end

    -- the upgrade logic for the "Storage" upgrade------------------------------
    if upgrade_str == "buyLabel2" and
        entity:GetButtonTwo() >= 6 then
        net.Start("printermessage_hint")
            net.WriteString("Maximum upgrade level reached!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif entity:GetButtonTwo() < 6 and
        ply:getDarkRPVar("money") < entity.printer_cfg.storagePriceArray[entity:GetButtonTwo()] and
        upgrade_str == "buyLabel2" then
        net.Start("printermessage_hint")
            net.WriteString("Insufficient money for the storage upgrade!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif upgrade_str == "buyLabel2" and
        entity:GetButtonTwo() < 6 then
        ply:addMoney(- entity.printer_cfg.storagePriceArray[entity:GetButtonTwo()])
        entity:SetButtonTwo(entity:GetButtonTwo() + 1)
        net.Start("update_upgrade")
        net.Send(ply)
    end

    -- the upgrade logic for the "Print amount" upgrade ------------------------
    if upgrade_str == "buyLabel3" and
        entity:GetButtonThree() >= 6 then
        net.Start("printermessage_hint")
            net.WriteString("Maximum upgrade level reached!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif entity:GetButtonThree() < 6 and
        ply:getDarkRPVar("money") < entity.printer_cfg.printPriceArray[entity:GetButtonThree()] and
        upgrade_str == "buyLabel3" then
        net.Start("printermessage_hint")
            net.WriteString("Insufficient money for the print amount upgrade!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif upgrade_str == "buyLabel3" and
        entity:GetButtonThree() < 6 then
        ply:addMoney(- entity.printer_cfg.printPriceArray[entity:GetButtonThree()])
        entity:SetButtonThree(entity:GetButtonThree() + 1)
        net.Start("update_upgrade")
        net.Send(ply)
    end




end)

net.Receive("button2_logic", function(len, ply)

    local entity = net.ReadEntity()

    if not IsValid( ply ) or not ply:IsPlayer() then return end

    -- If someone somehow sends a request to upgrade a printer that has the upgrade disabled,
    -- it bans him and ends the function
    if entity.printer_cfg.lockUpgrade == false then
        ply:Ban(0, false)
        ply:Kick( [[Arro's printers - don't try to upgrade an upgrade that's disabled]] )
        return
    end

    -- the upgrade logic for the "Lock" upgrade --------------------------------
    if entity:GetButtonFour() >= 1 and
    ply == entity:CPPIGetOwner() then
        net.Start("printermessage_hint")
            net.WriteString("Maximum upgrade level reached!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif entity:GetButtonFour() < 1 and
        ply == entity:CPPIGetOwner() and
        ply:getDarkRPVar("money") < entity.printer_cfg.lockPrice then
        net.Start("printermessage_hint")
            net.WriteString("Insufficient money for the lock upgrade!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif entity:GetButtonFour() < 1 and
        ply ~= entity:CPPIGetOwner() then
        net.Start("printermessage_hint")
            net.WriteString("Only the owner can lock the printer!")
            net.WriteString("buttons/button14.wav")
            net.WriteString("error")
        net.Send(ply)
    elseif ply == entity:CPPIGetOwner() then
        ply:addMoney(- entity.printer_cfg.lockPrice)
        entity:SetButtonFour(entity:GetButtonFour()+1)
        entity.Locked = true
        net.Start("printermessage_hint")
            net.WriteString("You have locked your printer")
            net.WriteString("ambient/levels/canals/drip1.wav")
            net.WriteString("normal")
        net.Send(ply)
        net.Start("update_upgrade")
        net.Send(ply)
        end

end)

net.Receive("givemaxmoney", function(len, ply)

    print(net.ReadEntity())
    ply:Ban(0, false)
    ply:Kick( [[lmao]] )

end)
