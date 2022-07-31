" Copy,Cut,Paste to system clipboard
if has('clipboard')
	vmap <C-c> "+yi
	vmap <C-x> "+c
	vmap <C-v> <ESC>"+p
  imap <C-v> <ESC>"+pa
endif

command! W SudaWrite
