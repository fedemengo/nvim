(module mods.tools.codediff {autoload {codediff codediff}})

(codediff.setup {:highlights {:line_insert :#123b10
                              :line_delete :#4a1717}
                 :diff {:layout :side-by-side
                        :jump_to_first_change true
                        :cycle_next_hunk true
                        :cycle_next_file true}
                 :explorer {:position :left
                            :width 40
                            :auto_refresh true
                            :file_filter {:ignore [:.git/**
                                                   :.jj/**
                                                   :*.png
                                                   :*.jpg
                                                   :*.jpeg
                                                   :*.gif
                                                   :*.webp
                                                   :*.svg
                                                   :*.ico
                                                   :*.bmp
                                                   :*.tiff
                                                   :*.tif
                                                   :*.pdf]}}})
