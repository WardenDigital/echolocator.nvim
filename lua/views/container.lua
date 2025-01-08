local utils = require('telescope.previewers.utils')

local M = {
    column_width = 52,
    buf_width = 80,
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
    local body = M.generate_body(entry)
    local labels = M.generate_labels(entry)

    local content = {
        helper_lines,
        header,
        body,
        labels,
    }

    local t = vim.iter(content):flatten(math.huge):totable()

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, t)
    utils.highlighter(bufnr, 'markdown')
end

--- Generate the header for the container
--- @param entry table
--- @return table<string>
M.generate_header = function(entry)
    local name_string = ' | ' .. entry.Names .. ' | '
    local pre_repeats = (M.buf_width - #name_string) / 2
    name_string = string.rep('', pre_repeats, ' ') .. name_string

    local prefix = "##"

    if entry.State == 'running' then
        prefix = prefix .. '##'
    end

    local id_line = prefix .. " ID: `" .. entry.ID .. "`"
    local created_at_line = prefix .. " Created at: `" .. entry.CreatedAt .. "`"

    local id_pad = string.rep(' ', M.column_width - #id_line)
    id_line = id_line .. id_pad .. 'State: ' .. container_state_icons[entry.State] .. ' ' .. entry.State

    local created_at_pad = string.rep(' ', M.column_width - #created_at_line)
    created_at_line = created_at_line ..
        created_at_pad .. "Status: " .. entry.Status

    return {
        string.rep('', M.buf_width, '-'),
        name_string,
        string.rep('', M.buf_width, '-'),
        '',
        id_line,
        '',
        created_at_line,
        '',
        string.rep('', M.buf_width, '-'),
    }
end

--- Generate the labels for the container
--- @param entry table
--- @return table<string>
M.generate_labels = function(entry)
    local labels = entry.Labels

    if labels == '' then
        return {}
    end

    local init_line = '| Labels |'
    local labels_pad = (M.buf_width - #init_line) / 2

    local labels_lines = {
        '',
        string.rep('', M.buf_width, '-'),
        string.rep(' ', labels_pad) .. init_line,
        string.rep('', M.buf_width, '-'),
    }

    for label in string.gmatch(labels, '([^, ]+)') do
        local strings = M._split_by_chunk(label, M.buf_width)
        for _, s in ipairs(strings) do
            table.insert(labels_lines, s)
        end
    end

    return labels_lines
end

--- Function for splitting long lables into multiple lines
--- @param text string
--- @param chunkSize number
--- @return table<string>
M._split_by_chunk = function(text, chunkSize)
    local s = {}
    for i = 1, #text, chunkSize do
        s[#s + 1] = text:sub(i, i + chunkSize - 1)
    end
    return s
end

--- Generate the body for the container
--- @param entry table
--- @return table<string>
M.generate_body = function(entry)
    local image_line = '### Image: `' .. entry.Image .. '`'
    local running_for_line = '### Running For: `' .. entry.RunningFor .. '`'

    local network_line = '### Network: `' .. entry.Networks .. '`'

    local ports_lines = M.generate_ports(entry)

    return {
        '',
        image_line,
        '',
        running_for_line,
        '',
        network_line,
        '',
        unpack(ports_lines),
    }
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
    }
end

--- Generate Ports block
--- @param entry table
--- @return table<string>
M.generate_ports = function(entry)
    local ports_key = '### Ports: '
    local ports_pad = #ports_key
    local ports_lines = { ports_key }

    local ports = string.gmatch(entry.Ports, '([^, ]+)')


    for port in ports do
        table.insert(ports_lines, string.rep(' ', ports_pad) .. port)
    end

    if #ports_lines > 1 then
        ports_lines[1] = ports_lines[1] .. '`' .. string.gsub(ports_lines[2], "%s+", "") .. '`'
        table.remove(ports_lines, 2)
    end

    return ports_lines
end

return M
