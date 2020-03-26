" Maintainer: Maxim Kim (habamax@gmail.com)
" vim: et sw=4

if exists("g:loaded_asciidoctor_autoload")
    finish
endif
let g:loaded_asciidoctor_autoload = 1


"" Trim string
" Unfortunately built-in trim is not widely available yet
" return trimmed string
func! s:trim(str) abort
    return substitute(a:str, '^\s*\|\s*$', '', 'g')
endfunc

"" Return name of an image directory.
"
" It is either 
" * '' (empty)
" * or value of :imagesdir: (stated at the top of the buffer, first 50 lines)
func! s:asciidoctorImagesDir()
    let imagesdirs = filter(getline(1, 50), {k,v -> v =~ '^:imagesdir:.*'})
    if len(imagesdirs)>0
        return matchstr(imagesdirs[0], ':imagesdir:\s*\zs\f\+\ze$').'/'
    else
        return ''
    endif
endfunc

"" Return full path of an image
"
" It is 'current buffer path'/:imagesdir:
func! s:asciidoctorImagesPath()
    return expand('%:p:h').'/'.s:asciidoctorImagesDir()
endfunc

"" Return list of generated images for the current buffer.
"
" If buffer name is `document.adoc`, search in a given path for the file
" pattern `g:asciidoctor_img_paste_pattern`.
"
" Example:
" `img_document_1.png`
" `img_document_2.png`
func! s:asciidoctorListImages(path)
    let rxpattern = '\V\[\\/]'.printf(g:asciidoctor_img_paste_pattern, expand('%:t:r'), '\d\+').'\$'
    let images = globpath(a:path, '*.png', 1, 1)
    return filter(images, {k,v -> v =~ rxpattern})
endfunc

"" Return index of the image file name
"
" `img_document_23.png` --> 23
" `img_document.png` --> 0 
" `any other` --> 0 
func! s:asciidoctorExtractIndex(filename)
    let rxpattern = '\V\[\\/]'.printf(g:asciidoctor_img_paste_pattern, expand('%:t:r'), '\zs\d\+\ze').'\$'
    let index = matchstr(a:filename, rxpattern)
    if index == ''
        let index = '0'
    endif
    return str2nr(index)
endfunc

"" Return new image name
"
" Having the list of images in a give path:
" `img_document_1.png`
" `img_document_2.png`
" ...
" Generate a new image name:
" `img_document_3.png
func! s:asciidoctorGenerateImageName(path)
    let index = max(map(s:asciidoctorListImages(a:path), 
                \{k,v -> s:asciidoctorExtractIndex(v)})) + 1
    return printf(g:asciidoctor_img_paste_pattern, expand('%:t:r'), index)
    
endfunc

"" Paste image from the clipboard.
"
" * Save image as png file to the :imagesdir:
" * Insert `image::link.png[]` at cursor position
func! asciidoctor#pasteImage() abort
    let path = s:asciidoctorImagesPath()
    if !isdirectory(path)
        echoerr 'Image directory '.path.' doesn''t exist!'
        return
    endif

    let fname = s:asciidoctorGenerateImageName(path)

    let cmd = printf(g:asciidoctor_img_paste_command, path, fname)

    let res = system(cmd)
    if v:shell_error
        echohl Error | echomsg s:trim(res) | echohl None
        return
    endif

    let sav_reg_x = @x
    let @x = printf('image::%s[]', fname)
    put x
    let @x = sav_reg_x
endfunc


"" Check header (20 lines) of the file for default source language
func! asciidoctor#detect_source_language()
    for line in getline(1, 20)
        let m = matchlist(line, '^:source-language: \(.*\)$')
        if !empty(m)
            let src_lang = s:trim(m[1])
            if src_lang != ''
                let b:asciidoctor_source_language = s:trim(m[1])
                break
            endif
        endif
    endfor
endfunc

"" Refresh highlighting for default source language.
"
" Should be called on buffer write.
func! asciidoctor#refresh_source_language_hl()
    let cur_b_source_language = get(b:, "asciidoctor_source_language", "NONE")

    call asciidoctor#detect_source_language()

    if cur_b_source_language != get(b:, "asciidoctor_source_language", "NONE")
        syn enable
    endif
endfunc

