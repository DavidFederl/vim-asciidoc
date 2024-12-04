" Vim compiler file
" Compiler: Asciidoc2PDF
" Maintainer: David P. Federl (david-peter.federl@federl.digital)
" vim: et sw=4

if exists("current_compiler")
    finish
endif
let current_compiler = "Asciidoc2PDF"
let s:keepcpo= &cpo
set cpo&vim

"" check first non-empty lines of the asciidoc buffer if theme 
"" is set up in file options
"" if not, don't provide themes and styles path to compiler to avoid errors
let s:use_pdf_paths = 0
for line in getline(1, 50)
    if line =~ "^\s*$"
        break
    endif
    if line =~ "^:pdf-theme:.*$"
        let s:use_pdf_paths = 1
        break
    endif
endfor

if get(g:, 'asciidoc_pdf_themes_path', '') == '' || !get(s:, 'use_pdf_paths', 0)
    let s:pdf_themes_path = ""
else
    let s:pdf_themes_path = '-a pdf-themesdir='.shellescape(fnamemodify(g:asciidoc_pdf_themes_path, ':p:h'))
endif

if get(g:, 'asciidoc_pdf_fonts_path', '') == '' || !get(s:, 'use_pdf_paths', 0)
    let s:pdf_fonts_path = ""
else
    let s:pdf_fonts_path = '-a pdf-fontsdir='.shellescape(fnamemodify(g:asciidoc_pdf_fonts_path, ':p:h'))
endif

if get(g:, 'asciidoc_pdf_extensions', []) == []
    let s:extensions = ""
else
    let s:extensions = "-r ".join(g:asciidoc_pdf_extensions, ' -r ')
endif

let s:asciidoc_pdf_executable = get(g:, 'asciidoc_pdf_executable', 'asciidoc-pdf')

let s:filename = shellescape(get(g:, 'asciidoc_use_fullpath', v:true) ? expand("%:p") : expand("%:t"))

let &l:makeprg = s:asciidoc_pdf_executable . " " . s:extensions
            \. " -a docdate=" . strftime("%Y-%m-%d")
            \. " -a doctime=" . strftime("%H:%M:%S") . " "
            \. s:pdf_themes_path . " "
            \. s:pdf_fonts_path . " "
            \. s:filename

let &cpo = s:keepcpo
unlet s:keepcpo
