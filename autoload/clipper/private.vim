" Copyright 2015-present Greg Hurrell. All rights reserved.
" Licensed under the terms of the BSD 2-clause license.

function! clipper#private#clip() abort
  if executable('nc') == 1
    let l:address = get(g:, 'ClipperAddress', 'localhost')
    let l:port = +(get(g:, 'ClipperPort', 8377)) " Co-erce to number.
    if l:port
      call system('nc ' . l:address . ' ' . l:port, @0)
    else
      call system('nc -U ' . l:address, @0)
    endif
  else
    echoerr 'Clipper: nc executable does not exist'
  endif
endfunction
