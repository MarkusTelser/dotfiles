" TODO differentiate between linux, windows (for example clipboard)
" TODO check alternatives for telescope-media-files, weird bug (keeps images on
" screen)
" TODO improve slow start, https://medium.com/usevim/improving-vims-startup-time-beb3f83cbfe8

" pre setup, so everything loads
set nocompatible

" exec host os specific settings
if has("win64") || has("win32") || has("win16")
	runtime ./hosts/windows.vim
elseif has('unix')
	let uname = substitute(system('uname'), '\n', '', '')
	if uname == 'Linux'
		runtime ./hosts/linux.vim
	elseif uname == 'Darwin'
		" macOS
	endif
endif

" set register options for vim session
set viminfo=!,'100,<1000,s100,h

" Enable syntax highlighting
if has('syntax')
	syntax on
endif

" Enable syntax highlighting
if has('filetype')
	filetype on
endif

" Copy to system clipboard
if has('clipboard')
	set clipboard=unnamedplus
endif

" use defined colorscheme (not black-white)
if has('termguicolors')
	set termguicolors
endif

" tab options
set tabstop=2
set shiftwidth=2
set softtabstop=2
set cindent

" scroll/numbers options
set number
set relativenumber
set scroll=3
set scrolloff=10

" display bottom line options
set laststatus=2
set wildmenu
set wildmode=longest:full,full
set showmode
set showcmd
set ruler

" search options
set hlsearch
set ignorecase
set incsearch
set smartcase
set showmatch

" extra graphhic options
set lazyredraw
set background=dark
set wildmenu
set wildmode=longest:full,full
set linebreak
set titlestring=%t "doesnt seem to work in gnome-terminal
set title

" extra backend options
set noswapfile 
set ttyfast
set encoding=utf-8
set autoread
set history=1000

" ensure full color palette
set t_Co=256

" Italics
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

colorscheme sonokai

" current line highlight
set cursorline
highlight CursorLineNr cterm=NONE ctermbg=NONE ctermfg=14 gui=NONE guibg=NONE guifg=#FFFF00
