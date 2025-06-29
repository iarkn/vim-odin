vim9script

# Vim indent file
# Language: Odin
# Maintainer: iarkn
# Website: https://github.com/iarkn/vim-odin
# Last Change: 2025-06-29

if exists('b:did_indent')
    finish
endif

b:did_indent = 1

b:undo_indent = 'setlocal autoindent< indentkeys< indentexpr<'

setlocal autoindent
setlocal indentkeys=0{,0},0),0],:,!^F,o,O,e
setlocal indentexpr=GetOdinIndent(v:lnum)

var matchpairs = {'}': '{', ')': '(', '\]': '\['}

def IsComment(lnum: number, line: string): bool
    return line =~ '^\s*/[/\*]' || synIDattr(synID(lnum, 1, 0), 'name') =~? 'Comment'
enddef

def GetPrevLnum(lnum: number): number
    var plnum = lnum - 1
    var pline = ''
    while plnum > 1
        plnum = prevnonblank(plnum)
        pline = getline(plnum)
        if IsComment(plnum, pline)
            plnum -= 1
        elseif pline =~ '\*/\s*$'
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
        else
            break
        endif
    endwhile
    return plnum
enddef

def TrimComment(lnum: number, line: string): string
    if IsComment(lnum, line)
        return ""
    endif
    var len = strcharlen(line)
    var min = 1
    var max = len
    var idx = max
    while 1
        if synIDattr(synID(lnum, idx, 0), 'name') !~? 'Comment'
            if idx == len
                # This line does not end with a comment.
                break
            endif
            min = idx
            idx += (max - idx) / 2
        else
            if idx == 0 || synIDattr(synID(lnum, idx - 1, 0), 'name') !~? 'Comment'
                return strcharpart(line, 0, idx - 1)
            endif
            max = idx
            idx -= (idx - min) / 2
        endif
    endwhile
    return line
enddef

def GetLine(lnum: number): string
    return TrimComment(lnum, getline(lnum))
enddef

def FindMatchIndent(lnum: number, pindent: number, pattern: string, range: number = 20): number
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
    if line =~ '^\s*/\*' || synIDattr(synID(lnum, 1, 0), 'name') =~# 'odinBlockComment'
        # Block comments are not modified.
        return indent
    endif

    line = TrimComment(lnum, line)
    if line == ""
        return indent
    endif

    var plnum = GetPrevLnum(lnum)
    var pline = GetLine(plnum)
    var pindent = indent(plnum)
    indent = pindent

    if line =~ '^\s*[})\]]'
        var col = strcharlen(matchstr(line, '^\s*[})\]]'))
        var pend = line[col - 1]
        var pstart = matchpairs[pend]

        var skip = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "String\\|Comment"'
        var mlnum = searchpairpos(pstart, '', pend, 'bnW', skip)[0]
        var mline = GetLine(mlnum)
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
    elseif pline =~# '^\s*case.*,\s*$'
        # Align continuation line for case label.
        return strdisplaywidth(matchstr(pline, '^\s*case\s*'))
    elseif pline =~ '\S\s*:\s*$'
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
