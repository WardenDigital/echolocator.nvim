local M = {}

M.actions = {
    --- Open a terminal in the container tty
    select_default = function(action_state, actions, prompt_bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        local cmd = {
            'vsplit',
            'term://docker',
            'exec',
            '-it',
            entry.value.ID,
            '/bin/bash'
        }

        vim.cmd(table.concat(cmd, ' '))
    end,

    --- Open a terminal while following logs
    logs = function(action_state, actions, prompt_bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        local cmd = {
            'vsplit',
            'term://docker',
            'logs',
            '-f',
            entry.value.ID
        }

        vim.cmd(table.concat(cmd, ' '))
    end,

    start = function(action_state)
        local entry = action_state.get_selected_entry()

        local cmd = {
            '!docker',
            'start',
            entry.value.ID
        }

        vim.cmd(table.concat(cmd, ' '))
    end,

    stop = function(action_state)
        local entry = action_state.get_selected_entry()

        local cmd = {
            '!docker',
            'stop',
            entry.value.ID
        }

        vim.cmd(table.concat(cmd, ' '))
    end,

    restart = function(action_state)
        local entry = action_state.get_selected_entry()

        local cmd = {
            '!docker',
            'restart',
            entry.value.ID
        }

        vim.cmd(table.concat(cmd, ' '))
    end,

    delete = function(action_state)
        local entry = action_state.get_selected_entry()

        local cmd = {
            '!docker',
            'stop',
            entry.value.ID,
            '&&',
            'docker',
            'rm',
            entry.value.ID
        }

        vim.cmd(table.concat(cmd, ' '))
    end
}

return M