"" Test bibliography completefunc
func! asciidoctor#complete_bibliography(findstart, base)
    if a:findstart
        let prefix = strpart(getline('.'), 0, col('.')-1)
        let m = match(prefix, 'cite\%(np\)\?:\[\zs[[:alnum:]]*$')
        if m != -1
            return m
        else
            return -3
        endif
    else
        " return filtered list of
        " [{"word": "citation1", "menu": "article"}, {"word": "citation2", "menu": "book"}, ...]
        " if "word" matches with a:base
        return filter(
                    \ map(s:read_all_bibtex(), {_, val -> {'word': matchstr(val, '{\zs.\{-}\ze,'), 'menu': matchstr(val, '@\zs.\{-}\ze{')}}),
                    \ {_, val -> val['word'] =~ '^'.a:base.'.*'})
    endif
endfunc

"" Read bibtex file
"
" Return list of citations
func! s:read_bibtex(file)
    let citation_types = '@book\|@article\|@booklet\|@conference\|@inbook'
                \.'\|@incollection\|@inproceedings\|@manual\|@mastersthesis'
                \.'\|@misc\|@phdthesis\|@proceedings\|@techreport\|@unpublished'
    let citations = filter(readfile(a:file), {_, val -> val =~ citation_types})

    return citations
endfunc

"" Read all bibtex files from a current file's path
"
" Return list of citations
func! s:read_all_bibtex()
    let citations = []
    for bibfile in globpath(expand('%:p:h'), '*.bib', 0, 1)
        call extend(citations, s:read_bibtex(bibfile))
    endfor
    return citations
endfunc



"" Check header (30 lines) of the file for theme name
" return theme name
func! asciidoctor#detect_pdf_theme()
    let result = ''
    for line in getline(1, 30)
        let m = matchlist(line, '^:pdf-style: \(.*\)$')
        if !empty(m)
            let  result = s:trim(m[1])
            if result != ''
                return result
            endif
        endif
    endfor
endfunc


"" Force default colors
" Colorschemes can redefine and link asciidoctor highlight groups
" And as a consequense if you run another colorscheme that didn't redefine
" anything you end up having non-default colors.
" Call it when there is a need to do it.
func! asciidoctor#force_default_colors() abort
    hi link asciidoctorTitle                 Title
    hi link asciidoctorSetextHeader          Title
    hi link asciidoctorH1                    Title
    hi link asciidoctorH2                    Title
    hi link asciidoctorH3                    Title
    hi link asciidoctorH4                    Title
    hi link asciidoctorH5                    Title
    hi link asciidoctorH6                    Title
    hi link asciidoctorListMarker            Delimiter
    hi link asciidoctorOrderedListMarker     asciidoctorListMarker
    hi link asciidoctorListContinuation      Delimiter
    hi link asciidoctorComment               Comment
    hi link asciidoctorIndented              Comment
    hi link asciidoctorPlus                  Delimiter
    hi link asciidoctorPageBreak             Delimiter
    hi link asciidoctorCallout               Delimiter
    hi link asciidoctorCalloutDesc           Delimiter

    hi link asciidoctorListingBlock          Comment
    hi link asciidoctorLiteralBlock          Comment

    hi link asciidoctorFile                  Underlined
    hi link asciidoctorUrl                   Underlined
    hi link asciidoctorEmail                 Underlined
    hi link asciidoctorUrlAuto               Underlined
    hi link asciidoctorEmailAuto             Underlined
    hi link asciidoctorUrlDescription        Constant

    hi link asciidoctorLink                  Underlined
    hi link asciidoctorAnchor                Underlined
    hi link asciidoctorAttribute             Identifier
    hi link asciidoctorCode                  Constant
    hi link asciidoctorOption                Identifier
    hi link asciidoctorBlock                 Delimiter
    hi link asciidoctorBlockOptions          Delimiter
    hi link asciidoctorTableSep              Delimiter
    hi link asciidoctorTableCell             Delimiter
    hi link asciidoctorTableEmbed            Delimiter
    hi link asciidoctorInlineAnchor          Delimiter

    hi link asciidoctorDefList               asciidoctorBold
    hi link asciidoctorCaption               Statement
    hi link asciidoctorAdmonition            asciidoctorBold
endfunc
