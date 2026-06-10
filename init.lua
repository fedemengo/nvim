if vim.fn.has("nvim-0.12") == 0 then
  error("neovim 0.12+ required")
end

local aniseed_path = vim.fn.stdpath("data") .. "/lazy/aniseed"

if not vim.uv.fs_stat(aniseed_path) then
  vim.fn.mkdir(vim.fn.fnamemodify(aniseed_path, ":h"), "p")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/Olical/aniseed.git",
    aniseed_path,
  })
  if vim.v.shell_error ~= 0 then
    error("failed to bootstrap aniseed")
  end
end

vim.opt.rtp:prepend(aniseed_path)
vim.g["aniseed#env"] = { module = "init", compile = true }
