function! cactus#internal#buffer#replace(bufnr, content) abort
  return s:replace(a:bufnr, a:content)
endfunction

function! cactus#internal#buffer#highlight(bufnr, hl, line, col_start, col_end) abort
  return s:highlight(a:bufnr, a:hl, a:line, a:col_start, a:col_end)
endfunction

function! cactus#internal#buffer#clear_highlights(bufnr) abort
  return s:clear_highlights(a:bufnr)
endfunction


if has('nvim')
  function! s:replace(bufnr, content) abort
    call nvim_buf_set_lines(a:bufnr, 0, -1, 0, a:content)
  endfunction

  function! s:highlight(bufnr, hl_group, line, col_start, col_end) abort
    call nvim_buf_add_highlight(
          \ a:bufnr,
          \ s:namespace,
          \ a:hl_group,
          \ a:line,
          \ a:col_start,
          \ a:col_end,
          \)
  endfunction

  function! s:clear_highlights(bufnr) abort
    call nvim_buf_clear_namespace(a:bufnr, s:namespace, 1, -1)
  endfunction

  let s:namespace = nvim_create_namespace('cactus')
else
  function! s:replace(bufnr, content) abort
    call setbufline(a:bufnr, 1, a:content)
    silent! call deletebufline(a:bufnr, len(a:content) + 1, '$')
  endfunction

  function! s:highlight(bufnr, hl_group, line, col_start, col_end) abort
    call prop_type_change(s:match_type_name, {'highlight': a:hl_group})
    silent! call prop_add(a:line + 1, a:col_start + 1, {
          \ 'bufnr': a:bufnr,
          \ 'end_col': a:col_end + 1,
          \ 'type': s:match_type_name,
          \})
  endfunction

  function! s:clear_highlights(bufnr) abort
    silent! call prop_clear(1, '$', {
          \ 'bufnr': a:bufnr,
          \})
  endfunction

  let s:match_type_name = 'cactus_match'
  if empty(prop_type_get(s:match_type_name))
    call prop_type_add(s:match_type_name, {})
  endif
endif

