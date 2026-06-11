-- Functional tests run headless inside the installed test environment:
--   make test-install && make test-functional
local failures = {}

local function check(cond, msg)
  if not cond then
    table.insert(failures, msg)
  end
end

local ok, err = pcall(function()
  require("lazy").load({ plugins = { "oil.nvim", "telescope.nvim" } })

  local config = vim.fn.stdpath("config")
  local telescope_mod = require("mods.tools.telescope")
  local buffer_dir = telescope_mod["buffer-dir"]
  check(type(buffer_dir) == "function", "mods.tools.telescope should export buffer-dir")

  -- oil buffer: cwd resolves to the directory oil is showing
  vim.cmd.edit(config .. "/fnl")
  check(vim.bo.filetype == "oil", "editing a directory should open an oil buffer, got ft=" .. vim.bo.filetype)
  local dir = buffer_dir() or "<nil>"
  check(not dir:match("^oil://"), "buffer-dir should strip the oil:// scheme, got " .. dir)
  check(vim.fn.isdirectory(dir) == 1, "buffer-dir should return a real directory, got " .. dir)
  check(vim.endswith(dir, "/fnl"), "buffer-dir should return the directory oil is showing, got " .. dir)

  -- regular buffer: falls back to telescope's buffer_dir
  vim.cmd.edit(config .. "/init.lua")
  dir = buffer_dir() or "<nil>"
  check(vim.fn.isdirectory(dir) == 1, "buffer-dir fallback should return a real directory, got " .. dir)
end)

if not ok then
  table.insert(failures, "test run errored: " .. tostring(err))
end

if #failures > 0 then
  for _, f in ipairs(failures) do
    print("FAIL: " .. f)
  end
  vim.cmd("cquit! 1")
else
  print("OK: headless tests passed")
  vim.cmd("quitall!")
end
