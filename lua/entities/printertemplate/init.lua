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
util.AddNetworkString("printermessage_hint")
util.AddNetworkString("button1_logic")
util.AddNetworkString("printers.create.reqeust")
util.AddNetworkString("printers.create.answer")

--------------------------------------------------------------------------------
--INCLUDES
--------------------------------------------------------------------------------
include("printer_config.lua")
include("shared.lua")  

--------------------------------------------------------------------------------
--MAIN CODE
--------------------------------------------------------------------------------



--------------Used to change the printer owner from world to ply----------------
hook.Add("playerBoughtCustomEntity", "penismanBuysPrinter", function(ply, entTable, ent)
    ent:CPPISetOwner(ply)
end)



function ENT:Initialize()

    if self:GetClass() == "printertemplate" then
        local templatecfg = getPrintersFromSQL()
        self.printer_cfg = templatecfg[1]
    end

    self:SetModel("models/props_c17/consolebox03a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:SetIsUpgradeUIopen(true) -- Is the upgrade UI open
    self:SetButtonOne(1)--Upgrade levels|
    self:SetButtonTwo(1)--              |
    self:SetButtonThree(1)--            |
    self:SetButtonFour(1)--             |
    self:SetButtonFive(1)--_____________|

    -- More stuff needed for clientside
    self:SetPrinterID(self.UniquePrinterID)
    self:SetPrinterName(printer_cfg.name)
    self:SetTotalPrinters(getPrintersAmount())

    local tempUpgrades = ""

    for k, v in ipairs(printer_cfg.upgrades) do
        if v.enabled == 1 then
            tempUpgrades = tempUpgrades
        end
    end

    self:SetEnabledUpgrades(tempUpgrades)

    -- Other stuff
    self.timer = CurTime()
    self.Locked = false -- used for the lock printer upgrade
    self.hud_timer = false -- used so player doesnt get spammed with messages

    self.health = self.printer_cfg.upgrades.healthUpgrade.upgradeArray[1]
    self.IsMoneyPrinter = true -- used for destruction

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
        if rnd < 4 then
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

    if CurTime() > self.timer + self.printer_cfg.upgrades.speedUpgrade.upgradeArray[self:GetButtonOne()] and
        self:GetMoneyAmount() + self.printer_cfg.upgrades.printUpgrade.upgradeArray[self:GetButtonThree()] <=
        self.printer_cfg.upgrades.storageUpgrade.upgradeArray[self:GetButtonTwo()] then

        self.timer = CurTime()
        self:SetMoneyAmount(self:GetMoneyAmount() + self.printer_cfg.upgrades.printUpgrade.upgradeArray[self:GetButtonThree()])

    elseif CurTime() > self.timer + self.printer_cfg.upgrades.speedUpgrade.upgradeArray[self:GetButtonOne()] and
        self:GetMoneyAmount() + self.printer_cfg.upgrades.printUpgrade.upgradeArray[self:GetButtonThree()] >
        self.printer_cfg.upgrades.storageUpgrade.upgradeArray[self:GetButtonTwo()] then

        self.timer = CurTime()
        self:SetMoneyAmount(self.printer_cfg.upgrades.storageUpgrade.upgradeArray[self:GetButtonTwo()])

    end


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
    local getButton = 0


    if not IsValid(entity) then return end


    if upgrade_str == "speedUpgrade" then
        getButton = entity:GetButtonOne()
    elseif upgrade_str == "storageUpgrade" then
        getButton = entity:GetButtonTwo()
    elseif upgrade_str == "printUpgrade" then
        getButton = entity:GetButtonThree()
    end


    -- the upgrade logic for every upgrade other than lock ---------------------
    for k, v in pairs(entity.printer_cfg.upgrades) do

        -- If someone sends a request to upgrade a printer that has the upgrade disabled,
        -- said someone gets banned
        if upgrade_str == k and v.enabled == false then
            ply:Ban(0, false)
            ply:Kick( [[Arro's printers - don't try to upgrade an upgrade that's disabled]] )
        end


        if upgrade_str ~= k or k == "lockUpgrade" then continue end


        if getButton >= 6 then
            net.Start("printermessage_hint")
                net.WriteString("Maximum upgrade level reached!")
                net.WriteString("buttons/button14.wav")
                net.WriteString("error")
            net.Send(ply)
        elseif getButton < 6 and
            ply:getDarkRPVar("money") < v.priceArray[getButton] then
            net.Start("printermessage_hint")
                net.WriteString("Insufficient money for the"..v.displayName.."upgrade!")
                net.WriteString("buttons/button14.wav")
                net.WriteString("error")
            net.Send(ply)
        else
            ply:addMoney(- v.priceArray[getButton])

            if k == "speedUpgrade" then
                entity:SetButtonOne(getButton + 1)
            elseif k == "storageUpgrade" then
                entity:SetButtonTwo(getButton + 1)
            elseif k == "printUpgrade" then
                entity:SetButtonThree(getButton + 1)
            end

        end
    end


    -- the upgrade logic for the "Lock" upgrade --------------------------------
    if upgrade_str == "lockUpgrade" then
        if entity:GetButtonFour() > 1 and
        ply == entity:CPPIGetOwner() then
            net.Start("printermessage_hint")
                net.WriteString("Maximum upgrade level reached!")
                net.WriteString("buttons/button14.wav")
                net.WriteString("error")
            net.Send(ply)
        elseif entity:GetButtonFour() <= 1 and
            ply == entity:CPPIGetOwner() and
            ply:getDarkRPVar("money") < entity.printer_cfg.upgrades.lockUpgrade.priceArray[1] then
            net.Start("printermessage_hint")
                net.WriteString("Insufficient money for the Lock upgrade!")
                net.WriteString("buttons/button14.wav")
                net.WriteString("error")
            net.Send(ply)
        elseif entity:GetButtonFour() <= 1 and
            ply ~= entity:CPPIGetOwner() then
            net.Start("printermessage_hint")
                net.WriteString("Only the owner can lock the printer!")
                net.WriteString("buttons/button14.wav")
                net.WriteString("error")
            net.Send(ply)
        elseif ply == entity:CPPIGetOwner() then
            ply:addMoney(- entity.printer_cfg.upgrades.lockUpgrade.priceArray[1])
            entity:SetButtonFour(entity:GetButtonFour()+1)
            entity.Locked = true
            net.Start("printermessage_hint")
                net.WriteString("You have locked your printer")
                net.WriteString("ambient/levels/canals/drip1.wav")
                net.WriteString("normal")
            net.Send(ply)
        end
    end
end)

function getPrintersAmount()

    local printer_inf = sql.Query("SELECT * FROM arrosprinters_table")
    return #printer_inf

end


function getPrintersFromSQL()
    -- getting printer's info from sv.db
    local printer_inf = sql.Query("SELECT * FROM arrosprinters_table")

    -- changing the previously read info to an organised table for simplicity's sake
    local printers = {}
    for k, v in ipairs(printer_inf) do

        local printer_upgr = sql.Query("SELECT * FROM arrosprinters_tab_upgrades WHERE printerID = "..v.id)

        printers[k] = {
            ["name"] = v.name,
            ["id"] = v.id,
            ["upgrades"] = {}
        }

        for i, u in ipairs(printer_upgr) do

            printers[k].upgrades[u.upgradeName] = {
                ["enabled"] = tonumber(v[u.upgradeName]),
                ["upgradeArray"] = {tonumber(u.value1),
                                    tonumber(u.value2),
                                    tonumber(u.value3),
                                    tonumber(u.value4),
                                    tonumber(u.value5),
                                    tonumber(u.value6)},
                ["priceArray"] = {tonumber(u.price1),
                                    tonumber(u.price2),
                                    tonumber(u.price3),
                                    tonumber(u.price4),
                                    tonumber(u.price5)},
                ["displayName"] = u.displayName,
                ["maxUpgrades"] = tonumber(u.maxUpgrades)
            }
        end

    end

    return printers
end

hook.Add( "InitPostEntity", "createNewPrinters", function()

    local printers = getPrintersFromSQL()

    -- defining a table for the new printer tables
    local ENT_TABLE = {}

    -- looping through each printer confing and creating new tables, storing them in ENT_TABLE
    for k, v in ipairs(printers) do
        -- gets a fresh copy of the printertemplate each time
        ENT_TABLE[k] = scripted_ents.Get("printertemplate")

        -- new table values from the config
        ENT_TABLE[k].PrintName = v.name
        ENT_TABLE[k].UniquePrinterID = v.id
        ENT_TABLE[k].Spawnable = true
        ENT_TABLE[k].printer_cfg = v
    end

    -- registering each new printer with unique tables, so the printers don't just use
    -- identical tables when running InitPostEntity
    for k, v in pairs(ENT_TABLE) do

        print("[Arro's printers] Loading printer - "..v.PrintName)
        scripted_ents.Register(ENT_TABLE[k], "arrosprinter"..k)

    end


end )