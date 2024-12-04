" Vim syntax file
" Language:     asciidoc
" Maintainer:   David P. Federl <david-peter.federl@federl.digital>
" Filenames:    *.adoc
" vim: et sw=4

if exists("b:current_syntax")
    finish
endif

syntax spell toplevel

if !exists('main_syntax')
    let main_syntax = 'asciidoc'
endif

if !exists('g:asciidoc_fenced_languages')
    let g:asciidoc_fenced_languages = []
endif
for s:type in g:asciidoc_fenced_languages + [get(b:, "asciidoc_source_language", "NONE")]
    if s:type ==# "NONE"
        continue
    endif
    exe 'syn include @asciidocSourceHighlight'.s:type.' syntax/'.s:type.'.vim'
    unlet! b:current_syntax
endfor
unlet! s:type

if globpath(&rtp, "syntax/plantuml.vim") != ''
    syn include @asciidocPlantumlHighlight syntax/plantuml.vim
    unlet! b:current_syntax
endif

" Check :h syn-sync-fourth
syn sync maxlines=100

syn case ignore

syn match asciidocOption "^:[[:alnum:]!-]\{-}:"
syn match asciidocListContinuation "^+\s*$"
syn match asciidocPageBreak "^<<<\+\s*$"

syn cluster asciidocBlock contains=asciidocTitle,asciidocH1,asciidocH2,asciidocH3,asciidocH4,asciidocH5,asciidocH6,asciidocSetextHeader,asciidocSetextHeaderDelimiter,asciidocBlockquote,asciidocListMarker,asciidocOrderedListMarker,asciidocCodeBlock,asciidocAdmonition,asciidocAdmonitionBlock
syn cluster asciidocInnerBlock contains=asciidocBlockquote,asciidocListMarker,asciidocOrderedListMarker,asciidocCodeBlock,asciidocDefList,asciidocAdmonition,asciidocAdmonitionBlock
syn cluster asciidocInline contains=asciidocItalic,asciidocBold,asciidocCode,asciidocBoldItalic,asciidocUrl,asciidocUrlAuto,asciidocLink,asciidocAnchor,asciidocMacro,asciidocAttribute,asciidocInlineAnchor
syn cluster asciidocUrls contains=asciidocUrlDescription,asciidocFile,asciidocUrlAuto,asciidocEmailAuto

syn region asciidocTitle matchgroup=asciidocTitleDelimiter start="^=\s" end="$" oneline keepend contains=@asciidocInline,@Spell
syn region asciidocH1 matchgroup=asciidocH1Delimiter start="^==\s" end="$" oneline keepend contains=@asciidocInline,@Spell
syn region asciidocH2 matchgroup=asciidocH2Delimiter start="^===\s" end="$" oneline keepend contains=@asciidocInline,@Spell
syn region asciidocH3 matchgroup=asciidocH3Delimiter start="^====\s" end="$" oneline keepend contains=@asciidocInline,@Spell
syn region asciidocH4 matchgroup=asciidocH4Delimiter start="^=====\s" end="$" oneline keepend contains=@asciidocInline,@Spell
syn region asciidocH5 matchgroup=asciidocH5Delimiter start="^======\s" end="$" oneline keepend contains=@asciidocInline,@Spell
syn region asciidocH6 matchgroup=asciidocH6Delimiter start="^=======\s" end="$" oneline keepend contains=@asciidocInline,@Spell

syn match asciidocSetextHeader '^\%(\n\|\%^\)\k.*\n\%(==\+\|\-\-\+\|\~\~\+\|\^\^\+\|++\+\)$' contains=@Spell,asciidocSetextHeaderDelimiter
syn match asciidocSetextHeaderDelimiter "^==\+\|\-\-\+\|\~\~\+\|\^\^\+\|++\+$" contained containedin=asciidocSetextHeader

syn sync clear
syn sync match syncH1 grouphere NONE "^==\s.*$"
syn sync match syncH2 grouphere NONE "^===\s.*$"
syn sync match syncH3 grouphere NONE "^====\s.*$"
syn sync match syncH4 grouphere NONE "^=====\s.*$"
syn sync match syncH5 grouphere NONE "^======\s.*$"
syn sync match syncH6 grouphere NONE "^=======\s.*$"

syn match asciidocAttribute "{[[:alpha:]][[:alnum:]-_:]\{-}}"

