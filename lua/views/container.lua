local utils = require('telescope.previewers.utils')

local M = {
    padding = 4,
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
    local view_table = { '```' }
    view_table = M._add_to_view_table(view_table, M.generate_header(entry))
    table.insert(view_table, '```')
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, view_table)
    utils.highlighter(bufnr, 'markdown')
end

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

M._add_to_view_table = function(view_table, values)
    view_table = view_table or {}

    local t = M._get_helper_lines()

    for _, value in ipairs(values) do
        table.insert(t, value)
    end

    return t
end

M._get_helper_lines = function()
    local lines = {
        '',
        '# (`s`) for `start/stop` | (`r`) for `restart` | (`d`) for `delete`',
        '',
        '# (`l`) for `logs`',
        '',
        '# (`Enter` | `<CR>`) for `ssh`',
        '',
    }

    table.insert(lines, string.rep('', 80, '-'))

    return lines
end

return M
