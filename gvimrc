set lines=80
set columns=200
syntax enable
set background=dark
colorscheme solarized8_high

if has("clipboard")
  " ALT-x is Cut
  vnoremap <A-x> "+x

  " ALT-c is Copy
  vnoremap <A-c> "+y

  " ALT-v is Paste
  map <A-v> "+gP
  cmap <A-v> <C-R>+
endif

" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
" Uses the paste.vim autoload script.
" Use CTRL-G u to have CTRL-Z only undo the paste.

if 1
  exe 'inoremap <script> <A-v> <C-G>u' . paste#paste_cmd['i']
  exe 'vnoremap <script> <A-v> ' . paste#paste_cmd['v']
endif
