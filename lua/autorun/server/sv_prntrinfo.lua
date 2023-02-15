-- ConVar used to figure out how many printers client has to register
count = sql.Query("SELECT COUNT(*) 'printer_cnt' FROM arrosprinters_table")

CreateConVar('arrosprinters_initial_printer_count', 0, FCVAR_REPLICATED)
GetConVar( 'arrosprinters_initial_printer_count' ):SetInt( count[1].printer_cnt )
