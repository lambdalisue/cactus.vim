function! cactus#internal#window#open(...) abort
  let options = extend({
        \ 'height': 15,
        \ 'highlight': 'CactusWindow',
        \}, a:0 ? a:1 : {},
        \)
  return s:open(
        \ options.height,
        \ options.highlight,
        \)
endfunction

function! cactus#internal#window#close(winid) abort
  return s:close(a:winid)
endfunction

function! cactus#internal#window#resize(winid, height) abort
  return s:resize(a:winid, a:height)
endfunction

if has('nvim')
  function! s:open(height, hl_group) abort
    let buf = nvim_create_buf(v:false, v:true)
    let win = nvim_open_win(buf, 0, {
          \ 'relative': 'editor',
          \ 'width': &columns,
          \ 'height': a:height,
          \ 'col': 0,
          \ 'row': &lines,
          \ 'anchor': 'SE',
          \ 'style': 'minimal',
          \})
    call setbufvar(buf, 'bufhidden', 'wipe')
    call setwinvar(
          \ win,
          \ '&winhighlight',
          \ 'Normal:' . a:hl_group,
          \)
    return win
  endfunction

  function! s:close(winid) abort
    call nvim_win_close(a:winid, v:true)
  endfunction

  function! s:resize(winid, height) abort
    call nvim_win_set_config(a:winid, {
          \ 'height': max([1, a:height]),
          \})
  endfunction
else
  function! s:open(height, hl_group) abort
    let win = popup_create('', {
          \ 'line': &lines - 1,
          \ 'col': 1,
          \ 'pos': 'botleft',
          \ 'fixed': 1,
          \ 'minwidth': &columns,
          \ 'maxheight': a:height,
          \ 'highlight': a:hl_group,
          \})
    let buf = winbufnr(win)
    call setbufvar(buf, 'bufhidden', 'wipe')
    return win
  endfunction

  function! s:close(winid) abort
    call popup_close(a:winid)
  endfunction

  function! s:resize(winid, height) abort
    call popup_move(a:winid, {
          \ 'maxheight': max([1, a:height]),
          \})
  endfunction
endif
