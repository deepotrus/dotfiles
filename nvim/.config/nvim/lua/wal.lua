local M = {}

function M.load()
  local colors = {}
  local path = os.getenv("HOME") .. "/.cache/wal/colors.sh"
  local file = io.open(path, "r")

  if not file then
    vim.notify("wal: could not open " .. path, vim.log.levels.WARN)
    return
  end

  for line in file:lines() do
    -- matches lines like: color0='#130d10'
    local key, val = line:match("^(%w+)='(#%x+)'")
    if key and val then
      colors[key] = val
    end
  end
  file:close()

  -- Register colors as a proper colorscheme
  vim.cmd("highlight clear")
  vim.cmd("set background=dark")
  vim.g.colors_name = "wal"

  local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  local c = colors

  -- Core UI
  hi("Normal",       { fg = c.foreground, bg = c.background })
  hi("NormalFloat",  { fg = c.foreground, bg = c.color0 })
  hi("LineNr",       { fg = c.color8 })
  hi("CursorLineNr", { fg = c.color3, bold = true })
  hi("CursorLine",   { bg = c.color0 })
  hi("Visual",       { bg = c.color8 })
  hi("Search",       { fg = c.background, bg = c.color3 })
  hi("IncSearch",    { fg = c.background, bg = c.color1 })
  hi("StatusLine",   { fg = c.foreground, bg = c.color0 })
  hi("StatusLineNC", { fg = c.color8,     bg = c.color0 })
  hi("VertSplit",    { fg = c.color0 })
  hi("Pmenu",        { fg = c.foreground, bg = c.color0 })
  hi("PmenuSel",     { fg = c.background, bg = c.color4 })
  hi("PmenuSbar",    { bg = c.color0 })
  hi("PmenuThumb",   { bg = c.color8 })
  hi("SignColumn",   { fg = c.color8,     bg = c.background })
  hi("EndOfBuffer",  { fg = c.color0 })
  hi("WinSeparator", { fg = c.color0 })
  hi("Folded",       { fg = c.color8,     bg = c.color0 })
  hi("Directory", { fg = c.color4 })
  hi("netrwSymLink", { fg = c.color5 })

  -- Syntax
  hi("Comment",      { fg = c.color8,  italic = true })
  hi("Constant",     { fg = c.color3 })
  hi("String",       { fg = c.color2 })
  hi("Identifier",   { fg = c.color4 })
  hi("Function",     { fg = c.color4 })
  hi("Statement",    { fg = c.color1 })
  hi("Keyword",      { fg = c.color1 })
  hi("Operator",     { fg = c.color6 })
  hi("PreProc",      { fg = c.color5 })
  hi("Type",         { fg = c.color3 })
  hi("Special",      { fg = c.color6 })
  hi("Error",        { fg = c.color1, bold = true })
  hi("Todo",         { fg = c.background, bg = c.color3, bold = true })
  hi("Underlined",   { fg = c.color4, underline = true })

  -- Diagnostics
  hi("DiagnosticError", { fg = c.color1 })
  hi("DiagnosticWarn",  { fg = c.color3 })
  hi("DiagnosticInfo",  { fg = c.color4 })
  hi("DiagnosticHint",  { fg = c.color6 })
end

return M