" a Macro is a generic pattern that has no default highlight, but it could contain a link/image/url/xref/mailto/etc, and naked URLs as well

syn match asciidocMacro "\<\l\{-1,}://\S\+" contains=asciidocUrlAuto,asciidocCode
syn match asciidocMacro "\<\w\S\{-}@\w\+\.\w\+" contains=asciidocEmailAuto,asciidocCode
syn match asciidocMacro "\<\l\{-1,}::\?\S*\[.\{-}\]" keepend contains=asciidocUrl,asciidocLink,asciidocEmail,asciidocCode

syn match asciidocFile "\f\+" contained
syn match asciidocUrlDescription "\[[^]]\{-}\]" contained containedin=asciidocLink
syn match asciidocUrlAuto "\%(file\|http\|ftp\|irc\)s\?://\S\+\%(\[.\{-}\]\)\?" contained contains=asciidocUrl
syn match asciidocEmailAuto "[a-zA-Z0-9._%+-]\{-1,}@\w\+\%(\.\w\+\)\+" contained

if get(g:, 'asciidoc_syntax_conceal', 0)
    " the pattern \[\ze\%(\s*[^ ]\+\s*\)\+]\+ means: a brackets pair, inside of which at least one non-space character, possibly with spaces
    syn region asciidocLink matchgroup=Conceal start="\%(link\|xref\|mailto\|irc\):[^:][^\[]\{-}\[\ze\%(\s*[^ \]]\+\s*\)\+\]\+" end="\]" concealends oneline keepend skipwhite contained
    syn region asciidocLink matchgroup=Conceal start="\%(link\|xref\|mailto\|irc\):\ze[^:][^\[]\{-}\[\s*\]" end="\ze\[\s*\]" concealends oneline keepend skipwhite contained nextgroup=asciidocUrlDescription contains=asciidocUrl,asciidocFile

    syn region asciidocUrl matchgroup=Conceal start="\%(file\|http\|ftp\|irc\)s\?://\S\+\[\ze\%(\s*[^ ]\+\s*\)\+]\+" end="\]" concealends oneline keepend skipwhite contained

    if get(g:, 'asciidoc_compact_media_links', 0)
        " conceal also the address of an image/video, if the description is not empty
        syn region asciidocLink matchgroup=Conceal start="\%(video\|image\)::\ze.*" end="\ze\[\s*\]" concealends oneline keepend skipwhite contained nextgroup=asciidocUrlDescription contains=asciidocUrl,asciidocFile
        syn region asciidocLink matchgroup=Conceal start="\%(video\|image\)::.*\[\ze\%(\s*[^ ]\+\s*\)\+]\+" end="\]" concealends oneline keepend skipwhite contained
    else
        syn region asciidocLink matchgroup=Conceal start="\%(video\|image\)::\?\ze.*" end="\ze\[.*\]" concealends oneline keepend skipwhite contained nextgroup=asciidocUrlDescription contains=asciidocFile
    endif

    syn region asciidocAnchor matchgroup=Conceal start="<<\%([^>]\{-},\s*\)\?\ze.\{-}>>" end=">>" concealends oneline

    syn region asciidocBold matchgroup=Conceal start=/\m\*\*/ end=/\*\*/ contains=@Spell concealends oneline
    syn region asciidocBold matchgroup=Conceal start=/\m\%(^\|[[:punct:][:space:]]\@<=\)\*\ze[^* ].\{-}\S/ end=/\*\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell concealends oneline

    syn region asciidocItalic matchgroup=Conceal start=/\m__/ end=/__/ contains=@Spell concealends oneline
    syn region asciidocItalic matchgroup=Conceal start=/\m\%(^\|[[:punct:][:space:]]\@<=\)_\ze[^_ ].\{-}\S/ end=/_\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell concealends oneline

    syn region asciidocBoldItalic matchgroup=Conceal start=/\m\*\*_/ end=/_\*\*/ contains=@Spell concealends oneline
    syn region asciidocBoldItalic matchgroup=Conceal start=/\m\%(^\|[[:punct:][:space:]]\@<=\)\*_\ze[^*_ ].\{-}\S/ end=/_\*\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell concealends oneline

    syn region asciidocCode matchgroup=Conceal start=/\m``/ end=/``/ contains=@Spell concealends oneline
    syn region asciidocCode matchgroup=Conceal start=/\m\%(^\|[[:punct:][:space:]]\@<=\)`\ze[^` ].\{-}\S/ end=/`\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell concealends oneline
else
    syn region asciidocLink start="\%(link\|xref\|mailto\):\zs[^:].\{-}\ze\[" end="\[.\{-}\]" oneline keepend skipwhite contained
    syn region asciidocLink start="\%(video\|image\)::\?\zs.\{-}\ze\[" end="\[.\{-}\]" oneline keepend skipwhite contained
    syn match asciidocUrl "\%(file\|http\|ftp\|irc\)s\?://\S\+\ze\%(\[.\{-}\]\)" nextgroup=asciidocUrlDescription

    syn match asciidocAnchor "<<.\{-}>>"

    syn match asciidocBold /\%(^\|[[:punct:][:space:]]\@<=\)\*[^* ].\{-}\S\*\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell
    " single char *b* bold
    syn match asciidocBold /\%(^\|[[:punct:][:space:]]\@<=\)\*[^* ]\*\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell
    syn match asciidocBold /\*\*\S.\{-}\*\*/ contains=@Spell

    syn match asciidocItalic /\%(^\|[[:punct:][:space:]]\@<=\)_[^_ ].\{-}\S_\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell
    " single char _b_ italic
    syn match asciidocItalic /\%(^\|[[:punct:][:space:]]\@<=\)_[^_ ]_\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell
    syn match asciidocItalic /__\S.\{-}__/ contains=@Spell

    syn match asciidocBoldItalic /\%(^\|[[:punct:][:space:]]\@<=\)\*_[^*_ ].\{-}\S_\*\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell
    " single char *_b_* bold+italic
    syn match asciidocBoldItalic /\%(^\|[[:punct:][:space:]]\@<=\)\*_[^*_ ]_\*\%([[:punct:][:space:]]\@=\|$\)/ contains=@Spell
    syn match asciidocBoldItalic /\*\*_\S.\{-}_\*\*/ contains=@Spell

    syn match asciidocCode /\%(^\|[[:punct:][:space:]]\@<=\)`[^` ].\{-}\S`\%([[:punct:][:space:]]\@=\|$\)/
    " single char `c` code
    syn match asciidocCode /\%(^\|[[:punct:][:space:]]\@<=\)`[^` ]`\%([[:punct:][:space:]]\@=\|$\)/
    syn match asciidocCode /``.\{-}``/
endif

syn match asciidocUppercase /^\ze\u\+:/ nextgroup=asciidocAdmonition
syn match asciidocAdmonition /\C^\%(NOTE:\)\|\%(TIP:\)\|\%(IMPORTANT:\)\|\%(CAUTION:\)\|\%(WARNING:\)\s/ contained

syn match asciidocListMarker "^\s*\(-\|\*\+\|\.\+\)\%(\s\+\[[Xx ]\]\+\s*\)\?\%(\s\+\S\)\@="
syn match asciidocOrderedListMarker "^\s*\%(\d\+\|\a\)\.\%(\s\+\S\)\@="
syn match asciidocDefList "^.\{-}::\%(\s\|$\)" contains=@Spell

syn match asciidocCallout "\s\+\zs<\%(\.\|\d\+\)>\ze\s*$" contained
syn match asciidocCalloutDesc "^\s*\zs<\%(\.\|\d\+\)>\ze\s\+"


syn match asciidocCaption "^\.[^.[:space:]].*$" contains=@asciidocInline,@Spell

syn match asciidocBlockOptions "^\[.\{-}\]\s*$"

if get(g:, 'asciidoc_syntax_indented', 1)
    syn match asciidocPlus '^+\n\s' contained
    syn match asciidocIndented '^+\?\n\%(\s\+\(-\|[*.]\+\|\d\+\.\|\a\.\)\s\)\@!\(\s.*\n\)\+' contains=asciidocPlus
endif

syn match asciidocInlineAnchor "\[\[.\{-}\]\]"

syn match asciidocIndexTerm "((.\{-}))"
syn match asciidocIndexTerm "(((.\{-})))"

" Open block
" --
" Should be highlighted as usual asciidoc
" Except (at least) headings
" --
syn region asciidocOpenBlock matchgroup=asciidocBlock start="^--\s*$" end="^--\s*$" contains=@asciidocInnerBlock,@asciidocInline,@Spell,asciidocComment,asciidocIndented

" Listing block
" ----
" block that will not be
" highlighted
" ----
syn region asciidocListingBlock matchgroup=asciidocBlock start="^----\+\s*$" end="^----\s*$"

" General [source] block
syn region asciidocSourceBlock matchgroup=asciidocBlock start="^\[source\%(,.*\)*\]\s*$" end="^\s*$" keepend
syn region asciidocSourceBlock matchgroup=asciidocBlock start="^\[source\%(,.*\)*\]\s*\n\z(--\+\)\s*$" end="^.*\n\zs\z1\s*$" keepend
syn region asciidocSourceBlock matchgroup=asciidocBlock start="^```\%(\w\+\)\?\s*$" end="^.*\n\?\zs```\s*$" keepend

" Source highlighting with programming languages
if main_syntax ==# 'asciidoc'

    "" if :source-language: is set up
    "" b:asciidoc_source_language should be set up in ftplugin -- reading
    "" first 20(?) rows of a file
    if get(b:, "asciidoc_source_language", "NONE") != "NONE"
        " :source-language: python
        "[source]
        " for i in ...
        "
        exe 'syn region asciidocSourceHighlightDefault'.b:asciidoc_source_language.' matchgroup=asciidocBlock start="^\[source\]\s*$" end="^\s*$" keepend contains=asciidocCallout,@asciidocSourceHighlight'.b:asciidoc_source_language

        " :source-language: python
        "[source]
        "----
        " for i in ...
        "----
        exe 'syn region asciidocSourceHighlightDefault'.b:asciidoc_source_language.' matchgroup=asciidocBlock start="^\[source\]\s*\n\z(--\+\)\s*$" end="^.*\n\zs\z1\s*$" keepend contains=asciidocCallout,@asciidocSourceHighlight'.b:asciidoc_source_language

        " :source-language: python
        "```lang
        "for i in ...
        "```
        exe 'syn region asciidocSourceHighlightDefault'.b:asciidoc_source_language.' matchgroup=asciidocBlock start="^```\s*$" end="^.*\n\?\zs```\s*$" keepend contains=asciidocCallout,@asciidocSourceHighlight'.b:asciidoc_source_language
    endif

    "" Other languages
    for s:type in g:asciidoc_fenced_languages + [get(b:, "asciidoc_source_language", "NONE")]
        if s:type ==# "NONE"
            continue
        endif
        "[source,lang]
        " for i in ...
        "
        exe 'syn region asciidocSourceHighlight'.s:type.' matchgroup=asciidocBlock start="^\[\%(source\)\?,\s*'.s:type.'\%(,.*\)*\]\s*$" end="^\s*$" keepend contains=asciidocCallout,@asciidocSourceHighlight'.s:type

        "[source,lang]
        "----
        "for i in ...
        "----
        exe 'syn region asciidocSourceHighlight'.s:type.' matchgroup=asciidocBlock start="^\[\%(source\)\?,\s*'.s:type.'\%(,.*\)*\]\s*\n\z(--\+\)\s*$" end="^.*\n\zs\z1\s*$" keepend contains=asciidocCallout,@asciidocSourceHighlight'.s:type

        "```lang
        "for i in ...
        "```
        exe 'syn region asciidocSourceHighlightDefault'.s:type.' matchgroup=asciidocBlock start="^```'.s:type.'\s*$" end="^.*\n\?\zs```\s*$" keepend contains=asciidocCallout,@asciidocSourceHighlight'.s:type


    endfor
    unlet! s:type
