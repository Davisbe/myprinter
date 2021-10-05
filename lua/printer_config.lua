printer = {}
--------------------------------------------------------------------------------
--+--+--+--+--+--+--+--+--+--+--FIRST PRINTER--+--+--+--+--+--+--+--+--+--+--+--
--------------------------------------------------------------------------------
printer[1] = {
    ------------------------Name of the printer---------------------------------
    ["name"] = "Bronze tier printer",

    ------------------------Printer's health------------------------------------
    ["health"] = 200,


    ------------------------ UPGRADE CONFIGS -----------------------------------
    ----------------------------------------------------------------------------
    -- Time between each print. First number is the print time when no upgrades
    -- are bought. Next 5 numbers are for each new upgrade ---------------------
    ["speedUpgrade"] = true,
    ["speedUpgradeArray"] = {140, 130, 120, 115, 110, 65},
    

    -- How much money will the printer print each time. First number is the
    -- print time when no upgrades are bought. Next 5 numbers are for each new upgrade
    ["printUpgrade"] = true,
    ["printUpgradeArray"] = {100, 140, 160, 180, 200, 250},
    

    --Storage capacaty. The same idea applies here as for the previous two
    --(first number is the storage space with no upgrades etc.) ----------------
    ["storageUpgrade"] = true,
    ["storageUpgradeArray"] = {10000, 15000, 17500, 20000, 22500, 30000},
    

    -- Health upgrade levels ---------------------------------------------------
    ["healthUpgrade"] = false,
    ["healthUpgradeArray"] = {100, 150, 175, 200, 225, 250},
    

    ------------------------ PRICE CONFIGS -------------------------------------
    ----------------------------------------------------------------------------
    -- Prices for each of the 5 "Speed" upgrades -------------------------------
    ["speedPriceArray"] = {2000, 3000, 3500, 4000, 4500},


    -- Prices for each of the 5 "Print amount" upgrades ------------------------
    ["printPriceArray"] = {2000, 3000, 3500, 4000, 4500},


    -- Prices for each of the 5 "Storage" upgrades -----------------------------
    ["storagePriceArray"] = {3000, 3500, 4000, 4500, 6000},

    ["lockUpgrade"] = true,
    ["lockPrice"] = 20000,
}
