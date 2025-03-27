" Vim indent plugin file
" Language: Odin
" Maintainer: Maxim Kim <habamax@gmail.com>
" Website: https://github.com/habamax/vim-odin
" Last Change: 2024-01-15

if exists('b:did_indent')
    finish
endif

let b:did_indent = 1

let b:undo_indent = 'setlocal cindent< cinoptions< cinkeys< indentexpr<'

setlocal cindent
setlocal cinoptions=L0,m1,(s,j1,J1,l1,+0,:0,#3
setlocal cinkeys=0{,0},0),0],!^F,:,o,O

setlocal indentexpr=GetOdinIndent(v:lnum)

function! PrevLine(lnum)
    let l:plnum = a:lnum - 1
    let l:pline = ''
    while l:plnum > 1
        let l:plnum = prevnonblank(l:plnum)
        let l:pline = getline(l:plnum)
        " XXX: take into account nested multiline /* /* */ */ comments
        if l:pline =~ '\*/\s*$'
            while getline(l:plnum) !~ '/\*' && l:plnum > 1
                let l:plnum -= 1
            endwhile
            if getline(l:plnum) =~ '^\s*/\*'
                let l:plnum -= 1
            else
                break
            endif
        elseif l:pline =~ '^\s*//'
            let l:plnum -= 1
        else
            break
        endif
    endwhile
    return l:plnum
endfunction

function! GetOdinIndent(lnum)
    let l:plnum = PrevLine(a:lnum)
    let l:pline = getline(l:plnum)
    let l:pindent = indent(l:plnum)

    " workaround of cindent "hang"
    " if the previous line looks like:
    " : #{}
    " : #whatever{whateverelse}
    " and variations where : # { } are in the string
    " cindent(a:lnum) hangs
    if l:pline =~ ':\s\+#.*{.*}'
        return l:pindent
    endif

    let l:indent = cindent(a:lnum)
    let l:line = getline(a:lnum)

    if l:line =~ '^\s*#\k\+'
        if l:pline =~ '[{:]\s*$'
            let l:indent = l:pindent + shiftwidth()
        else
            let l:indent = l:pindent
        endif
    elseif l:pline =~ 'switch\s.*{\s*$'
        let l:indent = l:pindent
    elseif l:pline =~ 'case\s*.*,\s*\(//.*\)\?$' " https://github.com/habamax/vim-odin/issues/8
        let l:indent = l:pindent + matchstr(l:pline, 'case\s*')->strcharlen()
    elseif l:line =~ '^\s*case\s\+.*,\s*$'
        let l:indent = l:pindent - shiftwidth()
    elseif l:pline =~ 'case\s*.*:\s*\(//.*\)\?$'
        if l:line !~ '^\s*}\s*$' && l:line !~ '^\s*case[[:space:]:]'
            let l:indent = l:pindent + shiftwidth()
        endif
    elseif l:pline =~ '^\s*@.*' && l:line !~ '^\s*}'
        let l:indent = l:pindent
    elseif l:pline =~ ':[:=].*}\s*$'
        let l:indent = l:pindent
    elseif l:pline =~ '^\s*}\s*$'
        if l:line !~ '^\s*}' && l:line !~ 'case\s*.*:\s*$'
            let l:indent = l:pindent
        else
            let l:indent = l:pindent - shiftwidth()
        endif
    elseif l:pline =~ '\S:\s*$'
        " looking up for a case something,
        "                       whatever,
        "                       anything:
        " ... 20 lines before
        for idx in range(l:plnum - 1, l:plnum - 21, -1)
            if l:plnum < 1
                break
            endif
            if getline(idx) =~ '^\s*case\s.*,\s*$'
                let l:indent = indent(idx) + shiftwidth()
                break
            endif
        endfor
    elseif l:pline =~ '{[^{]*}\s*$' && l:line !~ '^\s*[})]\s*$' " https://github.com/habamax/vim-odin/issues/2
        let l:indent = l:pindent
    elseif l:pline =~ '^\s*}\s*$' " https://github.com/habamax/vim-odin/issues/3
        " Find l:line with opening { and check if there is a label:
        " If there is, return l:indent of the closing }
        cursor(l:plnum, 1)
        silent normal! %

        let l:brlnum = line('.')
        let l:brline = getline('.')
        if l:plnum != l:brlnum && (l:brline =~ '^\s*\k\+:\s\+for' || l:brline =~ '^\s*\k\+\s*:=')
            let l:indent = l:pindent
        endif
    endif

    return l:indent
endfunction
