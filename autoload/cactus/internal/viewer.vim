let s:ESCAPE_PATTERN = '^$~.*[]\'
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
        \ 'input': '',
        \ 'query': [],
        \ 'indices': v:null,
        \ 'filter_timer': 0,
        \ 'winid': winid,
        \ 'height': options.height,
        \ 'threshold': options.threshold,
        \ 'candidates': a:candidates,
        \ 'close': { -> cactus#internal#window#close(winid) },
        \}
  call s:redraw(ns)
  let ticker = timer_start(
        \ s:TICKER_INTERVAL,
        \ funcref('s:ticker', [ns]),
        \ { 'repeat': -1 },
        \)
  call input('> ')
  call timer_stop(ticker)
  call timer_stop(ns.filter_timer)
  call cactus#internal#window#close(winid)
  redraw | echo ''
  return {
        \ 'query': ns.query,
        \ 'indices': ns.indices,
        \}
endfunction

function! s:ticker(ns, ...) abort
  let input = getcmdline()
  if a:ns.input ==# input
    return
  endif
  call timer_stop(a:ns.filter_timer)
  let a:ns.input = input
  let a:ns.filter_timer = timer_start(
        \ s:INPUT_DELAY,
        \ funcref('s:filter', [a:ns]),
        \)
endfunction

function! s:filter(ns, ...) abort
  let bufnr = winbufnr(a:ns.winid)
  if bufnr is# -1
    return
  endif
  let a:ns.query = cactus#internal#query#parse(a:ns.input)
  let a:ns.indices = cactus#internal#query#filter(
        \ a:ns.query,
        \ a:ns.candidates,
        \ a:ns.threshold,
        \)
  call timer_start(0, funcref('s:redraw', [a:ns]))
endfunction

function! s:redraw(ns, ...) abort
  let bufnr = winbufnr(a:ns.winid)
  if bufnr is# -1
    return
  endif
  if a:ns.indices is# v:null
    let content = a:ns.candidates[: a:ns.threshold - 1]
  else
    let candidates = a:ns.candidates
    let content = map(
          \ copy(a:ns.indices),
          \ { _, v -> candidates[v] },
          \)
  endif
  call extend(content, repeat([''], max([0, a:ns.height - len(content)])))
  call reverse(content)
  call cactus#internal#buffer#replace(bufnr, content)

  " XXX
  call win_gotoid(a:ns.winid)
  normal! G
  syntax clear
  execute printf(
        \ 'silent! syntax match CactusMatch "%s"',
        \ s:build_pattern(a:ns.query),
        \)
  redraw
endfunction

function! s:build_pattern(query) abort
  let q = copy(a:query)
  call map(q, { -> map(v:val, { -> escape(v:val, s:ESCAPE_PATTERN) }) })
  call map(q, { -> join(v:val, '\|') })
  return '\c' . escape(join(q, '\|'), '"')
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
