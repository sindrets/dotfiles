return function()
    require("git-worktree").setup({
        -- change_directory_command = <str> -- default: "cd",
        -- update_on_change = <boolean> -- default: true,
        -- update_on_change_command = <str> -- default: "e .",
        -- clearjumps_on_change = <boolean> -- default: true,
        -- autopush = <boolean> -- default: false,
    })

    require("telescope").load_extension("git_worktree")
end
