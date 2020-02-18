let s:TICKER_INTERVAL = 10
let s:INPUT_DELAY = 200

function! cactus#internal#viewer#open(candidates, ...) abort
  let options = extend({
        \ 'height': 15,
        \ 'threshold': 100,
        \}, a:0 ? a:1 : {},
        \)
  let winid = cactus#internal#window#open({
        \ 'height': options.height,
        \ 'highlight': 'CactusWindow',
        \})
  let ns = {
        \ 'query': '',
        \ 'content': reverse(a:candidates[: options.threshold - 1]),
        \ 'matches': [],
        \ 'filter_timer': 0,
        \ 'winid': winid,
        \ 'height': options.height,
        \ 'threshold': options.threshold,
        \ 'candidates': a:candidates,
        \}
  call s:redraw(ns)
  let ticker = timer_start(
        \ s:TICKER_INTERVAL,
        \ funcref('s:ticker', [ns]),
        \ { 'repeat': -1 },
        \)
  let pattern = input('> ')
  call timer_stop(ticker)
  call timer_stop(ns.filter_timer)
  call cactus#internal#window#close(winid)
  redraw | echo ''
  return ns.matches
endfunction

function! s:ticker(ns, ...) abort
  let query = getcmdline()
  if a:ns.query ==# query
    return
  endif
  call timer_stop(a:ns.filter_timer)
  let a:ns.query = query
  let a:ns.filter_timer = timer_start(s:INPUT_DELAY, { -> s:filter(a:ns) })
endfunction

function! s:filter(ns) abort
  let bufnr = winbufnr(a:ns.winid)
  if bufnr is# -1
    return
  endif
  let r = cactus#internal#filter#apply(
        \ cactus#internal#filter#fuzzy(a:ns.query),
        \ a:ns.candidates,
        \ a:ns.threshold,
        \)
  let a:ns.content = r.content
  let a:ns.matches = r.matches
  call s:redraw(a:ns)
endfunction

function! s:redraw(ns) abort
  let bufnr = winbufnr(a:ns.winid)
  let n = len(a:ns.candidates)
  let m = len(a:ns.content)
  let s = n > a:ns.threshold && m >= a:ns.threshold ? '+' : ''
  let c = extend([printf('Match: %d%s/%d', m, s, n)], a:ns.content)
  call cactus#internal#buffer#replace(bufnr, c)
  call cactus#internal#buffer#clear_highlights(bufnr)
  call map(
        \ copy(a:ns.matches),
        \ { i, v -> cactus#internal#buffer#highlight(bufnr, 'CactusMatch', i + 1, v[1], v[2]) },
        \)
  call cactus#internal#window#resize(
        \ a:ns.winid,
        \ min([a:ns.height, len(a:ns.content) + 1]),
        \)
  redraw
endfunction

function! s:define_highlights() abort
  highlight default link CactusWindow Visual
  highlight default link CactusMatch Search
endfunction

augroup cactus_internal_window
  autocmd! *
  autocmd ColorScheme * call s:define_highlights()
augroup END

call s:define_highlights()
