local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local previewers = require('telescope.previewers')
local view_generator = require('views.container')
local container_locator_actions = require('actions.container').actions
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {
    all = false
}

M.locate = function(opts)
    opts = opts or {}
    M.all = opts.all or false
    pickers.new(opts, {
        prompt_title = 'Docker Containers',
        finder = M.construct_finder(),
        previewer = M.construct_previewer(),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            M.construct_mappings(prompt_bufnr, map)
            return true
        end
    }):find()
end

--- Reload the finder with the new options
--- @param prompt_bufnr number
M.realod_finder = function(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    picker:refresh(M.construct_finder())
end

--- Construct the finder for the containers
--- @return table
M.construct_finder = function()
    return finders.new_async_job({
        command_generator = function()
            return M.construct_list_command()
        end,
        entry_maker = function(entry)
            entry = vim.fn.json_decode(entry)
            return {
                display = M._construct_finder_name(entry),
                ordinal = M._construct_finder_ordinal(entry),
                value = entry,
            }
        end
    })
end

--- Construct the previewer for the containers
--- @return table
M.construct_previewer = function()
    return previewers.new_buffer_previewer({
        title = 'Docker Container Preview',
        define_preview = function(self, entry)
            view_generator.generate_view_table(entry.value, self.state.bufnr)
        end
    })
end

--- Construct the command to list containers
--- @return table<string>
M.construct_list_command = function()
    local cmd = {}

    table.insert(cmd, 'docker')
    table.insert(cmd, 'ps')

    if M.all then
        table.insert(cmd, '-a')
    end

    table.insert(cmd, '--format')
    table.insert(cmd, 'json')
    return cmd
end

--- Construct the mappings for the finder
--- @param prompt_bufnr number
M.construct_mappings = function(prompt_bufnr, map)
    -- Open the terminal in the current buffer
    actions.select_default:replace(function()
        container_locator_actions.select_default(action_state, actions, prompt_bufnr)
    end)

    map('n', 'l', function()
        container_locator_actions.logs(action_state, actions, prompt_bufnr)
    end)

    map('n', 's', function()
        local container = action_state.get_selected_entry().value
        local is_running = container.State == 'running'
        if is_running then
            container_locator_actions.stop(action_state)
        else
            container_locator_actions.start(action_state)
        end
        M.realod_finder(prompt_bufnr)
    end)

    map('n', 'r', function()
        container_locator_actions.restart(action_state)
    end)

    map('n', 'd', function()
        container_locator_actions.delete(action_state)
    end)
end

--- Private function for construting the name displayed in finder
M._construct_finder_name = function(entry)
    local name = ''
    if entry.State ~= 'running' then
        name = ''
    end
    return name .. ' ' .. entry.Names
end

--- Private function for constructing the ordinal for the finder (search key)
M._construct_finder_ordinal = function(entry)
    return entry.Names .. entry.Image .. entry.Networks .. entry.Ports .. entry.State
end

return M
