function! cactus#internal#buffer#replace(bufnr, content) abort
  return s:replace(a:bufnr, a:content)
endfunction


if has('nvim')
  function! s:replace(bufnr, content) abort
    call nvim_buf_set_lines(a:bufnr, 0, -1, 0, a:content)
  endfunction
else
  function! s:replace(bufnr, content) abort
    call setbufline(a:bufnr, 1, a:content)
    silent! call deletebufline(a:bufnr, len(a:content) + 1, '$')
  endfunction
endif

