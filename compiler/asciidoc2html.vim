" Vim compiler file
" Compiler: Asciidoc2HTML
" Maintainer: David P. Federl (david-peter.federl@federl.digital)
" vim: et sw=4

if exists("current_compiler")
  finish
endif
let current_compiler = "Asciidoc2HTML"
let s:keepcpo= &cpo
set cpo&vim

if get(g:, 'asciidoc_extensions', []) == []
    let s:extensions = ""
else
    let s:extensions = "-r ".join(g:asciidoc_extensions, ' -r ')
endif

if get(g:, 'asciidoc_css_path', '') == ''
    let s:css_path = ""
else
    let s:css_path = '-a stylesdir='.shellescape(fnamemodify(g:asciidoc_css_path, ":p:h"))
endif

if get(g:, 'asciidoc_css', '') == ''
    let s:css_name = ""
else
    let s:css_name = '-a stylesheet='.shellescape(g:asciidoc_css)
endif

let s:asciidoc_executable = get(g:, 'asciidoc_executable', 'asciidoctor')

let s:filename = shellescape(get(g:, 'asciidoc_use_fullpath', v:true) ? expand("%:p") : expand("%:t"))

let &l:makeprg = s:asciidoc_executable . " " . s:extensions
            \. " -a docdate=".strftime("%Y-%m-%d")
            \. " -a doctime=".strftime("%T") . " "
            \. s:css_path . " "
            \. s:css_name . " "
            \. s:filename

let &cpo = s:keepcpo
unlet s:keepcpo
