if exists('g:cactus_loaded')
  finish
endif
let g:cactus_loaded = 1

command! CactusTest call cactus#internal#viewer#open(glob('~/*', 1, 1, 1))
