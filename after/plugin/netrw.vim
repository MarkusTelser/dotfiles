if !exists('g:loaded_netrwPlugin')
	finish
endif

" NetRw File browser options
let g:netrw_banner=0
let g:netrw_liststyle=0 " =3 for tree-style
let g:netrw_browse_split=4
let g:netrw_altv=1 " show on left side
let g:netrw_winsize=25
let g:netrw_keepdir=0
let g:netrw_localcopydircmd='cp -r'
