local Path = require("plenary.path")

local M = {}

M.resurrect_dir = vim.fn.expand("~/.local/share/tmux/resurrect/")
M.restore_script = vim.fn.expand("~/.tmux/plugins/tmux-resurrect/scripts/restore.sh")

local function short_command(cmd)
  return (cmd:match("[^/\\]*$") or cmd):match("^[^ ]+") or "unknown"
end

function M.parse_timestamp(filename)
  local ts = filename:match("tmux_resurrect_(%d%d%d%d%d%d%d%dT%d%d%d%d%d%d)")
  if not ts then return nil end
  return {
    timestamp_str = ts,
    time = os.time({
      year = tonumber(ts:sub(1, 4)),
      month = tonumber(ts:sub(5, 6)),
      day = tonumber(ts:sub(7, 8)),
      hour = tonumber(ts:sub(10, 11)),
      min = tonumber(ts:sub(12, 13)),
      sec = tonumber(ts:sub(14, 15)),
    }),
  }
end

function M.format_filename(filename)
  local parsed = M.parse_timestamp(filename)
  return parsed and os.date("%a, %-d %b %Y @ %H:%M", parsed.time) or filename
end

function M.get_timestamp(filename)
  local parsed = M.parse_timestamp(filename)
  return parsed and parsed.time or 0
end

function M.parse_resurrect_file(filepath)
  local lines = Path:new(filepath):readlines() or {}
  local windows, sessions = {}, {}

  for _, line in ipairs(lines) do
    local f = vim.split(line, "\t", { plain = true })
    if f[1] == "window" then
      local session, win_id, name = f[2], tonumber(f[3]), (f[4] or ""):gsub("^:", "")
      local key = session .. ":" .. win_id
      windows[key] = {
        session = session,
        window_id = win_id,
        panes = {},
        name = name ~= "" and name or nil,
      }
    end
  end

  for _, line in ipairs(lines) do
    local f = vim.split(line, "\t", { plain = true })
    if f[1] == "pane" then
      local session, win_id, pane_id = f[2], tonumber(f[3]), tonumber(f[4])
      local layout, cmd = f[5] or "", f[10] or ""
      local key = session .. ":" .. win_id

      sessions[session] = true
      windows[key] = windows[key] or {
        session = session,
        window_id = win_id,
        panes = {},
        name = nil,
      }

      table.insert(windows[key].panes, {
        pane = pane_id,
        layout = layout,
        cmd = short_command(cmd),
      })
    end
  end

  return sessions, windows
end

function M.restore_tmux_session(file)
  local path = M.resurrect_dir .. "/" .. file
  vim.fn.system({ "ln", "-sf", path, M.resurrect_dir .. "/last" })
  vim.fn.system({ "tmux", "run-shell", M.restore_script })
  vim.notify("Tmux session restored from: " .. M.format_filename(file), vim.log.levels.INFO)
end

return M
