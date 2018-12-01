" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 Sep 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

execute pathogen#infect()

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
"  set backup		" keep a backup file
  set nobackup  "overriding this
endif
set history=100		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
"map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

  " Auto switch to the current directory of the open file.
  autocmd BufEnter * lcd %:p:h

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Allow windows to get fully squashed
set winminheight=0  

"
" Switch between windows, maximizing the current window
"
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_ 

" Recursively search for tag files.
set tags=tags;/

" Enable modelines.
set modeline
set modelines=5

" CTRL+x opens the buffer list
map <C-x> <esc>:Unite buffer<cr>
map <C-c> <esc>:UniteWithProjectDir -start-insert file_rec<cr>

" gz in command mode closes the current buffer
map gz :bdelete<cr>

" g[bB] in command mode switch to the next/prev. buffer
map gb :bnext<cr>
map gB :bprev<cr>

" Toggle NerdTREE
map X <esc>:NERDTreeToggle<CR>

" Close all other open windows.
map Y <esc>:only<CR>

let mapleader=";"

map <leader>a <esc>:tabnew<CR>
map <leader>d <esc>:tabprev<CR>
map <leader>f <esc>:tabnext<CR>

let g:EasyMotion_do_mapping = 0 " Disable default mappings
map <Leader>s <Plug>(easymotion-s2)
map <Leader>w <Plug>(easymotion-bd-w)
map <Leader>e <Plug>(easymotion-bd-e)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>l <Plug>(easymotion-bd-jk)

" Paste to ix.io
noremap <silent> <leader>i :w !ix<CR>

" Auto-indent
set cindent
set smartindent
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2
set cinkeys=0{,0},0),:,0#,!^F,o,O,e

" Toggle auto-indent
map Q <esc>:setl ai! si! ai? si?<CR>

" Disable bells.
set visualbell t_vb=

" Screen centering
nmap <space> zz
nmap n nzz
nmap N Nzz

if has("autocmd")
   augroup module
   autocmd BufRead,BufNewFile *.module,*.install,*.profile,*.theme set filetype=php
   au BufNewFile,BufRead *.ejs set filetype=html
   autocmd BufNewFile,BufReadPost *.md set filetype=markdown
   autocmd BufNewFile,BufReadPost *.twig set filetype=jinja
   augroup END
   autocmd BufRead,BufNewFile *.txt set wrap
   autocmd BufRead,BufNewFile *.txt set linebreak
   autocmd BufRead,BufNewFile *.txt set nolist " list disables linebreak.
   autocmd FileType python setlocal shiftwidth=2 tabstop=2

endif

" Javascript highlight settings.
let g:javascript_plugin_jsdoc = 1

" Alternate color schemes.
syntax enable
set background=dark
" colorscheme colibri
colorscheme solarized

