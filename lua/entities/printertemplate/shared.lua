ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category = "Arro's printers"
ENT.PrintName = "Printer template"

ENT.Spawnable = false

-- used to create unique printers from the temlpate
ENT.UniquePrinterID = 1

-- if SERVER and !sql.TableExists("arrosprinters_table") then
    sql.Query("DROP TABLE arrosprinters_table")
    sql.Query("DROP TABLE arrosprinters_tab_upgrades")

    sql.Query([[CREATE TABLE arrosprinters_table (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT,
                  speedUpgrade INTEGER DEFAULT 0,
                  printUpgrade INTEGER DEFAULT 0,
                  storageUpgrade INTEGER DEFAULT 0,
                  healthUpgrade INTEGER DEFAULT 0,
                  lockUpgrade INTEGER DEFAULT 0
                )]])

    sql.Query([[CREATE TABLE arrosprinters_tab_upgrades (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  printerID INTEGER REFERENCES arrosprinters_table(id),
                  upgradeName TEXT,
                  displayName TEXT,
                  maxUpgrades INTEGER DEFAULT 5,
                  price1 INTEGER DEFAULT 0,
                  price2 INTEGER DEFAULT 0,
                  price3 INTEGER DEFAULT 0,
                  price4 INTEGER DEFAULT 0,
                  price5 INTEGER DEFAULT 0,
                  value1 INTEGER DEFAULT 0,
                  value2 INTEGER DEFAULT 0,
                  value3 INTEGER DEFAULT 0,
                  value4 INTEGER DEFAULT 0,
                  value5 INTEGER DEFAULT 0,
                  value6 INTEGER DEFAULT 0
                )]])

    sql.Query("INSERT INTO arrosprinters_table (`name`, `speedUpgrade`, `printUpgrade`, `storageUpgrade`, `healthUpgrade`, `lockUpgrade`)VALUES ('Template printer', 1, 1, 1, 0, 1)")
    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `price2`, `price3`, `price4`, `price5`, `value1`, `value2`, `value3`, `value4`, `value5`, `value6`)VALUES (1, 'printUpgrade', 'Print amount', 100, 200, 300, 400, 500, 100, 200, 300, 400, 500, 600)")
    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `price2`, `price3`, `price4`, `price5`, `value1`, `value2`, `value3`, `value4`, `value5`, `value6`)VALUES (1, 'speedUpgrade', 'Print speed', 100, 200, 300, 400, 500, 140, 120, 100, 80, 60, 40)")
    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `price2`, `price3`, `price4`, `price5`, `value1`, `value2`, `value3`, `value4`, `value5`, `value6`)VALUES (1, 'storageUpgrade', 'Storage', 100, 200, 300, 400, 500, 100, 200, 300, 400, 500, 10000)")
    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `price2`, `price3`, `price4`, `price5`, `value1`, `value2`, `value3`, `value4`, `value5`, `value6`)VALUES (1, 'healthUpgrade', 'Health', 100, 200, 300, 400, 500, 100, 200, 300, 400, 500, 10000)")

    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `value1`)VALUES (1, 'lockUpgrade', 'Lock', 10000, 0)")

    sql.Query("INSERT INTO arrosprinters_table (`name`, `speedUpgrade`, `printUpgrade`, `storageUpgrade`, `healthUpgrade`, `lockUpgrade`)VALUES ('Template printer2', 1, 1, 1, 0, 1)")
    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `price2`, `price3`, `price4`, `price5`, `value1`, `value2`, `value3`, `value4`, `value5`, `value6`)VALUES (2, 'printUpgrade', 'Print amount', 100, 200, 300, 400, 500, 100, 200, 300, 400, 500, 600)")
    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `price2`, `price3`, `price4`, `price5`, `value1`, `value2`, `value3`, `value4`, `value5`, `value6`)VALUES (2, 'speedUpgrade', 'Print speed', 100, 200, 300, 400, 500, 140, 120, 100, 80, 60, 40)")
    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `price2`, `price3`, `price4`, `price5`, `value1`, `value2`, `value3`, `value4`, `value5`, `value6`)VALUES (2, 'storageUpgrade', 'Storage', 100, 200, 300, 400, 500, 100, 200, 300, 400, 500, 10000)")
    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `price1`, `price2`, `price3`, `price4`, `price5`, `value1`, `value2`, `value3`, `value4`, `value5`, `value6`)VALUES (2, 'healthUpgrade', 'Health', 100, 200, 300, 400, 500, 100, 200, 300, 400, 500, 10000)")

    sql.Query("INSERT INTO arrosprinters_tab_upgrades (`printerID`, `upgradeName`, `displayName`, `maxUpgrades`, `price1`, `value1`)VALUES (2, 'lockUpgrade', 'Lock', 1, 10000, 0)")

-- end


function ENT:SetupDataTables()

    self:NetworkVar("Int", 0, "MoneyAmount")
    self:NetworkVar("String", 0, "PrinterName")
    self:NetworkVar("String", 1, "EnabledUpgrades")
    self:NetworkVar("Int", 1, "TotalPrinters")
    self:NetworkVar("Entity", 1, "owning_ent")
    self:NetworkVar("Bool", 1, "IsUpgradeUIopen")
    self:NetworkVar("Int", 1, "ButtonOne")
    self:NetworkVar("Int", 2, "ButtonTwo")
    self:NetworkVar("Int", 3, "ButtonThree")
    self:NetworkVar("Int", 4, "ButtonFour")
    self:NetworkVar("Int", 5, "ButtonFive")
    self:NetworkVar("Int", 6, "PrinterID")

end
