require "nvchad.autocmds"

-- Auto-pull config updates from git on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local config_dir = vim.fn.resolve(vim.fn.stdpath("config"))
    local repo_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(config_dir) .. " rev-parse --show-toplevel")[1]
    if not repo_root or repo_root == "" then
      return
    end
    vim.fn.jobstart({ "git", "-C", repo_root, "pull", "--ff-only" }, {
      on_stderr = function(_, data)
        if data then
          for _, line in ipairs(data) do
            if line ~= "" then
              vim.schedule(function()
                vim.notify("Config pull failed: " .. line, vim.log.levels.WARN)
              end)
            end
          end
        end
      end,
      on_exit = function(_, code)
        if code == 0 then
          require("lazy").sync({ show = false })
        end
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("NvimTreeFocus")
    end
  end,
})
