vim9script

# Vim indent file
# Language: Odin
# Maintainer: iarkn
# Website: https://github.com/iarkn/vim-odin
# Last Change: 2025-07-01

if exists('b:did_indent')
    finish
endif

b:did_indent = 1

setlocal autoindent
setlocal indentkeys=0{,0},0),0],:,!^F,o,O,e
setlocal indentexpr=GetOdinIndent(v:lnum)

b:undo_indent = 'setlocal autoindent< indentkeys< indentexpr<'

var matchpairs = {'}': '{', ')': '(', '\]': '\['}

def GetPrevLnum(lnum: number): number
    var plnum = lnum - 1
    var pline = ''
    while plnum > 1
        plnum = prevnonblank(plnum)
        pline = getline(plnum)
        if pline =~ '\*/\s*$'
            var comment_depth = 0
            while plnum > 1
                pline = getline(plnum)
                comment_depth -= count(pline, '/*')
                comment_depth += count(pline, '*/')
                if comment_depth == 0
                    return plnum
                endif
                plnum -= 1
            endwhile
        elseif pline =~ '^\s*/[/\*]' # || synIDattr(synID(plnum, 1, 0), 'name') =~? 'Comment'
            plnum -= 1
        else
            break
        endif
    endwhile
    return plnum
enddef

def TrimComment(lnum: number, line: string, check_block = true): string
    var comment_pattern = '^\s*//'
    if check_block
        comment_pattern = '^\s*//\|^\s*/\*'
    endif

    var comment_match = matchstr(line, comment_pattern)
    if comment_match != ''
        var comment_match_off = strlen(comment_match) - 3
        if comment_match_off <= 0
            return ''
        endif
        return line[: comment_match_off]
    endif

    var len = strlen(line)
    if synIDattr(synID(lnum, len, 0), 'name') !~? 'Comment'
        # Skip lines not ending with a comment.
        return line
    endif

    if check_block
        if synIDattr(synID(lnum, 1, 0), 'name') ==# 'odinBlockComment'
            return ''
        endif
    endif

    var idx = len - 1
    while idx >= 0
        if idx - 1 >= 0 && line[idx - 1] == '/' && (line[idx] == '/' || line[idx] == '*')
            if synIDattr(synID(lnum, idx - 1, 0), 'name') !~? 'Comment'
                return line[: idx - 2]
            endif
        endif
        idx -= 1
    endwhile
    return line
enddef

def GetLine(lnum: number, check_block = true): string
    return TrimComment(lnum, getline(lnum), check_block)
enddef

def FindMatchIndent(lnum: number, pindent: number, pattern: string, range: number = 10): number
    for mlnum in range(lnum, lnum - range, -1)
        if mlnum < 1
            break
        endif
        var mindent = indent(mlnum)
        if GetLine(mlnum) =~# pattern
            return mindent
        elseif mindent != pindent
            break
        endif
    endfor
    return -1
enddef

def GetOdinIndent(lnum: number): number
    var line = getline(lnum)
    var indent = indent(lnum)
    if line =~ '^\s*/\*\|^\s*\*/' || synIDattr(synID(lnum, 1, 0), 'name') =~# 'odinBlockComment'
        # Block comments are not modified.
        return indent
    endif

    line = TrimComment(lnum, line, false)

    var plnum = GetPrevLnum(lnum)
    var pline = GetLine(plnum)
    var pindent = indent(plnum)
    indent = pindent

    if line =~ '^\s*[})\]]'
        call cursor(lnum, 1)

        var col = strlen(matchstr(line, '^\s*[})\]]'))
        var pend = line[col - 1]
        var pstart = matchpairs[pend]

        var skip = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "String\\|Comment"'
        var mlnum = searchpairpos(pstart, '', pend, 'bnW', skip)[0]
        var mline = GetLine(mlnum, false)
        var mindent = indent(mlnum)

        # Align closing bracket with where clause.
        if mline =~# '^\s*where\>.*{\s*$'
            return mindent - shiftwidth()
        elseif line =~ '^\s*}\s*$'
            var nindent = FindMatchIndent(mlnum - 1, mindent, '^\s*where\>.*\(,\|||\|&&\)\s*$')
            if nindent >= 0
                return nindent - shiftwidth()
            endif
        endif

        # Align closing block.
        return mindent
    endif

    if pline =~ '[{(\[]\s*$'
        # Indent after opening block.
        indent += shiftwidth()
    endif

    if line =~# '^\s*case\>.*[,:]'
        if pline !~# '^\s*case\>.*[,:]'
            # Deindent case label (align to switch statement).
            return indent - shiftwidth()
        endif
    elseif pline =~# '^\s*case\>.*:\s*$'
        # Indent after case label.
        return indent + shiftwidth()
    elseif pline =~# '^\s*case\>.*,\s*$'
        # Align continuation line for case label.
        return strdisplaywidth(matchstr(pline, '^\s*case\s*'))
    elseif pline =~ '\S\s*:\s*$'
        # Indent after end of multi-line case label.
        var mindent = FindMatchIndent(plnum - 1, pindent, '^\s*case\>.*,\s*$')
        if mindent >= 0
            return mindent + shiftwidth()
        endif
    elseif line =~# '^\s*where\>'
        # Indent where clause.
        return indent + shiftwidth()
    elseif pline =~# '^\s*where\>.*\(,\|||\|&&\)\s*$'
        # Align continuation line for where clause.
        return strdisplaywidth(matchstr(pline, '^\s*where\s*'))
    elseif pline =~ '\S\s*{\s*$'
        if pline =~ '^\s*where\>'
            # Deindent after where clause.
            return indent - shiftwidth()
        else
            # Deindent after end of multi-line where clause.
            var mindent = FindMatchIndent(plnum - 1, pindent, '^\s*where\>.*\(,\|||\|&&\)\s*$')
            if mindent >= 0
                return mindent
            endif
        endif
    endif

    return indent
enddef
