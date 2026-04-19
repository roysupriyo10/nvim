-- set before any bootstrapping
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- set core options first, reason for segregation is profile specific loading of options later, extra plugins for work profile, etc
require("core")

-- load the profile that was detected at runtime
-- require("profiles").apply()
