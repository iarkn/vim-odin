" Vim syntax file
" Language: Odin
" Maintainer: iarkn
" Website: https://github.com/iarkn/vim-odin
" Original Author: Maxim Kim <habamax@gmail.com>
" Original Website: https://github.com/habamax/vim-odin
" Last Change: 2025-06-29

if exists("b:current_syntax")
    finish
endif

function! s:HighlightBuiltinProcs() abort
  return get(g:, 'odin_highlight_builtin_procs', 1)
endfunction

function! s:HighlightBuiltinRuntimeProcs() abort
  return get(g:, 'odin_highlight_builtin_runtime_procs', 1)
endfunction

" Keywords. See <https://github.com/odin-lang/Odin/blob/master/src/tokenizer.cpp>.
syntax keyword odinStatement   import foreign package where do break continue fallthrough defer return using asm
syntax keyword odinConditional if when else switch
syntax keyword odinRepeat      for
syntax keyword odinLabel       case
syntax keyword odinOperator    in not_in auto_cast cast transmute or_else or_return or_break or_continue
syntax keyword odinKeyword     proc context

hi def link odinStatement   Statement
hi def link odinRepeat      Repeat
hi def link odinLabel       Label
hi def link odinConditional Conditional
hi def link odinOperator    Operator
hi def link odinKeyword     Keyword

syntax keyword odinType struct union enum bit_set bit_field map matrix
syntax keyword odinType distinct dynamic

" Basic types. See <https://github.com/odin-lang/Odin/blob/master/src/types.cpp>.
syntax keyword odinType bool b8 b16 b32 b64
syntax keyword odinType int i8 i16 i32 i64 i128
syntax keyword odinType uint u8 u16 u32 u64 u128 uintptr
syntax keyword odinType i16le i32le i64le i128le u16le u32le u64le u128le
syntax keyword odinType i16be i32be i64be i128be u16be u32be u64be u128be
syntax keyword odinType f16 f32 f64 f16le f32le f64le f16be f32be f64be
syntax keyword odinType complex32 complex64 complex128
syntax keyword odinType quaternion64 quaternion128 quaternion256
syntax keyword odinType byte rune string cstring
syntax keyword odinType rawptr typeid any

hi def link odinType Type

" Built-in procedures and procedure groups. See <https://pkg.odin-lang.org/base/builtin>.
if s:HighlightBuiltinProcs()
    syntax keyword odinBuiltin
            \ len cap size_of align_of offset_of offset_of_selector offset_of_member
            \ offset_of_by_string type_of type_info_of typeid_of swizzle complex quaternion
            \ real imag jmag kmag conj expand_values min max abs clamp soa_zip soa_unzip
            \ raw_data
            \ containedin=odinBuiltinProc contained
    hi def link odinBuiltin Function
endif

if s:HighlightBuiltinRuntimeProcs()
    syntax keyword odinBuiltinRuntime
            \ container_of init_global_temporary_allocator copy_slice copy_from_string
            \ unordered_remove ordered_remove remove_range pop pop_safe pop_front
            \ pop_front_safe delete_string delete_cstring delete_dynamic_array delete_slice
            \ delete_map new new_clone make_slice make_dynamic_array make_dynamic_array_len
            \ make_dynamic_array_len_cap make_map make_map_cap make_multi_pointer clear_map
            \ reserve_map shrink_map delete_key append_elem non_zero_append_elem append_elems
            \ non_zero_append_elems append_elem_string non_zero_append_elem_string
            \ append_string append_nothing inject_at_elem inject_at_elems inject_at_elem_string
            \ assign_at_elem assign_at_elems assign_at_elem_string clear_dynamic_array
            \ reserve_dynamic_array non_zero_reserve_dynamic_array resize_dynamic_array
            \ non_zero_resize_dynamic_array map_insert map_upsert map_entry card assert
            \ raw_soa_footer_slice ensure raw_soa_footer_dynamic_array panic make_soa_aligned
            \ make_soa_slice unimplemented make_soa_dynamic_array assert_contextless
            \ make_soa_dynamic_array_len ensure_contextless make_soa_dynamic_array_len_cap
            \ panic_contextless unimplemented_contextless resize_soa non_zero_resize_soa
            \ reserve_soa non_zero_reserve_soa append_soa_elem non_zero_append_soa_elem
            \ append_soa_elems non_zero_append_soa_elems unordered_remove_soa
            \ ordered_remove_soa
            \ copy clear reserve non_zero_reserve resize non_zero_resize
            \ shrink free free_all delete make append non_zero_append inject_at assign_at
            \ make_soa append_soa delete_soa clear_soa
            \ containedin=odinBuiltinProc contained
    hi def link odinBuiltinRuntime odinBuiltin
endif

syntax match odinBuiltinProc "\w\+\ze("

syntax match odinTodo "TODO"  contained
syntax match odinTodo "NOTE"  contained
syntax match odinTodo "HACK"  contained
syntax match odinTodo "FIXME" contained
syntax match odinTodo "XXX"   contained
hi def link odinTodo Todo

syntax region odinRawString start=+`+ end=+`+
syntax region odinChar start=+'+ skip=+\\\\\|\\'+ end=+'+
syntax region odinString start=+"+ skip=+\\\\\|\\'+ end=+"+ contains=odinEscape
syntax match odinEscape /\\\([nrt\\'"]\|x\x\{2}\)/ display contained

hi def link odinString    String
hi def link odinRawString String
hi def link odinChar      Character
hi def link odinEscape    Special

syntax match odinAttribute "@\ze\<\w\+\>" display
syntax region odinAttribute
        \ matchgroup=odinAttribute
        \ start="@\ze(" end="\ze)"
        \ transparent oneline

hi def link odinAttribute Statement

syntax match odinInteger "\-\?\<[0-9][0-9_]*\>" display
syntax match odinFloat   "\-\?\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\%([eE][+-]\=[0-9_]\+\)\=" display
syntax match odinHex     "\<0[xX][0-9A-Fa-f_]\+\>" display
syntax match odinDoz     "\<0[zZ][0-9a-bA-B_]\+\>" display
syntax match odinOct     "\<0[oO][0-7_]\+\>" display
syntax match odinBin     "\<0[bB][01_]\+\>" display

hi def link odinInteger Number
hi def link odinFloat   Float
hi def link odinHex     Number
hi def link odinOct     Number
hi def link odinBin     Number
hi def link odinDoz     Number

syntax keyword odinBool true false
syntax keyword odinNull nil

hi def link odinBool Boolean
hi def link odinNull Constant

syntax match odinUninitialized "---"
hi def link odinUninitialized Constant

syntax region odinBuildTag start=/#+/ end=/$/
syntax match odinDirective "#\<\w\+\>" display

hi def link odinBuildTag  PreProc
hi def link odinDirective PreProc

syntax region odinLineComment start=/\/\// end=/$/  contains=@Spell,odinTodo
syntax region odinBlockComment start=/\/\*/ end=/\*\// contains=@Spell,odinTodo,odinBlockComment
syntax sync ccomment odinBlockComment

hi def link odinLineComment  Comment
hi def link odinBlockComment Comment

let b:current_syntax = "odin"
