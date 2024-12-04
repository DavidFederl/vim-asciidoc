" Vim filetype plugin
" Language:   asciidoc
" Maintainer: David P. Federl <david-peter.federl@federl.digital>
" Filenames:  *.adoc
" vim: et sw=4

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

let s:undo_opts = "setl cms< com< fo< flp< inex< efm< cfu< fde< fdm<"
let s:undo_cmds = "| delcommand Asciidoc2PDF"
      \. "| delcommand Asciidoc2HTML"
      \. "| delcommand Asciidoc2DOCX"
      \. "| delcommand AsciidocOpenRAW"
      \. "| delcommand AsciidocOpenPDF"
      \. "| delcommand AsciidocOpenHTML"
      \. "| delcommand AsciidocOpenDOCX"
      \. "| delcommand AsciidocPasteImage"
let s:undo_maps = "| execute 'nunmap <buffer> ]]'"
      \. "| execute 'nunmap <buffer> [['"
      \. "| execute 'xunmap <buffer> ]]'"
      \. "| execute 'xunmap <buffer> [['"
      \. "| execute 'ounmap <buffer> ih'"
      \. "| execute 'ounmap <buffer> ah'"
      \. "| execute 'xunmap <buffer> ih'"
      \. "| execute 'xunmap <buffer> ah'"
      \. "| execute 'ounmap <buffer> il'"
      \. "| execute 'ounmap <buffer> al'"
      \. "| execute 'xunmap <buffer> il'"
      \. "| execute 'xunmap <buffer> al'"
      \. "| execute 'nunmap <buffer> gx'"
      \. "| execute 'nunmap <buffer> gf'"
      \. "| execute 'nunmap <buffer> <Plug>(AsciidocFold)'"
      \. "| execute 'nunmap <buffer> <Plug>(AsciidocSectionPromote)'"
      \. "| execute 'nunmap <buffer> <Plug>(AsciidocSectionDemote)'"
let s:undo_vars = "| unlet! b:commentary_startofline"

if exists('b:undo_ftplugin')
    let b:undo_ftplugin .= "|" . s:undo_opts . s:undo_cmds . s:undo_maps . s:undo_vars
else
    let b:undo_ftplugin = s:undo_opts . s:undo_cmds . s:undo_maps . s:undo_vars
endif


" see https://github.com/asciidoc/asciidoc-pdf/issues/1273
setlocal errorformat=asciidoc:\ ERROR:\ %f:\ line\ %l:\ %m

" gf to open include::file.ext[] and link:file.ext[] files
setlocal includeexpr=substitute(v:fname,'\\(link:\\\|include::\\)\\(.\\{-}\\)\\[.*','\\2','g')
setlocal comments=
setlocal commentstring=//\ %s
" vim-commentary plugin setup
let b:commentary_startofline = 1

setlocal formatoptions+=cqn
setlocal formatlistpat=^\\s*
setlocal formatlistpat+=[
setlocal formatlistpat+=\\[({]\\?
setlocal formatlistpat+=\\(
setlocal formatlistpat+=[0-9]\\+
setlocal formatlistpat+=\\\|
setlocal formatlistpat+=[a-zA-Z]
setlocal formatlistpat+=\\)
setlocal formatlistpat+=[\\]:.)}
setlocal formatlistpat+=]
setlocal formatlistpat+=\\s\\+
setlocal formatlistpat+=\\\|
setlocal formatlistpat+=^\\s*-\\s\\+
setlocal formatlistpat+=\\\|
setlocal formatlistpat+=^\\s*[*]\\+\\s\\+
setlocal formatlistpat+=\\\|
setlocal formatlistpat+=^\\s*[.]\\+\\s\\+

setlocal completefunc=asciidoc#complete_bibliography


