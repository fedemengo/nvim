(module mods.tools.conflict {autoload {conflict :git-conflict}})

(conflict.setup {:highlights {:incoming :DiffAdd :current :DiffText}})
