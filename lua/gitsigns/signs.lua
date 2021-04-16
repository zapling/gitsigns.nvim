local Config = require('gitsigns/config').Config

local M = {Sign = {}, }


























M.sign_map = {
   add = "GitSignsAdd",
   delete = "GitSignsDelete",
   change = "GitSignsChange",
   topdelete = "GitSignsTopDelete",
   changedelete = "GitSignsChangeDelete",
   fold = "GitSignsFold",
}

local ns = 'gitsigns_ns'

local sign_define_cache = {}

local function sign_get(name)
   if not sign_define_cache[name] then
      local s = vim.fn.sign_getdefined(name)
      if not vim.tbl_isempty(s) then
         sign_define_cache[name] = s
      end
   end
   return sign_define_cache[name]
end

function M.define(name, opts, redefine)
   if redefine then
      sign_define_cache[name] = nil
      vim.fn.sign_undefine(name)
      vim.fn.sign_define(name, opts)
   elseif not sign_get(name) then
      vim.fn.sign_define(name, opts)
   end
end

function M.remove(bufnr, lnum)
   vim.fn.sign_unplace(ns, { buffer = bufnr, id = lnum })
end

function M.add(cfg, bufnr, signs)
   for lnum, s in pairs(signs) do
      local stype = M.sign_map[s.type]
      local count = s.count

      local cs = cfg.signs[s.type]
      if cfg.signcolumn and cs.show_count and count then
         local cc = cfg.count_chars
         local count_suffix = cc[count] and tostring(count) or (cc['+'] and 'Plus') or ''
         local count_char = cc[count] or cc['+'] or ''
         stype = stype .. count_suffix
         M.define(stype, {
            texthl = cs.hl,
            text = cfg.signcolumn and cs.text .. count_char or nil,
            numhl = cfg.numhl and cs.numhl or nil,
            linehl = cfg.linehl and cs.linehl or nil,
         })
      end

      vim.fn.sign_place(lnum, ns, stype, bufnr, {
         lnum = lnum, priority = cfg.sign_priority,
      })
   end
end



function M.get(bufnr, lnum)
   local placed = vim.fn.sign_getplaced(bufnr, { group = ns, lnum = lnum })[1].signs
   local ret = {}
   for _, s in ipairs(placed) do
      table.insert(ret, s.name)
   end
   return ret
end

return M
