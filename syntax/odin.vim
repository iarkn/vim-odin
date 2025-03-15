vim9script

# Vim indent plugin file
# Language: Odin
# Maintainer: Maxim Kim <habamax@gmail.com>
# Website: https://github.com/habamax/vim-odin
# Last Change: 2025-03-15

if exists("b:current_syntax")
  finish
endif

syntax keyword odinKeyword using transmute cast auto_cast distinct opaque where dynamic
syntax keyword odinKeyword struct enum union bit_field bit_set
syntax keyword odinKeyword package proc map import export foreign
syntax keyword odinKeyword return defer fallthrough
syntax keyword odinKeyword or_return or_else or_continue or_break
syntax keyword odinKeyword inline no_inline
syntax keyword odinKeyword in not_in

syntax keyword odinConditional if when else do for switch case continue break
syntax keyword odinType string cstring bool b8 b16 b32 b64 byte rune any rawptr
syntax keyword odinType f16 f32 f64 f16le f16be f32le f32be f64le f64be
syntax keyword odinType u8 u16 u32 u64 u128 u16le u32le u64le u128le u16be
syntax keyword odinType u32be u64be u128be uint uintptr i8 i16 i32 i64 i128
syntax keyword odinType i16le i32le i64le i128le i16be i32be i64be i128be
syntax keyword odinType int complex complex32 complex64 complex128 matrix typeid
syntax keyword odinType quaternion quaternion64 quaternion128 quaternion256
syntax keyword odinBool true false
syntax keyword odinNull nil
syntax match odinUninitialized '\s\+---\(\s\|$\)'

syntax keyword odinBuiltin abs align_of append append_elem append_elem_string append_elems
syntax keyword odinBuiltin append_nothing append_soa append_soa_elem append_soa_elems append_string
syntax keyword odinBuiltin assert assert_contextless assign_at assign_at_elem assign_at_elem_string
syntax keyword odinBuiltin assign_at_elems cap card clamp clear clear_dynamic_array clear_map clear_soa
syntax keyword odinBuiltin complex conj container_of copy copy_from_string copy_slice delete delete_cstring
syntax keyword odinBuiltin delete_dynamic_array delete_key delete_map delete_slice delete_soa delete_string
syntax keyword odinBuiltin ensure ensure_contextless expand_values free free_all imag
syntax keyword odinBuiltin init_global_temporary_allocator inject_at inject_at_elem inject_at_elem_string
syntax keyword odinBuiltin inject_at_elems jmag kmag len make make_dynamic_array make_dynamic_array_len
syntax keyword odinBuiltin make_dynamic_array_len_cap make_map make_map_cap make_multi_pointer make_slice
syntax keyword odinBuiltin make_soa make_soa_aligned make_soa_dynamic_array make_soa_dynamic_array_len
syntax keyword odinBuiltin make_soa_dynamic_array_len_cap make_soa_slice map_entry map_insert map_upsert
syntax keyword odinBuiltin max min new new_clone non_zero_append non_zero_append_elem
syntax keyword odinBuiltin non_zero_append_elem_string non_zero_append_elems non_zero_append_soa_elem
syntax keyword odinBuiltin non_zero_append_soa_elems non_zero_reserve non_zero_reserve_dynamic_array
syntax keyword odinBuiltin non_zero_reserve_soa non_zero_resize non_zero_resize_dynamic_array
syntax keyword odinBuiltin non_zero_resize_soa offset_of offset_of_by_string offset_of_member
syntax keyword odinBuiltin offset_of_selector ordered_remove ordered_remove_soa panic panic_contextless
syntax keyword odinBuiltin pop pop_front pop_front_safe pop_safe quaternion raw_data
syntax keyword odinBuiltin raw_soa_footer_dynamic_array raw_soa_footer_slice real remove_range reserve
syntax keyword odinBuiltin reserve_dynamic_array reserve_map reserve_soa resize resize_dynamic_array
syntax keyword odinBuiltin resize_soa shrink shrink_map size_of soa_unzip soa_zip swizzle type_info_of
syntax keyword odinBuiltin type_of typeid_of unimplemented unimplemented_contextless unordered_remove
syntax keyword odinBuiltin unordered_remove_soa

syntax match odinTodo "TODO" contained
syntax match odinTodo "XXX" contained
syntax match odinTodo "FIXME" contained
syntax match odinTodo "HACK" contained

syntax region odinRawString start=+`+ end=+`+
syntax region odinChar start=+'+ skip=+\\\\\|\\'+ end=+'+
syntax region odinString start=+"+ skip=+\\\\\|\\'+ end=+"+ contains=odinEscape
syntax match odinEscape display contained /\\\([nrt\\'"]\|x\x\{2}\)/

#syntax match odinProcedure "\v<\w*>(\s*::\s*proc)@="

syntax match odinAttribute "@\ze\<\w\+\>" display
syntax region odinAttribute
      \ matchgroup=odinAttribute
      \ start="@\ze(" end="\ze)"
      \ transparent oneline

syntax match odinInteger "\-\?\<\d\+\>" display
syntax match odinFloat "\-\?\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\%([eE][+-]\=[0-9_]\+\)\=" display
syntax match odinHex "\<0[xX][0-9A-Fa-f]\+\>" display
syntax match odinDoz "\<0[zZ][0-9a-bA-B]\+\>" display
syntax match odinOct "\<0[oO][0-7]\+\>" display
syntax match odinBin "\<0[bB][01]\+\>" display

syntax match odinAddressOf "&" display
syntax match odinDeref "\^" display

syntax match odinMacro "#\<\w\+\>" display

syntax match odinTemplate "$\<\w\+\>"

syntax region odinLineComment start=/\/\// end=/$/  contains=@Spell,odinTodo
syntax region odinBlockComment start=/\/\*/ end=/\*\// contains=@Spell,odinTodo,odinBlockComment
syn sync ccomment odinBlockComment

highlight def link odinKeyword       Statement
highlight def link odinConditional   Conditional
highlight def link odinOperator      Operator
highlight def link odinBuiltin       Identifier

highlight def link odinString        String
highlight def link odinRawString     String
highlight def link odinChar          Character
highlight def link odinEscape        Special

highlight def link odinProcedure     Function

highlight def link odinMacro         PreProc

highlight def link odinLineComment   Comment
highlight def link odinBlockComment  Comment

highlight def link odinTodo          Todo

highlight def link odinAttribute     Statement
highlight def link odinType          Type
highlight def link odinBool          Boolean
highlight def link odinNull          Constant
highlight def link odinUninitialized Constant
highlight def link odinInteger       Number
highlight def link odinFloat         Float
highlight def link odinHex           Number
highlight def link odinOct           Number
highlight def link odinBin           Number
highlight def link odinDoz           Number

b:current_syntax = "odin"
