" Copyright 2015-present Greg Hurrell. All rights reserved.
" Licensed under the terms of the BSD 2-clause license.

function! clipper#private#set_invocation(method) abort
  if !exists('s:invocation')
    let s:invocation=a:method
  endif
endfunction

function! clipper#private#clip() abort
  if exists('s:invocation') && s:invocation != ''
    call system(s:invocation, @0)
  elseif clipper#private#executable() != ''
    let l:executable = clipper#private#executable()
    let l:address = get(g:, 'ClipperAddress', 'localhost')
    let l:port = +(get(g:, 'ClipperPort', 8377)) " Co-erce to number.
    if l:port
      " nc
      call system(l:executable . ' ' . l:address . ' ' . l:port, @0)
    else
      " nc -U
      call system(l:executable . ' -U ' . l:address, @0)
    endif
  else
    echoerr 'Clipper: nc executable does not exist'
  endif
endfunction

let s:executable=''

function! clipper#private#executable() abort
  if s:executable == '' && executable('nc') == 1
    " Try to figure out whether -N switch is supported and required.
    " Examples:
    " - Ubuntu, FreeBSD and similar:
    "     Supports and requires -N:
    "     "shutdown(2) the network socket after EOF on the input"
    "     http://manpages.ubuntu.com/manpages/bionic/man1/nc_openbsd.1.html
    "     https://www.freebsd.org/cgi/man.cgi?nc
    " - Darwin:
    "     Supports but does not require -N; it does something else:
    "     "Number of probes to send before generating a write timeout event"
    " - CentOS etc:
    "     Does not support or need -N.
    let l:help = system('nc -h')
    if match(l:help, '\v\s-N\s.+shutdown>') != -1
      let s:executable = 'nc -N'
    else
      let s:executable = 'nc'
    endif
  endif
  return s:executable
endfunction
