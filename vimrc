" ==============================================================================
" Keycode Timeout (Prevents Escape delays / unwanted Normal mode drops)
" ==============================================================================
set ttimeout
set ttimeoutlen=10

" ==============================================================================
" Start / End of Line (Cmd + Left / Cmd + Right)
" ==============================================================================
" iTerm2 sends 0x01 (Ctrl+A) for Cmd+Left and 0x05 (Ctrl+E) for Cmd+Right
noremap  <C-A> ^
noremap  <C-E> $
inoremap <C-A> <C-O>^
inoremap <C-E> <C-O>A
vnoremap <C-A> ^
vnoremap <C-E> $

" MacVim / GUI support (<D-> = Command key)
noremap  <D-Left>  ^
noremap  <D-Right> $
inoremap <D-Left>  <C-O>^
inoremap <D-Right> <C-O>A
vnoremap <D-Left>  ^
vnoremap <D-Right> $

" Standard Home / End key support
noremap  <Home> ^
noremap  <End>  $
inoremap <Home> <C-O>^
inoremap <End>  <C-O>A
vnoremap <Home> ^
vnoremap <End>  $

" ==============================================================================
" Word Navigation (Option + Left / Option + Right)
" ==============================================================================
" Esc + b / Esc + f (sent by Option + Left / Right in iTerm2)
noremap  <Esc>b b
noremap  <Esc>f w
inoremap <Esc>b <C-O>b
inoremap <Esc>f <C-O>w
vnoremap <Esc>b b
vnoremap <Esc>f w

" Backup for raw arrow escape sequences (Option + Left / Right)
noremap  <Esc>[1;3D b
noremap  <Esc>[1;3C w
inoremap <Esc>[1;3D <C-O>b
inoremap <Esc>[1;3C <C-O>w
vnoremap <Esc>[1;3D b
vnoremap <Esc>[1;3C w

" Meta notation fallback (<M-> = Alt/Option)
noremap  <M-b> b
noremap  <M-f> w
inoremap <M-b> <C-O>b
inoremap <M-f> <C-O>w
vnoremap <M-b> b
vnoremap <M-f> w
