if has("nvim")
  let g:plug_home = stdpath('data') . '/plugged'
endif

" plugin manager
call plug#begin()

	" themes
	Plug 'tomasr/molokai'
	Plug 'bluz71/vim-moonfly-colors'
	Plug 'kyoz/purify', { 'rtp': 'vim'} 
	Plug 'bignimbus/pop-punk.vim'
	Plug 'sonph/onehalf', { 'rtp': 'vim' }
	Plug 'NLKNguyen/papercolor-theme'
	Plug 'dracula/vim', { 'as': 'dracula' }
	Plug 'morhetz/gruvbox'
	Plug 'rakr/vim-one'
	Plug 'sainnhe/sonokai'
	Plug 'sainnhe/edge'
	Plug 'sainnhe/gruvbox-material'
	Plug 'wuelnerdotexe/vim-enfocado'
	Plug 'eemed/sitruuna.vim'

	" proper transpranency
	Plug 'xiyaowong/nvim-transparent'

	" status and tab line
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'lambdalisue/battery.vim'
	" Plug 'edkolev/tmuxline.vim'

	" fuzzy file finder
	Plug 'nvim-lua/popup.nvim'
	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
	Plug 'nvim-telescope/telescope-media-files.nvim' 

	" versioning support
	Plug 'mhinz/vim-signify'
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-rhubarb'
	Plug 'junegunn/gv.vim'

	" file explorer
	Plug 'preservim/nerdtree'
	Plug 'johnstef99/vim-nerdtree-syntax-highlight', { 'on': 'NERDTreeToggle'}
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	Plug 'ryanoasis/vim-devicons'
	"Plug 'kyazdani42/nvim-web-devicons'

	" language-server autocompletion support
	Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-buffer'
	Plug 'hrsh7th/cmp-path'
	Plug 'hrsh7th/cmp-cmdline'
	Plug 'ray-x/lsp_signature.nvim'
	Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'neovim/nvim-lspconfig'
	" Plug 'neoclide/coc.nvim', {'branch': 'release'}
	" coc-pyright, coc-prettier, coc-pairs, coc-json, coc-java

	" extras installed
	Plug 'junegunn/goyo.vim'
	Plug 'tpope/vim-commentary'
	Plug 'dstein64/vim-startuptime'
	Plug 'yamatsum/nvim-cursorline'
	Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
	Plug 'gabrielelana/vim-markdown'
	Plug 'lambdalisue/suda.vim'
call plug#end()
