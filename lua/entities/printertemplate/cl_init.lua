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
    ent_info.printer_cfg = printer[printer_id]

end

function UpgradeLevel(name, ent)

    if name == "speedUpgrade" then
        return ent:GetButtonOne()
    elseif name == "storageUpgrade" then
        return ent:GetButtonTwo()
    elseif name == "printUpgrade" then
        return ent:GetButtonThree()
    elseif name == "lockUpgrade" then
        return ent:GetButtonFour() + 1
    end

end

function UIButtonPressed(ent, upgrade_info, buttonMenu, bw, bh, i_spacing)


    local INFO = upgrade_info

    local upgrade_lvl = UpgradeLevel(INFO.name, ent)

    net.Receive("update_upgrade", function()
        upgrade_lvl = UpgradeLevel(INFO.name, ent)
        print(INFO.name)
    end)

    local name = vgui.Create("DPanel", buttonMenu)
        name:SetPos(0, i_spacing)
        name:SetSize(bw*0.45, bh*0.25)
        name.colorLerp = 00
        name.Paint = function(self, w, h)
            if(self:IsHovered()) then
                self.colorLerp = Lerp(5 * FrameTime(), self.colorLerp, 20)
            else
                self.colorLerp = Lerp(10*FrameTime(), self.colorLerp, 0)
            end

            draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 100+self.colorLerp, 125+self.colorLerp))
            draw.DrawText(INFO.panel_name, "PanelButtonFont", w / 2, h * 0.07, Color(255, 255, 255), 1, 1)
            draw.DrawText("Upgraded:"..(upgrade_lvl - 1).."/"..INFO.max_upgrades, "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
        end

        local netw_send = vgui.Create( "DLabel", name )
        netw_send:SetPos( bw*0.36, 0 )
        netw_send:SetText( "" )
        netw_send:SetSize(bw*0.09, bh*0.25)
        netw_send.buyLerp = 0
        netw_send:SetMouseInputEnabled( true )
        netw_send:SetCursor( "hand" )
        netw_send.Paint = function(self, w, h)
            local parent = self:GetParent()
            local cw, cy = parent:CursorPos()
            local posw, posy = parent:GetPos()
            local sizew, sizey = parent:GetSize()
            if (cw >= posw and
                cy >= posy and
                cw <= sizew and
                cy <= sizey) then
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, w)
            else
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, 0)
            end
            
            draw.RoundedBox(0, w*1.01 - self.buyLerp, 0, w, h, Color(0, 220, 30))

        end

        netw_send.DoClick = function()
            if INFO.name == "lockUpgrade" then
                net.Start("button2_logic")
                    net.WriteEntity(ent)
                    net.WriteString(INFO.netw_send)
                net.SendToServer()
            else
            netw_send.DoClick = function()
                net.Start("button1_logic")
                    net.WriteEntity(ent)
                    net.WriteString(INFO.netw_send)
                net.SendToServer()
            end
        end
    end


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
            draw.SimpleText(string.sub(self.printer_cfg.name, 1, 20),"PrinterFont", 0,-80, Color(120,120,255),1,1)
            draw.SimpleText("$"..self:GetMoneyAmount(), "PrinterFont", 0, -40, Color(120,120,255), 1, 1)

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
        draw.RoundedBox(0, 0, h * 0.05, w, h * 0.95, Color(40, 40, 40))
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
    buttonMenu:SetPos(bgw * 0.075, 0)
    buttonMenu:SetSize(bgw * 0.85, bgh)
    buttonMenu.Paint = function(self, w, h)

        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 0))

    end


    local bw, bh = buttonMenu:GetSize()



    local UPGRADE_LOCATIONS = {}

    UPGRADE_LOCATIONS[1] = {
        ["x"] = 0,
        ["y"] = 0,
    }
    UPGRADE_LOCATIONS[2] = {
        ["x"] = bw * 0.55,
        ["y"] = 0,
    }
    UPGRADE_LOCATIONS[3] = {
        ["x"] = 0,
        ["y"] = bh*0.375,
    }
    UPGRADE_LOCATIONS[4] = {
        ["x"] = bw * 0.55,
        ["y"] = bh*0.375,
    }
    UPGRADE_LOCATIONS[5] = {
        ["x"] = 0,
        ["y"] = bh*0.75,
    }
    UPGRADE_LOCATIONS[6] = {
        ["x"] = bw * 0.55,
        ["y"] = bh*0.75,
    }


    local countAvalUpgr = 0

    if entity.printer_cfg.speedUpgrade == true then
        countAvalUpgr = countAvalUpgr + 1

    end
    if entity.printer_cfg.printUpgrade == true then
        countAvalUpgr = countAvalUpgr + 1
    end
    if entity.printer_cfg.storageUpgrade == true then
        countAvalUpgr = countAvalUpgr + 1
    end
    if entity.printer_cfg.healthUpgrade == true then
        countAvalUpgr = countAvalUpgr + 1
    end



    -- SPEED UPGRADE THING --
    if entity.printer_cfg.speedUpgrade == true then

        local u_speed = vgui.Create("DPanel", buttonMenu)
        if countAvalUpgr == 1 then
            u_speed:SetPos(0, UPGRADE_LOCATIONS[1].y)
            u_speed:SetSize(bw*0.90, ph*0.48*0.25)
            buttonBG:SetSize(pw, ph*0.48 / 3)
        else
            u_speed:SetPos(UPGRADE_LOCATIONS[1].x, UPGRADE_LOCATIONS[1].y)
            u_speed:SetSize(bw*0.45, ph*0.48*0.25)
        end
        u_speed.colorLerp = 0
        u_speed.Paint = function(self, w, h)
            if(self:IsHovered()) then
                self.colorLerp = Lerp(5 * FrameTime(), self.colorLerp, 20)
            else
                self.colorLerp = Lerp(10*FrameTime(), self.colorLerp, 0)
            end

            draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 100+self.colorLerp, 125+self.colorLerp))
            draw.DrawText("Speed", "PanelButtonFont", w / 2, h * 0.07, Color(255, 255, 255), 1, 1)
            draw.DrawText("Upgraded:"..(entity:GetButtonOne() - 1).."/5", "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
        end

        local buyLabel1 = vgui.Create( "DLabel", u_speed )
        buyLabel1:SetPos( bw*0.36, 0 )
        buyLabel1:SetText( "" )
        buyLabel1:SetSize(bw*0.09, bh*0.25)
        buyLabel1.buyLerp = 0
        buyLabel1:SetMouseInputEnabled( true )
        buyLabel1:SetCursor( "hand" )
        buyLabel1.Paint = function(self, w, h)
            local parent = self:GetParent()
            local cw, cy = parent:CursorPos()
            local posw, posy = parent:GetPos()
            local sizew, sizey = parent:GetSize()
            if (cw >= posw and
                cy >= posy and
                cw <= sizew and
                cy <= sizey) then
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, w)
            else
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, 0)
            end
            
            draw.RoundedBox(0, w*1.01 - self.buyLerp, 0, w, h, Color(0, 220, 30))

        end

        buyLabel1.DoClick = function()
            net.Start("button1_logic")
                net.WriteEntity(entity)
                net.WriteString("buyLabel1")
            net.SendToServer()
        end

    table.remove(UPGRADE_LOCATIONS, 1)

    end

    -- STORAGE UPGRADE THING --
    if entity.printer_cfg.storageUpgrade == true then

        local u_storage = vgui.Create("DPanel", buttonMenu)
        u_storage:SetPos(UPGRADE_LOCATIONS[1].x, UPGRADE_LOCATIONS[1].y)
        u_storage:SetSize(bw*0.45, bh*0.25)
        u_storage.colorLerp = 0
        u_storage.Paint = function(self, w, h)
             if(self:IsHovered()) then
                self.colorLerp = Lerp(5 * FrameTime(), self.colorLerp, 20)
            else
                self.colorLerp = Lerp(10*FrameTime(), self.colorLerp, 0)
            end

            draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 100+self.colorLerp, 125+self.colorLerp))
            draw.DrawText("Storage", "PanelButtonFont", w / 2, h * 0.07, Color(255, 255, 255), 1, 1)
            draw.DrawText("Upgraded:"..(entity:GetButtonTwo() - 1).."/5", "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
        end
        local buyLabel2 = vgui.Create( "DLabel", u_storage )
        buyLabel2:SetPos( bw*0.36, 0 )
        buyLabel2:SetText( "" )
        buyLabel2:SetSize(bw*0.09, bh*0.25)
        buyLabel2.buyLerp = 0
        buyLabel2:SetMouseInputEnabled( true )
        buyLabel2:SetCursor( "hand" )
        buyLabel2.Paint = function(self, w, h)
            local parent = self:GetParent()
            local parent2 = parent:GetParent()
            local cw, cy = parent2:CursorPos()
            local posw, posy = parent:GetPos()
            local sizew, sizey = parent:GetSize()
            if (cw >= posw and
                cy >= posy and
                cw <= posw+sizew and
                cy <= posy+sizey) then
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, w)
            else
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, 0)
            end
            
            draw.RoundedBox(0, w*1.01 - self.buyLerp, 0, w, h, Color(0, 220, 30))

        end

        buyLabel2.DoClick = function()
            net.Start("button1_logic")
                net.WriteEntity(entity)
                net.WriteString("buyLabel2")
            net.SendToServer()
        end

    table.remove(UPGRADE_LOCATIONS, 1)

    end


    -- PRINTING AMOUNT UPGRADE THING --
    if entity.printer_cfg.printUpgrade == true then

        local u_amount = vgui.Create("DPanel", buttonMenu)
        if countAvalUpgr == 3 then
            u_amount:SetPos(0, UPGRADE_LOCATIONS[1].y)
            u_amount:SetSize(bw*0.90, bh*0.25)
        else
            u_amount:SetPos(UPGRADE_LOCATIONS[1].x, UPGRADE_LOCATIONS[1].y)
            u_amount:SetSize(bw*0.45, bh*0.25)
        end
        u_amount.colorLerp = 0
        u_amount.Paint = function(self, w, h)
            if(self:IsHovered()) then
                self.colorLerp = Lerp(5 * FrameTime(), self.colorLerp, 20)
            else
                self.colorLerp = Lerp(10*FrameTime(), self.colorLerp, 0)
            end

            draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 100+self.colorLerp, 125+self.colorLerp))
            draw.DrawText("Print amount", "PanelButtonFont", w / 2, h * 0.07, Color(255, 255, 255), 1, 1)
            draw.DrawText("Upgraded:"..(entity:GetButtonThree() - 1).."/5", "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
        end
        local buyLabel3 = vgui.Create( "DLabel", u_amount )
        buyLabel3:SetPos( bw*0.36, 0 )
        buyLabel3:SetText( "" )
        buyLabel3:SetSize(bw*0.09, bh*0.25)
        buyLabel3.buyLerp = 0
        buyLabel3:SetMouseInputEnabled( true )
        buyLabel3:SetCursor( "hand" )
        buyLabel3.Paint = function(self, w, h)
            local parent = self:GetParent()
            local parent2 = parent:GetParent()
            local cw, cy = parent2:CursorPos()
            local posw, posy = parent:GetPos()
            local sizew, sizey = parent:GetSize()
            if (cw >= posw and
                cy >= posy and
                cw <= posw+sizew and
                cy <= posy+sizey) then
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, w)
            else
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, 0)
            end
            
            draw.RoundedBox(0, w*1.01 - self.buyLerp, 0, w, h, Color(0, 220, 30))

        end

        buyLabel3.DoClick = function()
            net.Start("button1_logic")
                net.WriteEntity(entity)
                net.WriteString("buyLabel3")
            net.SendToServer()
        end

    table.remove(UPGRADE_LOCATIONS, 1)

    end

    -- LOCK UPGRADE THING --
    if entity.printer_cfg.lockUpgrade == true then

        local u_lock = vgui.Create("DPanel", buttonMenu)
        u_lock:SetPos(UPGRADE_LOCATIONS[1].x, UPGRADE_LOCATIONS[1].y)
        u_lock:SetSize(bw*0.45, bh*0.25)
        u_lock.colorLerp = 0
        u_lock.Paint = function(self, w, h)

            if(self:IsHovered()) then
                self.colorLerp = Lerp(5 * FrameTime(), self.colorLerp, 20)
            else
                self.colorLerp = Lerp(10*FrameTime(), self.colorLerp, 0)
            end

            draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 100+self.colorLerp, 125+self.colorLerp))
            draw.DrawText("Lock", "PanelButtonFont", w / 2, h * 0.07, Color(255, 255, 255), 1, 1)
            draw.DrawText("Upgraded: "..entity:GetButtonFour().."/1", "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)

        end
        local buyLabel4 = vgui.Create( "DLabel", u_lock )
        buyLabel4:SetPos( bw*0.36, 0 )
        buyLabel4:SetText( "" )
        buyLabel4:SetSize(bw*0.09, bh*0.25)
        buyLabel4.buyLerp = 0
        buyLabel4:SetMouseInputEnabled( true )
        buyLabel4:SetCursor( "hand" )
        buyLabel4.Paint = function(self, w, h)
            local parent = self:GetParent()
            local parent2 = parent:GetParent()
            local cw, cy = parent2:CursorPos()
            local posw, posy = parent:GetPos()
            local sizew, sizey = parent:GetSize()
            if (cw >= posw and
                cy >= posy and
                cw <= posw+sizew and
                cy <= posy+sizey) then
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, w)
            else
                self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, 0)
            end
            
            draw.RoundedBox(0, w*1.01 - self.buyLerp, 0, w, h, Color(0, 220, 30))

        end

        buyLabel4.DoClick = function()
            net.Start("button2_logic")
                net.WriteEntity(entity)
            net.SendToServer()
        end

    table.remove(UPGRADE_LOCATIONS, 1)

    end

    -- -- SILENT PRINTING UPGRADE THING --
    -- local u_silent = vgui.Create("DPanel", buttonMenu)
    -- u_silent:SetPos(bw * 0.55, bh*0.375)
    -- u_silent:SetSize(bw*0.45, bh*0.25)
    -- u_silent.colorLerp = 0
    -- u_silent.Paint = function(self, w, h)

    --     if(self:IsHovered()) then
    --         self.colorLerp = Lerp(5 * FrameTime(), self.colorLerp, 20)
    --     else
    --         self.colorLerp = Lerp(10*FrameTime(), self.colorLerp, 0)
    --     end

    --     draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 100+self.colorLerp, 125+self.colorLerp))
    --     draw.DrawText("Silent print", "PanelButtonFont", w / 2, h * 0.07, Color(255, 255, 255), 1, 1)
    --     draw.DrawText("Upgraded: 0/1", "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
    -- end
    -- local buyLabel5 = vgui.Create( "DLabel", u_silent )
    -- buyLabel5:SetPos( bw*0.36, 0 )
    -- buyLabel5:SetText( "" )
    -- buyLabel5:SetSize(bw*0.09, bh*0.25)
    -- buyLabel5.buyLerp = 0
    -- buyLabel5:SetMouseInputEnabled( true )
    -- buyLabel5:SetCursor( "hand" )
    -- buyLabel5.Paint = function(self, w, h)
    --     local parent = self:GetParent()
    --     local parent2 = parent:GetParent()
    --     local cw, cy = parent2:CursorPos()
    --     local posw, posy = parent:GetPos()
    --     local sizew, sizey = parent:GetSize()
    --     if (cw >= posw and
    --         cy >= posy and
    --         cw <= posw+sizew and
    --         cy <= posy+sizey) then
    --         self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, w)
    --     else
    --         self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, 0)
    --     end
        
    --     draw.RoundedBox(0, w*1.01 - self.buyLerp, 0, w, h, Color(0, 220, 30))

    -- end

    -- buyLabel5.DoClick = function()
    --     net.Start("button1_logic")
    --         net.WriteEntity(entity)
    --         net.WriteString("buyLabel5")
    --     net.SendToServer()
    -- end

    -- -- SO POLICE CANT TRACK YOUR PRINTER UPGRADE THING --
    -- local u_antipolice = vgui.Create("DPanel", buttonMenu)
    -- u_antipolice:SetPos(bw * 0.55, bh*0.75)
    -- u_antipolice:SetSize(bw*0.45, bh*0.25)
    -- u_antipolice.colorLerp = 0
    -- u_antipolice.Paint = function(self, w, h)

    --     if(self:IsHovered()) then
    --         self.colorLerp = Lerp(5 * FrameTime(), self.colorLerp, 20)
    --     else
    --         self.colorLerp = Lerp(10*FrameTime(), self.colorLerp, 0)
    --     end

    --     draw.RoundedBox(0, 0, 0, w, h, Color(self.colorLerp, 100+self.colorLerp, 125+self.colorLerp))
    --     draw.DrawText("Anti police radar", "PanelButtonFont", w / 2, h * 0.07, Color(255, 255, 255), 1, 1)
    --     draw.DrawText("Upgraded: 0/1", "PanelButtonFont2", w / 2, h * 0.6, Color(255, 255, 255), 1, 1)
    -- end
    -- local buyLabel6 = vgui.Create( "DLabel", u_antipolice )
    -- buyLabel6:SetPos( bw*0.36, 0 )
    -- buyLabel6:SetText( "" )
    -- buyLabel6:SetSize(bw*0.09, bh*0.25)
    -- buyLabel6.buyLerp = 0
    -- buyLabel6:SetMouseInputEnabled( true )
    -- buyLabel6:SetCursor( "hand" )
    -- buyLabel6.Paint = function(self, w, h)
    --     local parent = self:GetParent()
    --     local parent2 = parent:GetParent()
    --     local cw, cy = parent2:CursorPos()
    --     local posw, posy = parent:GetPos()
    --     local sizew, sizey = parent:GetSize()
    --     if (cw >= posw and
    --         cy >= posy and
    --         cw <= posw+sizew and
    --         cy <= posy+sizey) then
    --         self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, w)
    --     else
    --         self.buyLerp = Lerp(10 * FrameTime(), self.buyLerp, 0)
    --     end
        
    --     draw.RoundedBox(0, w*1.01 - self.buyLerp, 0, w, h, Color(0, 220, 30))

    -- end

    -- buyLabel6.DoClick = function()
    --     net.Start("button1_logic")
    --         net.WriteEntity(entity)
    --         net.WriteString("buyLabel6")
    --     net.SendToServer()
    -- end


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
        draw.DrawText("Close", "PanelCloseFont", w / 2, h * 0.1, Color(255, 255, 255), 1, 1)
    end
    closeButton.DoClick = function()
        PrinterPanel:Close()
    end

end)


--------------------------------------------------------------------------------
-- NET SENDS AND RECEIVES --
--------------------------------------------------------------------------------
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

function testMaxMoney()
    net.Start("givemaxmoney")

        -- Sets max money for all player printers. USED FOR TESTS. DO NOT DELETE --
        local target = LocalPlayer()
        net.WriteEntity(target)

    net.SendToServer()
end

hook.Add( "InitPostEntity", "refreshSpawnMenu", function()

    hook.GetTable()["OnGamemodeLoaded"]["CreateSpawnMenu"]()

end)
