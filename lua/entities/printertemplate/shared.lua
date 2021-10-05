ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category = "Arro's printers"
ENT.PrintName = "Printer template"

ENT.Spawnable = false

ENT.UniquePrinterID = 1

function ENT:SetupDataTables()

    self:NetworkVar("Int", 0, "MoneyAmount")
    self:NetworkVar("Entity", 1, "owning_ent")
    self:NetworkVar("Bool", 1, "IsUpgradeUIopen")
    self:NetworkVar("Int", 1, "ButtonOne")
    self:NetworkVar("Int", 2, "ButtonTwo")
    self:NetworkVar("Int", 3, "ButtonThree")
    self:NetworkVar("Int", 4, "ButtonFour")
    self:NetworkVar("Int", 5, "ButtonFive")

end

hook.Add( "InitPostEntity", "createNewPrinters", function()


    -- defining a table for the new printer tables
    local ENT_TABLE = {}

    -- looping through each printer confing and creating new tables, storing them in ENT_TABLE
    for k, v in pairs(printer) do
        -- gets a fresh copy of the printertemplate each time
        ENT_TABLE[k] = scripted_ents.Get("printertemplate")

        -- new table values from the config
        ENT_TABLE[k].PrintName = v.name
        ENT_TABLE[k].UniquePrinterID = k
        ENT_TABLE[k].Spawnable = true
    end

    -- registering each new printer with unique tables, so the printers don't just use
    -- identical tables when running InitPostEntity
    for k, v in pairs(ENT_TABLE) do

        print("[Arro's printers] Loading printer - "..v.PrintName)
        scripted_ents.Register(ENT_TABLE[k], "arrosprinter"..k)

    end


end )