"""
""" Commands
"""
" Use vim-dispatch if available
if exists(':Make') == 2
    let s:make = ':Make'
else
    let s:make = ':make'
endif

exe 'command! -buffer Asciidoc2PDF :compiler asciidoc2pdf | '   . s:make
exe 'command! -buffer Asciidoc2HTML :compiler asciidoc2html | ' . s:make
exe 'command! -buffer Asciidoc2DOCX :compiler asciidoc2docx | ' . s:make

command! -buffer AsciidocOpenRAW  call asciidoc#open_file(s:get_fname())
command! -buffer AsciidocOpenPDF  call asciidoc#open_file(s:get_fname(".pdf"))
command! -buffer AsciidocOpenHTML call asciidoc#open_file(s:get_fname(".html"))
command! -buffer AsciidocOpenDOCX call asciidoc#open_file(s:get_fname(".docx"))

command! -buffer AsciidocPasteImage :call asciidoc#pasteImage()



"""
""" Mappings
"""
nnoremap <silent><buffer> ]] :<c-u>call <sid>section(0, v:count1)<CR>
nnoremap <silent><buffer> [[ :<c-u>call <sid>section(1, v:count1)<CR>
xmap     <buffer><expr>   ]] "\<esc>".v:count1.']]m>gv'
xmap     <buffer><expr>   [[ "\<esc>".v:count1.'[[m>gv'

"" header textobject
onoremap <silent><buffer>ih :<C-u>call asciidoc#header_textobj(v:true)<CR>
onoremap <silent><buffer>ah :<C-u>call asciidoc#header_textobj(v:false)<CR>
xnoremap <silent><buffer>ih :<C-u>call asciidoc#header_textobj(v:true)<CR>
xnoremap <silent><buffer>ah :<C-u>call asciidoc#header_textobj(v:false)<CR>

"" delimited bLock textobject
onoremap <silent><buffer>il :<C-u>call asciidoc#delimited_block_textobj(v:true)<CR>
onoremap <silent><buffer>al :<C-u>call asciidoc#delimited_block_textobj(v:false)<CR>
xnoremap <silent><buffer>il :<C-u>call asciidoc#delimited_block_textobj(v:true)<CR>
xnoremap <silent><buffer>al :<C-u>call asciidoc#delimited_block_textobj(v:false)<CR>

nnoremap <silent><buffer> gx :<c-u>call asciidoc#open_url()<CR>
nnoremap <silent><buffer> gf :<c-u>call asciidoc#open_url("edit")<CR>

"" Useful with
""  let g:asciidoc_folding = 1
""  let g:asciidoc_foldnested = 0
""  let g:asciidoc_foldtitle_as_h1 = 1
"" Fold up to count foldlevel in a special way:
""     * no count is provided, toggle current fold;
""     * count is n, open folds of up to foldlevel n.
func! s:asciidoc_fold(count) abort
    if !get(g:, 'asciidoc_folding', 0)
        return
    endif
    if a:count == 0
        normal! za
    else
        let &foldlevel = a:count
    endif
endfunc

"" fold up to v:count foldlevel in a special way
nnoremap <silent><buffer> <Plug>(AsciidocFold) :<C-u>call <sid>asciidoc_fold(v:count)<CR>

"" promote/demote sections
nnoremap <silent><buffer> <Plug>(AsciidocSectionPromote) :<C-u>call asciidoc#promote_section()<CR>
nnoremap <silent><buffer> <Plug>(AsciidocSectionDemote) :<C-u>call asciidoc#demote_section()<CR>



"""
""" Global options processing
"""
if get(g:, 'asciidoc_opener', '') == ''
    if has("win32") || has("win32unix")
        if has("nvim")
            let g:asciidoc_opener = ':silent !start ""'
        else
            let g:asciidoc_opener = ':silent !start'
        endif
    elseif has("osx")
        let g:asciidoc_opener = ":!open"
    elseif exists("$WSLENV")
        let g:asciidoc_opener = ":silent !cmd.exe /C start"
    else
        let g:asciidoc_opener = ":!xdg-open"
    endif
endif


if has("folding") && get(g:, 'asciidoc_folding', 0)
    function! AsciidocFold() "{{{
        let line = getline(v:lnum)

        if (v:lnum == 1) && (line =~ '^----*$')
           return ">1"
        endif

        let nested = get(g:, "asciidoc_foldnested", v:true)

        " Regular headers
        let depth = match(line, '\(^=\+\)\@<=\( .*$\)\@=')

        " Do not fold nested regular headers
        if depth > 1 && !nested
            let depth = 1
        endif

        " Setext style headings
        if depth < 0
            let prevline = getline(v:lnum - 1)
            let nextline = getline(v:lnum + 1)

            if (line =~ '^.\+$') && (nextline =~ '^=\+$') && (prevline =~ '^\s*$')
                let depth = nested ? 2 : 1
            endif

            if (line =~ '^.\+$') && (nextline =~ '^-\+$') && (prevline =~ '^\s*$')
                let depth = nested ? 3 : 1
            endif

            if (line =~ '^.\+$') && (nextline =~ '^\~\+$') && (prevline =~ '^\s*$')
                let depth = nested ? 4 : 1
            endif

            if (line =~ '^.\+$') && (nextline =~ '^^\+$') && (prevline =~ '^\s*$')
                let depth = nested ? 5 : 1
            endif

            if (line =~ '^.\+$') && (nextline =~ '^+\+$') && (prevline =~ '^\s*$')
                let depth = nested ? 5 : 1
            endif
        endif


        if depth > 0
            " fold all sections under title
            if depth > 1 && get(g:, "asciidoc_foldtitle_as_h1", v:true)
                let depth -= 1
            endif
            " check syntax, it should be asciidocTitle or asciidocH
            let syncode = synstack(v:lnum, 1)
            if len(syncode) > 0 && synIDattr(syncode[0], 'name') =~ 'asciidoc\%(H[1-6]\)\|Title\|SetextHeader'
                return ">" . depth
            endif
        endif

        " Fold options
        if s:asciidoc_fold_options
            let opt_regex = '^:[[:alnum:]-!]\{-}:.*$'
            if (line =~ opt_regex)
                let prevline = getline(v:lnum - 1)
                let nextline = getline(v:lnum + 1)
                if (prevline !~ opt_regex) && (nextline =~ opt_regex)
                    return "a1"
                endif
                if (nextline !~ opt_regex) && (prevline =~ opt_regex)
                    return "s1"
                endif
            endif
        endif

        return "="
    endfunction "}}}

    setlocal foldexpr=AsciidocFold()
    setlocal foldmethod=expr
    let s:asciidoc_fold_options = get(g:, 'asciidoc_fold_options', 0)
endif


if get(g:, 'asciidoc_img_paste_command', '') == ''
    " first `%s` is a path
    " second `%s` is an image file name
    if has('win32')
        let g:asciidoc_img_paste_command = 'gm convert clipboard: %s%s'
    elseif has('osx')
        let g:asciidoc_img_paste_command = 'pngpaste %s%s'
    else " there is probably a better tool for linux?
        let g:asciidoc_img_paste_command = 'gm convert clipboard: %s%s'
    endif
endif


if get(g:, 'asciidoc_img_paste_pattern', '') == ''
    " first `%s` is a base document name:
    " (~/docs/hello-world.adoc => hello-world)
    " second `%s` is a number of the image.
    let g:asciidoc_img_paste_pattern = 'img_%s_%s.png'
endif



"""
""" Detect default source code language
"""
call asciidoc#detect_source_language()

augroup asciidoc_source_language
    au!
    au bufwrite *.adoc,*.asciidoc call asciidoc#refresh_source_language_hl()
augroup END



"""
""" Helper functions
"""
func! s:get_fname(...)
    let ext = get(a:, 1, '')
    if ext == ''
        return expand("%")
    else
        return expand("%:r").ext
    endif
endfunc


"" Next/Previous section mappings
func! s:section(back, cnt)
  for n in range(a:cnt)
    call search('^=\+\s\+\S\+\|\_^\%(\n\|\%^\)\@<=\k.*\n\%(==\+\|\-\-\+\|\~\~\+\|\^\^\+\|++\+\)$', a:back ? 'bW' : 'W')
  endfor
endfunc
