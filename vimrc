" Make Command + Left behave as Home
noremap <C-A> ^
inoremap <C-A> <Esc>^i
vnoremap <C-A> ^

" Make Command + Right behave as End
noremap <C-E> $
inoremap <C-E> <Esc>A
vnoremap <C-E> $

" Map ^[f (Esc + f) to move to the next word
noremap <Esc>f w
inoremap <Esc>f <Esc>wi
vnoremap <Esc>f w

" Map ^[b (Esc + b) to move to the previous word
noremap <Esc>b b
inoremap <Esc>b <Esc>bi
vnoremap <Esc>b b

