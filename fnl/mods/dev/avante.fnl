(module mods.dev.avante {autoload {avante :avante
                                   api :avante.api
                                   avante_lib :avante_lib}})

(avante_lib.load)

(local config {:provider "ollama"
               :vendors {:ollama {:__inherited_from "openai"
                                :api_key_name ""
                                :endpoint "http://harlie:11434/v1"
                                :model "marco-o1:7b-fp16"}}})
(avante.setup config)

(map [:n :v] :<C-a>a (bindf api.ask) {:desc "Open avante sidebar"})
(map [:n :v] :<C-a>f (bindf api.ask {:floating true}) {:desc "Open floating prompt"})
(map [:n] :<C-a>e (bindf api.edit) {:desc "Edit current selection"})
(map [:n] :<C-a>r (bindf api.refresh) {:desc "Refresh sidebar"})
(map [:n] :<C-a>p (bindf api.switch_provider) {:desc "Switch AI provider"})
(map [:n] :<C-a>g (bindf api.get_suggestion) {:desc "Get current suggestion"})
(map [:n] :<C-a>b (bindf api.build) {:desc "Build avante"})
(map [:n] :<C-a>F (bindf api.focus) {:desc "Focus sidebar/code/input"})
