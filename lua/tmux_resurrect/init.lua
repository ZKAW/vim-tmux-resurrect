local M = {}

function M.setup()
  vim.api.nvim_create_user_command("TmuxResurrect", require("tmux_resurrect.picker").open, {})
end

return M
