include("printer_config.lua")
include("shared.lua")

--------------------------------------------------------------------------------
-- FONTS --
--------------------------------------------------------------------------------
surface.CreateFont( "PrinterFont", {
    font = "Arial",
    extended = false,
    size = 30,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )
surface.CreateFont( "PrinterButtonFont", {
    font = "Arial",
    extended = false,
    size = 32,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "MoneyFont", {
    font = "Arial",
    extended = false,
    size = 15,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "PanelCloseFont", {
    font = "Arial",
    extended = false,
    size = 15,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "PanelButtonFont", {
    font = "Arial",
    extended = false,
    size = 30,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "PanelButtonFont2", {
    font = "Arial",
    extended = false,
    size = 15,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )


--------------------------------------------------------------------------------
-- PRINTER MODEL & 3D2D --
--------------------------------------------------------------------------------

function PrinterCFG(ent_info)

    local printer_id = scripted_ents.Get(ent_info:GetClass()).UniquePrinterID
    ent_info.printer_cfg = arroprinter[printer_id]

end



function ENT:Initialize()

    PrinterCFG(self)

end



function ENT:Draw()

    self:DrawModel()

    local pos = self:GetPos()
    local ang = self:GetAngles()
    local eye = LocalPlayer():GetEyeTrace()
    local cursorPos = eye.HitPos
    local localcursorPos = self:WorldToLocal(cursorPos)

    ang:RotateAroundAxis(ang:Up(), 90)

    cam.Start3D2D(pos + ang:Up() * 8, ang, 0.1)


        -- TITLE AND MONEY AMOUNT --
        draw.RoundedBox(0, -111, -109, 222, 218, Color(50,50,50))
        draw.RoundedBox(0, -105, -105, 210, 210, Color(10,10,200, 50))
            draw.SimpleText(
                string.sub(self.printer_cfg.name, 1, 20),
                "PrinterFont",
                0,
                -80,
                Color(120,120,255),1,1)

            draw.SimpleText("$"..self:GetMoneyAmount(),
                "PrinterFont",
                0,
                -40,
                Color(120,120,255), 1, 1)

        -- UPGRADE BUTTON OR OWNER NAME --
        if(localcursorPos.x*10 >= 0 and
            localcursorPos.x*10 <= 30 and
            localcursorPos.y*10 > -75 and
            localcursorPos.y*10 < 75) then
            draw.RoundedBox(6, -77.5, -2.5, 155, 35, Color(160,160,100))
            end
        draw.RoundedBox(5, -75, 0, 150, 30, Color(100,120,120))
        draw.SimpleText("Upgrade","PrinterButtonFont", 0,13, Color(160,160,100),1,1)

        -- COLLECT BUTTON --
        if(localcursorPos.x*10 >= 40 and
            localcursorPos.x*10 <= 70 and
            localcursorPos.y*10 > -75 and
            localcursorPos.y*10 < 75) then
            draw.RoundedBox(6, -77.5, 36.5, 155, 35, Color(160,160,100))
            end
        draw.RoundedBox(5, -75, 40, 150, 30, Color(100,120,120))
            draw.SimpleText("Collect","PrinterButtonFont", 0,53, Color(160,160,100),1,1)
        

    cam.End3D2D()

end


--------------------------------------------------------------------------------
-- PRINTER UPGRADE DFRAME --
--------------------------------------------------------------------------------
net.Receive("entities.printertemplate.ui", function()

    if IsValid(PrinterPanel) then return end

    local entity = net.ReadEntity()

    local PrinterPanel = vgui.Create( "DFrame" ) -- Creates the frame itself
    PrinterPanel:SetSize( ScrW() * 0.45, ScrH() * 0.5 ) -- Size of the frame
    PrinterPanel:Center() -- Position on the players screen
    PrinterPanel:SetTitle( "" ) -- Title of the frame
    PrinterPanel:SetVisible( true )
    PrinterPanel:SetDraggable( false ) -- Draggable by mouse?
    PrinterPanel:ShowCloseButton( false ) -- Show the close button?
    PrinterPanel:MakePopup() -- Show the frame
    PrinterPanel.Paint = function(self, w, h)
        draw.RoundedBox(
            0,
            0,
            ScrH() * 0.5 * 0.05,
            w,
            ScrH() * 0.5 * 0.95,
            Color(40, 40, 40))
    end

    local pw, ph = PrinterPanel:GetSize()

    -- UPGRADE MENU SELECTIONS --
    ----------------------------------------------------------------------------
    local buttonBG = vgui.Create("DPanel", PrinterPanel)
    buttonBG:SetPos(0, ph * 0.45)
    buttonBG:SetSize(pw, ph*0.48)
    buttonBG.Paint = function(self, w, h)

        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 100))

    end

    local bgw, bgh = buttonBG:GetSize()

    local buttonMenu = vgui.Create("DPanel", buttonBG)
    buttonMenu:SetPos(bgw * 0.075, ph * 0.05)
    buttonMenu:SetSize(bgw * 0.85, bgh)
    buttonMenu.Paint = function(self, w, h)

        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 0))

    end


    --[[
    Everything below this is fucking shit, but I love it
    --]]



    -- FIGURING OUT THE ENABLED UPGRADES AND STUFF --
    ----------------------------------------------------------------------------

    local countAvalUpgr = 0     -- used to determine the upgrade window
                                -- layout of the buttons

    for k, v in pairs(entity.printer_cfg.upgrades) do
        if v.enabled == true then
            countAvalUpgr = countAvalUpgr + 1
        end
    end


    -- Defines the possible locations of the upgrade buttons
    -- the values are messy because the sizes were achieved
    -- through trial and error. Subject to change
    local UPGRADE_LOCATIONS = {}

    UPGRADE_LOCATIONS[1] = {
        ["x"] = 0,
        ["y"] = 0,
        ["buttonBGx"] = pw,
        ["buttonBGy"] = ph*0.65/3,
    }

    UPGRADE_LOCATIONS[2] = {
        ["x"] = pw * 0.55 * 0.85,
        ["y"] = 0,
        ["buttonBGx"] = pw,
        ["buttonBGy"] = ph*0.65/3,
    }

    UPGRADE_LOCATIONS[3] = {
        ["x"] = 0,
        ["y"] = ph*0.375*0.48,
        ["buttonBGx"] = pw,
        ["buttonBGy"] = ph*0.6* 2/3,
    }

    UPGRADE_LOCATIONS[4] = {
        ["x"] = pw * 0.55 * 0.85,
        ["y"] = ph*0.375*0.48,
        ["buttonBGx"] = pw,
        ["buttonBGy"] = ph*0.6* 2/3,
    }

    UPGRADE_LOCATIONS[5] = {
        ["x"] = 0,
        ["y"] = ph*0.75*0.48,
        ["buttonBGx"] = pw,
        ["buttonBGy"] = ph*0.55,
    }

    UPGRADE_LOCATIONS[6] = {
        ["x"] = pw * 0.55 * 0.85,
        ["y"] = ph*0.75*0.48,
        ["buttonBGx"] = pw,
        ["buttonBGy"] = ph*0.55,
    }


    -- if the amount of enabled upgrades is even, then the last
    -- upgrade button will be the width of 2 upgrade buttons
    --
    -- buttonX will be width of buttons
    if countAvalUpgr % 2 == 0 then
        for k, v in pairs(UPGRADE_LOCATIONS) do
            UPGRADE_LOCATIONS[k].buttonX = pw*0.45*0.85        
        end
    else
        for k, v in pairs(UPGRADE_LOCATIONS) do
            if k ~= countAvalUpgr then
                UPGRADE_LOCATIONS[k].buttonX = pw*0.45*0.85
            else
                UPGRADE_LOCATIONS[k].buttonX = pw*0.85
            end     
        end
    end


    -- The background of the upgrade buttons size get's changed according
    -- to the amount of upgrades enabled
    buttonBG:SetSize(UPGRADE_LOCATIONS[countAvalUpgr].buttonBGx,
        UPGRADE_LOCATIONS[countAvalUpgr].buttonBGy)
    local bw, bh = buttonMenu:GetSize()
    local bgw, bgh = buttonBG:GetSize()



    -- CREATION OF THE UPGRADE BUTTONS --
    ----------------------------------------------------------------------------

    -- Creates the panels for the upgrades which are enabled
    entity.upgradeButtons = {}
    local curCfg = 1



    for k, v in pairs(entity.printer_cfg.upgrades) do
        if v.enabled == true then

            -- Main upgrade label
            entity.upgradeButtons[curCfg] = vgui.Create("DPanel", buttonMenu)
            entity.upgradeButtons[curCfg]:SetPos(UPGRADE_LOCATIONS[curCfg].x, UPGRADE_LOCATIONS[curCfg].y)
            entity.upgradeButtons[curCfg]:SetSize(UPGRADE_LOCATIONS[curCfg].buttonX,  ph*0.48*0.25)
            entity.upgradeButtons[curCfg].colorLerp = 0
            entity.upgradeButtons[curCfg].name = k



            -- Button for purchasing the upgrade
            entity.upgradeButtons["buyLabel"..curCfg] = vgui.Create( "DLabel", entity.upgradeButtons[curCfg] )
            entity.upgradeButtons["buyLabel"..curCfg]:SetSize(pw*0.08, ph*0.12)
            entity.upgradeButtons["buyLabel"..curCfg]:SetPos(
                entity.upgradeButtons[curCfg]:GetSize() - entity.upgradeButtons["buyLabel"..curCfg]:GetSize())
            entity.upgradeButtons["buyLabel"..curCfg]:SetText( "" )
            entity.upgradeButtons["buyLabel"..curCfg].buyLerp = 0
            entity.upgradeButtons["buyLabel"..curCfg]:SetMouseInputEnabled( true )
            entity.upgradeButtons["buyLabel"..curCfg]:SetCursor( "hand" )


            -- starts upgrade logic
            entity.upgradeButtons["buyLabel"..curCfg].DoClick = function()
                net.Start("button1_logic")
                    net.WriteEntity(entity)
                    net.WriteString(k)
                net.SendToServer()
            end


            -- Paint functions
            entity.upgradeButtons[curCfg].Paint = function(self, w, h)
                if(self:IsHovered()) then
                    self.colorLerp = Lerp(5*FrameTime(), self.colorLerp, 20)
                else
                    self.colorLerp = Lerp(10*FrameTime(), self.colorLerp, 0)
                end

                draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 100+self.colorLerp, 125+self.colorLerp))
                draw.DrawText(v.displayName, "PanelButtonFont", w / 2, h * 0.07, Color(255, 255, 255), 1, 1)

                -- the fact that I need entity:GetButtonOne() requires this monstrosity 
                if self.name == "speedUpgrade" then
                    draw.DrawText("Upgraded:"..(entity:GetButtonOne() - 1).."/5",
                        "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
                elseif self.name == "storageUpgrade" then
                    draw.DrawText("Upgraded:"..(entity:GetButtonTwo() - 1).."/5",
                        "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
                elseif self.name == "printUpgrade" then
                    draw.DrawText("Upgraded:"..(entity:GetButtonThree() - 1).."/5",
                        "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
                elseif self.name == "lockUpgrade" then
                    draw.DrawText("Upgraded:"..(entity:GetButtonFour() - 1).."/1",
                        "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
                end
            end

            entity.upgradeButtons["buyLabel"..curCfg].Paint = function(self, w, h)
                if (self:IsHovered() or
                    self:GetParent():IsHovered()) then
                    self.buyLerp = Lerp(10*FrameTime(), self.buyLerp, w)
                else
                    self.buyLerp = Lerp(10*FrameTime(), self.buyLerp, 0)
                end
                
                draw.RoundedBox(0, w*1.01 - self.buyLerp, 0, w, h, Color(0, 220, 30))
            end


            curCfg = curCfg + 1

        end
    end



    -- CLOSE BUTTON --
    ----------------------------------------------------------------------------
    local closeButton = vgui.Create("DButton", PrinterPanel)
    closeButton:SetText("")
    closeButton:SetPos(pw*0.91, 0)
    closeButton:SetSize(pw * 0.1, ph * 0.05)
    closeButton.colorLerp = 0
    closeButton.Paint = function(self, w, h)
        if(self:IsHovered()) then
            self.colorLerp = Lerp(0.075, self.colorLerp, 50)
        else
            self.colorLerp = Lerp(0.025, self.colorLerp, 0)
        end

        draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 145 + self.colorLerp, 200 + self.colorLerp))
        draw.DrawText("Close", "PanelCloseFont", w / 2, h * 0.15, Color(255, 255, 255), 1, 1)
    end
    closeButton.DoClick = function()
        PrinterPanel:Close()
    end

    PrinterPanel:SetSize( ScrW() * 0.45, bgh + ph * 0.5) -- Size of the frame
    PrinterPanel:Center() -- Position on the players screen
    pw, ph = PrinterPanel:GetSize()

end)


--------------------------------------------------------------------------------
-- OTHER NET SENDS AND RECEIVES --
--------------------------------------------------------------------------------

-- for printer notifications for upgrades
net.Receive("printermessage_hint", function()

    local printerMessage = net.ReadString()
    local printerSound = net.ReadString()
    local notifType = net.ReadString()
    
    if notifType == "normal" then
        notifType = 0
    elseif notifType == "error" then
        notifType = 1
    end
        
    notification.AddLegacy( printerMessage, notifType, 5 )
    surface.PlaySound( printerSound )

end)


--------------------------------------------------------------------------------
-- OTHER --
--------------------------------------------------------------------------------

-- Refreshes the spawnlist, so the printers are visible
hook.Add( "InitPostEntity", "refreshSpawnMenu", function()

    hook.GetTable()["OnGamemodeLoaded"]["CreateSpawnMenu"]()

end)

-- boop
function testMaxMoney()
    net.Start("givemaxmoney")

        local target = LocalPlayer()
        net.WriteEntity(target)

    net.SendToServer()
end