endif

" Contents of plantuml blocks should be highlighted with plantuml syntax...
" There is no built in plantuml syntax as far as I know.
" Tested with https://github.com/aklt/plantuml-syntax
syn region asciidocPlantumlBlock matchgroup=asciidocBlock start="^\[plantuml.\{-}\]\s*\n\z(\.\.\.\.\+\)\s*$" end="^.*\n\zs\z1\s*$" keepend contains=@asciidocPlantumlHighlight
syn region asciidocPlantumlBlock matchgroup=asciidocBlock start="^\[plantuml.\{-}\]\s*\n\z(--\+\)\s*$" end="^.*\n\zs\z1\s*$" keepend contains=@asciidocPlantumlHighlight

" Contents of literal blocks should not be highlighted
" TODO: make [literal] works with paragraph
syn region asciidocLiteralBlock matchgroup=asciidocBlock start="^\z(\.\.\.\.\+\)\s*$" end="^\z1\s*$" contains=@Spell,asciidocComment
syn region asciidocExampleBlock matchgroup=asciidocBlock start="^\z(====\+\)\s*$" end="^\z1\s*$" contains=@asciidocInnerBlock,@asciidocInline,@Spell,asciidocComment,asciidocIndented
syn region asciidocSidebarBlock matchgroup=asciidocBlock start="^\z(\*\*\*\*\+\)\s*$" end="^\z1\s*$" contains=@asciidocInnerBlock,@asciidocInline,@Spell,asciidocComment,asciidocIndented
syn region asciidocQuoteBlock   matchgroup=asciidocBlock start="^\z(____\+\)\s*$" end="^\z1\s*$" contains=@asciidocInnerBlock,@asciidocInline,@Spell,asciidocComment,asciidocIndented

