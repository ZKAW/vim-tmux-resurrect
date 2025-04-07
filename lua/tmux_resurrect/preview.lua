local core = require("tmux_resurrect.core")

local M = {}

function M.format(filepath)
  local sessions, windows = core.parse_resurrect_file(filepath)
  local session_names, lines = {}, {}

  for s in pairs(sessions) do table.insert(session_names, s) end
  if #session_names == 0 then session_names = { "Default" } end
  table.sort(session_names)

  for i, session in ipairs(session_names) do
    table.insert(lines, "Session: " .. session)
    table.insert(lines, "")

    local wins = {}
    for _, w in pairs(windows) do
      if w.session == session or session == "Default" then
        table.insert(wins, w)
      end
    end
    table.sort(wins, function(a, b) return a.window_id < b.window_id end)

    for _, w in ipairs(wins) do
      local counts = {}
      for _, pane in ipairs(w.panes) do
        counts[pane.cmd] = (counts[pane.cmd] or 0) + 1
      end

      local summary = {}
      for cmd, count in pairs(counts) do
        table.insert(summary, count > 1 and (cmd .. " (" .. count .. ")") or cmd)
      end

      local win_label = w.name and string.format(" [%s]", w.name) or ""
      table.insert(lines, string.format("• Window %d%s:", w.window_id, win_label))
      table.insert(lines, "  Programs: " .. table.concat(summary, ", "))
      table.insert(lines, "")
    end

    if i < #session_names then
      table.insert(lines, "----------------------------")
      table.insert(lines, "")
    end
  end

  return #lines > 0 and lines or { "No tmux window/pane data found." }
end

return M
