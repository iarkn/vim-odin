" Vim compiler file
" Compiler: Odin Compiler

if exists('current_compiler')
    finish
endif

let current_compiler = 'odin'

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=odin\ $*
CompilerSet errorformat=%f(%l:%c)\ %m
