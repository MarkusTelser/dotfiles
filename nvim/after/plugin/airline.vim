if !exists('g:loaded_airline')
	finish
endif

let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#whitespace#enabled = 0

" individual separators
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''

" tab line settings
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" battery extension
let g:battery#update_statusline = 1
let g:battery#update_interval = 5000

function! Battery_icon() 
  if !battery#is_charging()
		let l:battery_icon = {
			\ 5: " ",
			\ 4: " ",
			\ 3: " ",
			\ 2: " ",
			\ 1: " "}
    
		let l:backend = battery#backend()
		let l:nf = float2nr(round(backend.value / 20.0))
		return printf('%s', get(battery_icon, nf))
	endif
	return '🗲'
endfunction

let g:airline_section_z = '%p%%%#__accent_bold#%{g:airline_symbols.linenr}%l%#__restore__#%#__accent_bold#/%L%{g:airline_symbols.maxlinenr}%#__restore__#%#__accent_bold#%{g:airline_symbols.colnr}%v%#__restore__# '

call airline#parts#define_raw('foo', '%{strftime("%H:%M")} | %{Battery_icon()} %{battery#value()}%% ')
call airline#parts#define_minwidth('foo', 50)
call airline#parts#define_accent('foo', 'bold')
let g:airline_section_z = airline#section#create_right(['ffenc','foo'])
