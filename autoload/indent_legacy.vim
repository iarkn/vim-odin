" Vim indent file
" Language: Odin
" Maintainer: iarkn
" Website: https://github.com/iarkn/vim-odin
" Last Change: 2025-06-29

if exists('b:did_indent')
    finish
endif

let b:did_indent = 1

let b:undo_indent = 'setlocal autoindent< indentkeys< indentexpr<'

setlocal autoindent
setlocal indentkeys=0{,0},0),0],:,!^F,o,O,e
setlocal indentexpr=GetOdinIndent(v:lnum)

let s:matchpairs = {'}': '{', ')': '(', '\]': '\['}

function! s:IsComment(lnum, line) abort
    return a:line =~ '^\s*/[/\*]' || synIDattr(synID(a:lnum, 1, 0), 'name') =~? 'Comment'
endfunction

function! s:GetPrevLnum(lnum) abort
    let l:plnum = a:lnum - 1
    let l:pline = ''
    while l:plnum > 1
        let l:plnum = prevnonblank(l:plnum)
        let l:pline = getline(l:plnum)
        if s:IsComment(l:plnum, l:pline)
            let l:plnum -= 1
        elseif l:pline =~ '\*/\s*$'
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
        else
            break
        endif
    endwhile
    return l:plnum
endfunction

function! s:TrimComment(lnum, line) abort
    if s:IsComment(a:lnum, a:line)
        return ""
    endif
    let l:len = strcharlen(a:line)
    let l:min = 1
    let l:max = l:len
    let l:idx = l:max
    while 1
        if synIDattr(synID(a:lnum, l:idx, 0), 'name') !~? 'Comment'
            if l:idx == l:len
                " This line does not end with a comment.
                break
            endif
            let l:min = l:idx
            let l:idx += (l:max - l:idx) / 2
        else
            if l:idx == 0 || synIDattr(synID(a:lnum, l:idx - 1, 0), 'name') !~? 'Comment'
                return strcharpart(a:line, 0, l:idx - 1)
            endif
            let l:max = l:idx
            let l:idx -= (l:idx - l:min) / 2
        endif
    endwhile
    return a:line
endfunction

function! s:GetLine(lnum) abort
    return s:TrimComment(a:lnum, getline(a:lnum))
endfunction

function! s:FindMatchIndent(lnum, pindent, pattern, range = 20) abort
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
    if l:line =~ '^\s*/\*' || synIDattr(synID(a:lnum, 1, 0), 'name') =~# 'odinBlockComment'
        " Block comments are not modified.
        return l:indent
    endif

    let l:line = s:TrimComment(a:lnum, l:line)
    if l:line == ""
        return l:indent
    endif

    let l:plnum = s:GetPrevLnum(a:lnum)
    let l:pline = s:GetLine(l:plnum)
    let l:pindent = indent(l:plnum)
    let l:indent = l:pindent

    if l:line =~ '^\s*[})\]]'
        let l:col = strcharlen(matchstr(l:line, '^\s*[})\]]'))
        let l:pend = l:line[l:col - 1]
        let l:pstart = s:matchpairs[l:pend]

        let l:skip = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "String\\|Comment"'
        let l:mlnum = searchpairpos(l:pstart, '', l:pend, 'bnW', skip)[0]
        let l:mline = s:GetLine(l:mlnum)
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
    elseif l:pline =~# '^\s*case.*,\s*$'
        " Align continuation line for case label.
        return strdisplaywidth(matchstr(l:pline, '^\s*case\s*'))
    elseif l:pline =~ '\S\s*:\s*$'
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
