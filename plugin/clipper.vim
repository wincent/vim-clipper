" Copyright 2015-present Greg Hurrell. All rights reserved.
" Licensed under the terms of the BSD 2-clause license.

" Provide users with means to prevent loading, as recommended in `:h
" write-plugin`.
if exists('g:ClipperLoaded') || &compatible || v:version < 700
  finish
endif
let g:ClipperLoaded=1

" Temporarily set 'cpoptions' to Vim default as per `:h use-cpo-save`.
let s:cpoptions=&cpoptions
set cpoptions&vim

command! Clip call clipper#private#clip()

let s:map=get(g:, 'ClipperMap', 1)
if s:map
  if !hasmapto('<Plug>(ClipperClip)') && maparg('<leader>y', 'n') ==# ''
    nmap <unique> <leader>y <Plug>(ClipperClip)
  endif
endif
nnoremap <Plug>(ClipperClip) :Clip<CR>

function! ClipperMaybeClip(event)
  let l:system=get(g:, 'ClipperAutoSystemOnly', 0)
  if l:system == 1 && a:event.operator ==# 'y' && (a:event.regname == '+' || a:event.regname == '*')
    call clipper#private#clip(a:event.regname)
  elseif l:system == 0 && a:event.operator ==# 'y'
    call clipper#private#clip(0)
  endif
endfunction

let s:auto=get(g:, 'ClipperAuto', 1)
if s:auto && exists('##TextYankPost')
  augroup Clipper
    autocmd!
    autocmd TextYankPost * call ClipperMaybeClip(v:event)
  augroup END
endif

" Restore 'cpoptions' to its former value.
let &cpoptions=s:cpoptions
unlet s:cpoptions
