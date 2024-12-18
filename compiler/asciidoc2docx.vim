" Vim compiler file
" Compiler: Asciidoc 2 DOCX using docbook intermediate format and pandoc
" Maintainer: David P. Federl (david-peter.federl@federl.digital)
" vim: et sw=4

if exists("current_compiler")
    finish
endif
let current_compiler = "Asciidoc2DOCX"
let s:keepcpo= &cpo
set cpo&vim

if get(g:, 'asciidoc_extensions', []) == []
    let s:extensions = ""
else
    let s:extensions = "-r ".join(g:asciidoc_extensions, ' -r ')
endif

let s:asciidoc_executable = get(g:, 'asciidoc_executable', 'asciidoctor')

let s:asciidoc_pandoc_executable = get(g:, 'asciidoc_pandoc_executable', 'pandoc')

let s:asciidoc_pandoc_data_dir = get(g:, 'asciidoc_pandoc_data_dir', '')
if s:asciidoc_pandoc_data_dir != ''
    let data_dir_param = " --data-dir=" . shellescape(fnamemodify(s:asciidoc_pandoc_data_dir, ':p:h'))
else
    let data_dir_param = ''
endif

let s:asciidoc_pandoc_reference_doc = get(g:, 'asciidoc_pandoc_reference_doc', '')
if s:asciidoc_pandoc_reference_doc != ''
    let reference_doc_param = ' --reference-doc=' . s:asciidoc_pandoc_reference_doc
else
    " search for the theme name in first 30 lines of the file
    " generate reference doc name as `data-dir path + theme-reference.docx`
    " test if file exists and set the name, empty string otherwise
    let theme_name = asciidoc#detect_pdf_theme()
    let file_name = theme_name . '-reference.docx'
    let full_path = expand(s:asciidoc_pandoc_data_dir . '/' . file_name, 1)

    if glob(full_path, 1) != ''
        let reference_doc_param = ' --reference-doc=' . shellescape(full_path)
    else
        let reference_doc_param = ''
    endif

endif

let s:asciidoc_pandoc_other_params = get(g:, 'asciidoc_pandoc_other_params', '')
if s:asciidoc_pandoc_other_params != ''
    let other_params = ' ' . s:asciidoc_pandoc_other_params
else
    let other_params = ''
endif

let s:make_docbook = s:asciidoc_executable . " " . s:extensions
            \. " -a docdate=" . strftime("%Y-%m-%d")
            \. " -a doctime=" . strftime("%T")
            \. " -b docbook"
            \. " " . shellescape(expand("%:p"))

let s:make_docx = s:asciidoc_pandoc_executable
            \. other_params
            \. data_dir_param
            \. reference_doc_param
            \. " -f docbook -t docx"
            \. " -o " . shellescape(expand("%:p:r") . ".docx")
            \. " " . shellescape(expand("%:p:r") . ".xml")

let s:cd = "cd ".shellescape(expand("%:p:h"))
let &l:makeprg = s:make_docbook . " && " . s:cd ." && ". s:make_docx

let &cpo = s:keepcpo
unlet s:keepcpo
