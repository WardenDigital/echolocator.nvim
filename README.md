# This is a plugin for interacting with docker. 
Currently there is a limited functionality with docker containers. Plugin is under construction.
It might be converted into telescope extension in the future.

It utilizes Telescope plugin for UI and search functionality.

## Usage

`lua/plugins/echolocator.lua`:

```lua
return {
    "WardenDigital/echolocator.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    setup = function()
        require("echolocator")
    end,
}

```
For now hotkeys are bound to `<leader>lc` and `<leader>lac` for active and all containers respectively.
