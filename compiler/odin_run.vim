" Vim compiler file
" Compiler: Odin Compiler (odin run)

if exists('current_compiler')
    finish
endif

runtime compiler/odin.vim

let current_compiler = 'odin_run'

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif

if exists('g:odin_run_makeprg_params')
    exec 'CompilerSet makeprg=odin\ run\ .\ ' . escape(g:odin_run_makeprg_params, ' \|') . '\ $*'
else
    CompilerSet makeprg=odin\ run\ . $*
endif
