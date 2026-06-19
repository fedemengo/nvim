(module mods.tools.oil {autoload {oil oil}})

(oil.setup {:default_file_explorer true
            :buf_options {:buflisted true
                          :bufhidden :hide}
            :view_options {:show_hidden true}})

(map [:n] :- oil.open {:desc "Open parent directory (oil)"})
