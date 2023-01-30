function ensure(user, repo)
    local pack_path = vim.fn.stdpath("data") .. "/site/pack"
    local install_path = string.format("%s/packer/start/%s", pack_path, repo)
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        vim.fn.execute(string.format("!git clone https://github.com/%s/%s %s", user, repo, install_path))
        vim.fn.execute(string.format("packadd %s", repo))
    end
end

ensure("wbthomason", "packer.nvim")
ensure("Olical", "aniseed")
ensure("lewis6991", "impatient.nvim")

require("impatient").enable_profile()

vim.g["aniseed#env"] = {
  module = "startup",
  compile = true
}

