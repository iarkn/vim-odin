" Vim compiler file
" Compiler: Odin Compiler (odin build)

if exists('current_compiler')
    finish
endif

runtime compiler/odin.vim

let current_compiler = 'odin_build'

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif

if exists('g:odin_build_makeprg_params')
    exec 'CompilerSet makeprg=odin\ build\ .\ ' . escape(g:odin_build_makeprg_params, ' \|') . '\ $*'
else
    CompilerSet makeprg=odin\ build\ . $*
endif