syn region asciidocAdmonitionBlock matchgroup=asciidocBlock start="^\[\u\+\]\n\z(====\+\)\s*$" end="^\z1\s*$" contains=@asciidocInnerBlock,@asciidocInline,@Spell,asciidocComment,asciidocIndented

" Table blocks
syn match asciidocTableCell "\(^\|\s\)\@<=[.+*<^>aehlmdsv[:digit:]]\+|\||" contained containedin=asciidocTableBlock
syn region asciidocTableBlock matchgroup=asciidocBlock start="^|\z(===\+\)\s*$" end="^|\z1\s*$" keepend contains=asciidocTableCell,asciidocIndented,@asciidocInnerBlock,@asciidocInline,@Spell,asciidocComment
syn region asciidocTableBlock matchgroup=asciidocBlock start="^,\z(===\+\)\s*$" end="^,\z1\s*$" keepend
syn region asciidocTableBlock matchgroup=asciidocBlock start="^;\z(===\+\)\s*$" end="^;\z1\s*$" keepend

syn match asciidocComment "^//.*$" contains=@Spell
syn region asciidocComment start="^////.*$" end="^////.*$" contains=@Spell

hi def link asciidocTitle                 Title
hi def link asciidocSetextHeader          Title
hi def link asciidocH1                    Title
hi def link asciidocH2                    Title
hi def link asciidocH3                    Title
hi def link asciidocH4                    Title
hi def link asciidocH5                    Title
hi def link asciidocH6                    Title
hi def link asciidocTitleDelimiter        Type
hi def link asciidocH1Delimiter           Type
hi def link asciidocH2Delimiter           Type
hi def link asciidocH3Delimiter           Type
hi def link asciidocH4Delimiter           Type
hi def link asciidocH5Delimiter           Type
hi def link asciidocH6Delimiter           Type
hi def link asciidocSetextHeaderDelimiter Type
hi def link asciidocListMarker            Delimiter
hi def link asciidocOrderedListMarker     asciidocListMarker
hi def link asciidocListContinuation      PreProc
hi def link asciidocComment               Comment
hi def link asciidocIndented              Comment
hi def link asciidocPlus                  PreProc
hi def link asciidocPageBreak             PreProc
hi def link asciidocCallout               Float
hi def link asciidocCalloutDesc           String

