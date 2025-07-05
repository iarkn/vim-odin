" Vim indent file
" Language: Odin
" Maintainer: iarkn
" Website: https://github.com/iarkn/vim-odin
" Last Change: 2025-07-01

if exists('b:did_indent')
    finish
endif

let b:did_indent = 1

setlocal autoindent
setlocal indentkeys=0{,0},0),0],:,!^F,o,O,e
setlocal indentexpr=GetOdinIndent(v:lnum)

let b:undo_indent = 'setlocal autoindent< indentkeys< indentexpr<'

let s:matchpairs = {'}': '{', ')': '(', '\]': '\['}

function! s:GetPrevLnum(lnum) abort
    let l:plnum = a:lnum - 1
    let l:pline = ''
    while l:plnum > 1
        let l:plnum = prevnonblank(l:plnum)
        let l:pline = getline(l:plnum)
        if l:pline =~ '\*/\s*$'
            let l:comment_depth = 0
            while l:plnum > 1
                let l:pline = getline(l:plnum)
                let l:comment_depth -= count(l:pline, '/*')
                let l:comment_depth += count(l:pline, '*/')
                if l:comment_depth == 0
                    return l:plnum
                endif
                let l:plnum -= 1
            endwhile
        elseif l:pline =~ '^\s*/[/\*]' " || synIDattr(synID(l:plnum, 1, 0), 'name') =~? 'Comment'
            let l:plnum -= 1
        else
            break
        endif
    endwhile
    return l:plnum
endfunction

function! s:TrimComment(lnum, line, check_block = 1) abort
    let l:comment_pattern = '^\s*//'
    if a:check_block == 1
        let l:comment_pattern = '^\s*//\|^\s*/\*'
    endif

    let l:comment_match = matchstr(a:line, l:comment_pattern)
    if l:comment_match != ''
        let l:comment_match_off = strlen(l:comment_match) - 3
        if l:comment_match_off <= 0
            return ''
        endif
        return a:line[: l:comment_match_off]
    endif

    let l:len = strlen(a:line)
    if synIDattr(synID(a:lnum, l:len, 0), 'name') !~? 'Comment'
        " Skip lines not ending with a comment.
        return a:line
    endif

    if a:check_block == 1
        if synIDattr(synID(a:lnum, 1, 0), 'name') ==# 'odinBlockComment'
            return ''
        endif
    endif

    let l:idx = l:len - 1
    while l:idx >= 0
        if l:idx - 1 >= 0 && a:line[l:idx - 1] == '/' && (a:line[l:idx] == '/' || a:line[l:idx] == '*')
            if synIDattr(synID(a:lnum, l:idx - 1, 0), 'name') !~? 'Comment'
                return a:line[: l:idx - 2]
            endif
        endif
        let l:idx -= 1
    endwhile
    return a:line
endfunction

function! s:GetLine(lnum, check_block = 1) abort
    return s:TrimComment(a:lnum, getline(a:lnum), a:check_block)
endfunction

function! s:FindMatchIndent(lnum, pindent, pattern, range = 10) abort
    for mlnum in range(a:lnum, a:lnum - a:range, -1)
        if mlnum < 1
            break
        endif
        let l:mindent = indent(mlnum)
        if s:GetLine(mlnum) =~# a:pattern
            return l:mindent
        elseif l:mindent != a:pindent
            break
        endif
    endfor
    return -1
endfunction

function! GetOdinIndent(lnum) abort
    let l:line = getline(a:lnum)
    let l:indent = indent(a:lnum)
    if l:line =~ '^\s*/\*\|^\s*\*/' || synIDattr(synID(a:lnum, 1, 0), 'name') =~# 'odinBlockComment'
        " Block comments are not modified.
        return l:indent
    endif

    let l:line = s:TrimComment(a:lnum, l:line, 0)

    let l:plnum = s:GetPrevLnum(a:lnum)
    let l:pline = s:GetLine(l:plnum)
    let l:pindent = indent(l:plnum)
    let l:indent = l:pindent

    if l:line =~ '^\s*[})\]]'
        call cursor(a:lnum, 1)

        let l:col = strlen(matchstr(l:line, '^\s*[})\]]'))
        let l:pend = l:line[l:col - 1]
        let l:pstart = s:matchpairs[l:pend]

        let l:skip = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "String\\|Comment"'
        let l:mlnum = searchpairpos(l:pstart, '', l:pend, 'bnW', skip)[0]
        let l:mline = s:GetLine(l:mlnum, 0)
        let l:mindent = indent(l:mlnum)

        " Align closing bracket with where clause.
        if l:mline =~# '^\s*where\>.*{\s*$'
            return l:mindent - shiftwidth()
        elseif l:line =~ '^\s*}\s*$'
            let l:nindent = s:FindMatchIndent(l:mlnum - 1, l:mindent, '^\s*where\>.*\(,\|||\|&&\)\s*$')
            if l:nindent >= 0
                return l:nindent - shiftwidth()
            endif
        endif

        " Align closing block.
        return l:mindent
    endif

    if l:pline =~ '[{(\[]\s*$'
        " Indent after opening block.
        let l:indent += shiftwidth()
    endif

    if l:line =~# '^\s*case\>.*[,:]'
        if l:pline !~# '^\s*case\>.*[,:]'
            " Deindent case label (align to switch statement).
            return l:indent - shiftwidth()
        endif
    elseif l:pline =~# '^\s*case\>.*:\s*$'
        " Indent after case label.
        return l:indent + shiftwidth()
    elseif l:pline =~# '^\s*case\>.*,\s*$'
        " Align continuation line for case label.
        return strdisplaywidth(matchstr(l:pline, '^\s*case\s*'))
    elseif l:pline =~ '\S\s*:\s*$'
        " Indent after end of multi-line case label.
        let l:mindent = s:FindMatchIndent(l:plnum - 1, l:pindent, '^\s*case\>.*,\s*$')
        if l:mindent >= 0
            return l:mindent + shiftwidth()
        endif
    elseif l:line =~# '^\s*where\>'
        " Indent where clause.
        return l:indent + shiftwidth()
    elseif l:pline =~# '^\s*where\>.*\(,\|||\|&&\)\s*$'
        " Align continuation line for where clause.
        return strdisplaywidth(matchstr(l:pline, '^\s*where\s*'))
    elseif l:pline =~ '\S\s*{\s*$'
        if l:pline =~ '^\s*where\>'
            " Deindent after where clause.
            return l:indent - shiftwidth()
        else
            " Deindent after end of multi-line where clause.
            let l:mindent = s:FindMatchIndent(l:plnum - 1, l:pindent, '^\s*where\>.*\(,\|||\|&&\)\s*$')
            if l:mindent >= 0
                return l:mindent
            endif
        endif
    endif

    return l:indent
endfunction
