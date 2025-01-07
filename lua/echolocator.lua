local M = {}

M.locate_containers = function(opts)
    opts = opts or {}

    local locator = require("locators.container")
    locator.locate(opts)
end

vim.keymap.set('n', '<leader>lc', function() M.locate_containers({ all = false }) end,
    { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lac', function() M.locate_containers({ all = true }) end,
    { noremap = true, silent = true })

return M
