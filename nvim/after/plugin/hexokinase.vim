if !exists('g:loaded_hexokinase')
	finish
endif

" All selected highlight options
let g:Hexokinase_highlighters = [
\   'virtual',
"\   'backgroundfull',
\   'foregroundfull'
\ ]

" The text to display when using virtual text for the highlighting.
let g:Hexokinase_virtualText = '●' " ■' " 
" Filetype specific patterns to match entry value must be comma seperated list
let g:Hexokinase_ftOptInPatterns = {
\     'css': 'full_hex,triple_hex,rgb,rgba,hsl,hsla,colour_names',
\     'html': 'full_hex,triple_hex,rgb,rgba,hsl,hsla,colour_names'
\ }

" Filetypes to ignore entry value must be comma seperated list
let g:Hexokinase_ftDisabled = ['text', 'markdown']

" Patterns to match for all filetypes & others
let g:Hexokinase_optInPatterns = 'full_hex,rgb,rgba,hsl,hsla'
" let g:Hexokinase_optOutPatterns = []

" Which autocmd-events trigger a refresh of highlighting.
let g:Hexokinase_refreshEvents = ['TextChanged', 'TextChangedI', 'BufRead']
" DEFAULT = ['TextChanged', 'InsertLeave', 'BufRead'] 