hi def link asciidocListingBlock          Comment
hi def link asciidocLiteralBlock          Comment

hi def link asciidocFile                  Underlined
hi def link asciidocUrl                   Underlined
hi def link asciidocEmail                 Underlined
hi def link asciidocUrlAuto               Underlined
hi def link asciidocEmailAuto             Underlined
hi def link asciidocUrlDescription        String

hi def link asciidocLink                  Underlined
hi def link asciidocAnchor                Underlined
hi def link asciidocAttribute             Identifier
hi def link asciidocCode                  Constant
hi def link asciidocOption                PreProc
hi def link asciidocBlock                 PreProc
hi def link asciidocBlockOptions          PreProc
hi def link asciidocTableSep              PreProc
hi def link asciidocTableCell             PreProc
hi def link asciidocTableEmbed            PreProc
hi def link asciidocInlineAnchor          PreProc
hi def link asciidocMacro                 Macro
hi def link asciidocIndexTerm             Macro

hi def asciidocBold                       gui=bold cterm=bold
hi def asciidocItalic                     gui=italic cterm=italic
hi def asciidocBoldItalic                 gui=bold,italic cterm=bold,italic

hi def link asciidocDefList               asciidocBold
hi def link asciidocCaption               Statement
hi def link asciidocAdmonition            asciidocBold

let b:current_syntax = "asciidoc"
if main_syntax ==# 'asciidoc'
    unlet main_syntax
endif
