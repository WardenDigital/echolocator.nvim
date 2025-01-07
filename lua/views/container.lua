local utils = require('telescope.previewers.utils')

local M = {
    column_width = 60,
}

local container_state_icons = {
    running = '',
    stopped = '',
    paused = '',
    restarting = '',
    removing = '',
    exited = '󰩈',
    dead = '󰮢',
}

--- Generate the view table for the container
--- @param entry table
M.generate_view_table = function(entry, bufnr)
    local helper_lines = M.get_helper_lines()
    local header = M.generate_header(entry)

    local t = {}

    for _, line in ipairs(helper_lines) do
        table.insert(t, line)
    end

    for _, line in ipairs(header) do
        table.insert(t, line)
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, t)
    utils.highlighter(bufnr, 'markdown')
end

--- Generate the header for the container
--- @param entry table
--- @return table<string>
M.generate_header = function(entry)
    local header = { '' }

    local intro_line = "##"

    if entry.State == 'running' then
        intro_line = intro_line .. '##'
    end

    intro_line = intro_line .. " Container: " .. entry.Names
    local pad = string.rep(' ', M.column_width - #intro_line)
    intro_line = intro_line .. pad .. 'State: ' .. container_state_icons[entry.State] .. ' ' .. entry.State

    table.insert(header, intro_line)
    table.insert(header, '')

    table.insert(header, string.rep('', 80, '-'))

    return header
end

--- Get the helper lines for the container
--- @return table<string>
M.get_helper_lines = function()
    return {
        '',
        '# (`s`) for `start/stop` | (`r`) for `restart` | (`d`) for `delete`',
        '',
        '# (`l`) for `logs`',
        '',
        '# (`Enter` | `<CR>`) for `ssh`',
        '',
        string.rep('', 80, '-'),
    }
end

return M
