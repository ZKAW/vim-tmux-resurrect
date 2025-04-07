local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")

local core = require("tmux_resurrect.core")
local preview = require("tmux_resurrect.preview")

local M = {}

function M.open()
  local files = vim.fn.readdir(core.resurrect_dir)
  local entries = {}

  for _, file in ipairs(files) do
    if file:match("^tmux_resurrect_%d+T%d+%.txt$") then
      local filepath = core.resurrect_dir .. "/" .. file
      local parsed_sessions, _ = core.parse_resurrect_file(filepath)
      local session_names = {}

      for session in pairs(parsed_sessions or {}) do
        if not session:match("^%d+$") then
          table.insert(session_names, session)
        end
      end

      table.sort(session_names)

      local display_parts = { core.format_filename(file) }
      if #session_names > 0 then
        table.insert(display_parts, "– " .. table.concat(session_names, ", "))
      end

      table.insert(entries, {
        display = table.concat(display_parts, " "),
        value = file,
        ordinal = file .. " " .. table.concat(session_names, " "),
        timestamp = core.get_timestamp(file),
      })
    end
  end

  table.sort(entries, function(a, b) return a.timestamp > b.timestamp end)

  pickers.new({}, {
    prompt_title = "Tmux Resurrect Files",
    finder = finders.new_table {
      results = entries,
      entry_maker = function(entry) return entry end,
    },
    previewer = previewers.new_buffer_previewer {
      define_preview = function(self, entry)
        local output = preview.format(core.resurrect_dir .. "/" .. entry.value)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, output)
      end,
    },
    sorter = conf.generic_sorter({}),
    initial_mode = "normal",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local selected = action_state.get_selected_entry().value
        actions.close(bufnr)
        core.restore_tmux_session(selected)
      end)
      return true
    end,
  }):find()
end

return M
