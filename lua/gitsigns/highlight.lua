
local api = vim.api

local dprint = require("gitsigns/debug").dprint

local M = {}

local GitSignHl = {}







local hls = {
   GitSignsAdd = { 'GitGutterAdd', 'SignifySignAdd', 'DiffAdd:reverse' },
   GitSignsChange = { 'GitGutterChange', 'SignifySignChange', 'DiffChange:reverse' },
   GitSignsDelete = { 'GitGutterDelete', 'SignifySignDelete', 'DiffDelete:reverse' },
   GitSignsFold = { 'Special:fg' },
   GitSignsCurrentLineBlame = { 'NonText' },
}

local function is_hl_set(hl_name)

   local exists, hl = pcall(api.nvim_get_hl_by_name, hl_name, true)
   local color = hl.foreground or hl.background
   return exists and color ~= nil
end

local function hl_link(to, from, reverse)
   if is_hl_set(to) then
      return
   end

   local mods = {
      reverse = reverse or false,
      fg = false,
   }

   for p, _ in pairs(mods) do
      local sfx = ':' .. p
      if vim.endswith(from, sfx) then
         from = from:sub(1, -(1 + #sfx))
         mods[p] = true
      end
   end

   if not (mods.reverse or mods.fg) then
      vim.cmd(('highlight link %s %s'):format(to, from))
      return
   end

   local exists, hl = pcall(api.nvim_get_hl_by_name, from, true)
   if exists then
      local bg
      if mods.fg then

         local sc_hl = api.nvim_get_hl_by_name('Signcolumn', true)
         bg = sc_hl.background and ('guibg=#%06x'):format(sc_hl.background) or ''
      else
         bg = hl.background and ('guibg=#%06x'):format(hl.background) or ''
      end
      local fg = hl.foreground and ('guifg=#%06x'):format(hl.foreground) or ''
      local rev = mods.reverse and 'gui=reverse' or ''
      vim.cmd(table.concat({ 'highlight', to, fg, bg, rev }, ' '))
   end
end

local function isGitSignHl(hl)
   return hls[hl] ~= nil
end



function M.setup_highlight(hl_name0)
   if not isGitSignHl(hl_name0) then
      return
   end

   local hl_name = hl_name0

   if is_hl_set(hl_name) then

      return
   end

   for _, d in ipairs(hls[hl_name]) do
      if is_hl_set(d:match('%w+')) then
         dprint(('Deriving %s from %s'):format(hl_name, d))
         hl_link(hl_name, d)
         return
      end
   end
end

function M.setup_other_highlight(hl, from_hl)
   local hl_pfx, hl_sfx = hl:sub(1, -3), hl:sub(-2, -1)
   if isGitSignHl(hl_pfx) and (hl_sfx == 'Ln' or hl_sfx == 'Nr') then
      dprint(('Deriving %s from %s'):format(hl, from_hl))
      hl_link(hl, from_hl, hl_sfx == 'Ln')
   end
end

return M
