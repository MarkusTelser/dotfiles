" Copy,Cut,Paste to system clipboard
if has('clipboard')
	vmap <C-c> "+yi
	vmap <C-x> "+c
	vmap <C-v> <ESC>"+p
  imap <C-v> <ESC>"+pa
endif

command! W SudaWrite

" strike-through and undo current line
nmap <M-u> <Esc>^i~~<Esc>A~~<Esc>0
nmap <M-U> <Esc>^2x$xx0
